<#
.SYNOPSIS
    Parses an InterClub season standings Excel file and generates individual-standings.json.

.DESCRIPTION
    Reads the final season standings Excel file and generates:
      - individual-standings.json  (from "Y2D - Age Category", "Y2D - Ladies", "Y2D - Men" tabs)

    Sheets used:
      "Y2D - Age Category" - per-age-category standings; header row 2, data from row 3.
        Race positions (cols 7-13) are positions within the specific age category.
        Col 41 = within-category rank.  Cols 33-36 = 4 counting positions (sorted).

      "Y2D - Ladies" - overall ladies standings (all female ages combined); header row 1, data from row 3.
        Race positions (cols 7-13) are positions among ALL ladies.
        Col 42 = overall ladies rank.

      "Y2D - Men" - overall men's standings (all male ages combined); header row 1, data from row 3.
        Race positions (cols 7-13) are positions among ALL men.
        Col 42 = overall men rank.

.PARAMETER ExcelFile
    Path to the season standings Excel file (e.g. "inter club final 2025.xlsx").

.PARAMETER Year
    Series year (e.g. 2025).  Defaults to 2025.

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER Provisional
    When set, marks the output JSON as provisional.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\parse-individual-standings.ps1 -ExcelFile "C:\Downloads\inter club final 2025.xlsx"

.EXAMPLE
    .\scripts\parse-individual-standings.ps1 -ExcelFile "C:\Downloads\inter club final 2025.xlsx" -Provisional -DryRun
#>

[CmdletBinding()]
param(
    [string]$ExcelFile,
    [string]$Year = "2025",
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$Provisional,
    [switch]$DryRun,
    [int]$AgeCatScoreColumn = 0,
    [int]$OverallScoreColumn = 0,
    # When set, no score column exists in the Excel: total is emitted as null and all
    # non-empty name rows are included regardless of score.  Auto-enabled for years <= 2017.
    [switch]$NoScore
)

$ErrorActionPreference = "Stop"

# --- Helpers ------------------------------------------------------------------

function Prompt-Value {
    param([string]$Prompt, [string]$Default = "")
    if ($Default) {
        $val = Read-Host "$Prompt [$Default]"
        if (-not $val) { return $Default }
        return $val
    }
    do { $val = Read-Host $Prompt } while (-not $val)
    return $val
}

function Get-ClubId {
    param([string]$Name)
    switch -Wildcard ($Name.Trim().ToLower()) {
        "blackpool*" { return "blackpool" }
        "b.w.f*"     { return "blackpool" }
        "bwf*"       { return "blackpool" }
        "chorley*"   { return "chorley" }
        "lytham*"    { return "lytham" }
        "lsa*"       { return "lytham" }
        "north fylde*" { return "north-fylde" }
        "preston*"   { return "preston" }
        "red rose*"  { return "red-rose" }
        "red-rose*"  { return "red-rose" }
        "thornton*"  { return "thornton" }
        "wesham*"    { return "wesham" }
        "guest*"     { return "Guest" }
    }
    return $null
}

# Maps Excel category string to individual-standings category id and site fields.
# Returns $null for unmapped categories (silently skipped).
function Get-CategoryInfo {
    param([string]$ExcelCat)
    switch ($ExcelCat.Trim()) {
        "JF"   { return @{ Id = "jun-female"; Sex = "F"; AgeCategory = "JUN" } }
        "JM"   { return @{ Id = "jun-male";   Sex = "M"; AgeCategory = "JUN" } }
        "F"    { return @{ Id = "sen-female"; Sex = "F"; AgeCategory = "SEN" } }
        "M"    { return @{ Id = "sen-male";   Sex = "M"; AgeCategory = "SEN" } }
        "F-35" { return @{ Id = "v35-female"; Sex = "F"; AgeCategory = "V35" } }
        "F-40" { return @{ Id = "v40-female"; Sex = "F"; AgeCategory = "V40" } }
        "F-45" { return @{ Id = "v45-female"; Sex = "F"; AgeCategory = "V45" } }
        "F-50" { return @{ Id = "v50-female"; Sex = "F"; AgeCategory = "V50" } }
        "F-55" { return @{ Id = "v55-female"; Sex = "F"; AgeCategory = "V55" } }
        "F-60" { return @{ Id = "v60-female"; Sex = "F"; AgeCategory = "V60" } }
        "F-65" { return @{ Id = "v65-female"; Sex = "F"; AgeCategory = "V65" } }
        "F-70" { return @{ Id = "v70-female"; Sex = "F"; AgeCategory = "V70" } }
        "F-75" { return @{ Id = "v75-female"; Sex = "F"; AgeCategory = "V75" } }
        "F-80" { return @{ Id = "v80-female"; Sex = "F"; AgeCategory = "V80" } }
        "F-85" { return @{ Id = "v85-female"; Sex = "F"; AgeCategory = "V85" } }
        "M-40" { return @{ Id = "v40-male";   Sex = "M"; AgeCategory = "V40" } }
        "M-45" { return @{ Id = "v45-male";   Sex = "M"; AgeCategory = "V45" } }
        "M-50" { return @{ Id = "v50-male";   Sex = "M"; AgeCategory = "V50" } }
        "M-55" { return @{ Id = "v55-male";   Sex = "M"; AgeCategory = "V55" } }
        "M-60" { return @{ Id = "v60-male";   Sex = "M"; AgeCategory = "V60" } }
        "M-65" { return @{ Id = "v65-male";   Sex = "M"; AgeCategory = "V65" } }
        "M-70" { return @{ Id = "v70-male";   Sex = "M"; AgeCategory = "V70" } }
        "M-75" { return @{ Id = "v75-male";   Sex = "M"; AgeCategory = "V75" } }
        "M-80" { return @{ Id = "v80-male";   Sex = "M"; AgeCategory = "V80" } }
        "M-85" { return @{ Id = "v85-male";   Sex = "M"; AgeCategory = "V85" } }
    }
    return $null
}

# Race column numbers in the standings sheets (consistent across all three sheets).
# Defined as a function so it is available in all scopes without $script: reliance.
function Get-RaceColMap {
    # Keys are column numbers as strings to avoid OrderedDictionary integer-index ambiguity
    return @{
        "7"  = "blackpool"
        "8"  = "lytham"
        "9"  = "preston"
        "10" = "thornton"
        "11" = "wesham"
        "12" = "chorley"
        "13" = "red-rose"
    }
}

# Builds the per-race results map for a runner.
# $RacePositions: ordered dict raceId -> position (999 = did not run)
# $MaxCounting: maximum races that count (from config)
# Returns ordered dict raceId -> {points, counting}
function Build-RaceResults {
    param(
        [System.Collections.Specialized.OrderedDictionary]$RacePositions,
        [int]$MaxCounting
    )

    # Collect only races the runner entered (non-999)
    $entered = [System.Collections.Generic.List[PSCustomObject]]@()
    foreach ($raceId in $RacePositions.Keys) {
        $pos = $RacePositions[$raceId]
        if ($pos -ne 999) {
            $entered.Add([PSCustomObject]@{ RaceId = $raceId; Points = $pos })
        }
    }

    # Sort by points ascending; stable sort preserves original (column) order for ties
    $sorted = @($entered | Sort-Object Points)

    # The first MaxCounting are counting (or all if fewer entered)
    $countingSet = [System.Collections.Generic.HashSet[string]]@()
    for ($i = 0; $i -lt [Math]::Min($MaxCounting, $sorted.Count); $i++) {
        $countingSet.Add($sorted[$i].RaceId) | Out-Null
    }

    $results = [ordered]@{}
    foreach ($e in $entered) {
        $results[$e.RaceId] = [ordered]@{
            points   = $e.Points
            counting = $countingSet.Contains($e.RaceId)
        }
    }

    return $results
}

# --- Sheet parsers ------------------------------------------------------------

# Parses "Y2D - Age Category".
# Standard format: header row 2 (row 1 blank), data from row 3.
# No-score format (years <= 2017): header row 1, data from row 2; no score column.
# Returns list of PSCustomObject with fields needed for per-age-category standings.
# Position is inferred from the order rows appear within each category (sheet is assumed sorted).
function Parse-AgeCategory {
    param($Sheet, [int]$MaxCounting, [int]$ScoreColumn = 40, [switch]$NoScore)

    $raceColMap       = Get-RaceColMap
    $hasRaceCols      = (-not $NoScore) -and ($ScoreColumn -gt 13)
    $dataStartRow     = if ($NoScore) { 2 } else { 3 }
    $totalRows        = $Sheet.UsedRange.Rows.Count
    $runners          = [System.Collections.Generic.List[PSCustomObject]]@()
    $categoryCounters = @{}

    for ($r = $dataStartRow; $r -le $totalRows; $r++) {
        $first   = $Sheet.Cells.Item($r, 2).Text.Trim()
        $last    = $Sheet.Cells.Item($r, 3).Text.Trim()
        $cat     = $Sheet.Cells.Item($r, 4).Text.Trim()
        $clubRaw = $Sheet.Cells.Item($r, 5).Text.Trim()

        if (-not $first -and -not $last) { continue }
        if (-not $cat) { continue }

        $catInfo = Get-CategoryInfo $cat
        if (-not $catInfo) { continue }

        if ($NoScore) {
            $score = $null
        } else {
            $scoreRaw = $Sheet.Cells.Item($r, $ScoreColumn).Text.Trim()
            $score    = if ($scoreRaw -match '^\d+$') { [int]$scoreRaw } else { 0 }
            if ($score -eq 0) { continue }
        }

        if (-not $categoryCounters.ContainsKey($catInfo.Id)) { $categoryCounters[$catInfo.Id] = 0 }
        $categoryCounters[$catInfo.Id]++
        $position = $categoryCounters[$catInfo.Id]

        $clubId = Get-ClubId $clubRaw
        if (-not $clubId) {
            Write-Warning "Row $r (Age Cat): unknown club '$clubRaw'"
            $clubId = "Guest"
        }

        $raceResults = [ordered]@{}
        if ($hasRaceCols) {
            $racePositions = [ordered]@{}
            foreach ($col in $raceColMap.Keys) {
                # Use .Value2 (not .Text) so narrow columns don't return '#' for multi-digit positions
                $rawVal = $Sheet.Cells.Item($r, [int]$col).Value2
                $racePositions[$raceColMap["$col"]] = if ($rawVal -is [double] -or $rawVal -is [int]) { [int]$rawVal } else { 999 }
            }
            $raceResults = Build-RaceResults -RacePositions $racePositions -MaxCounting $MaxCounting
        }

        $runners.Add([PSCustomObject]@{
            Name        = "$first $last".Trim()
            Club        = $clubId
            Sex         = $catInfo.Sex
            AgeCategory = $catInfo.AgeCategory
            CategoryId  = $catInfo.Id
            Position    = $position
            Total       = $score
            Results     = $raceResults
        })
    }

    return $runners
}

# Parses "Y2D - Ladies" or "Y2D - Men" overall sheet.
# Header row 1, data from row 2 onward (row 2 may or may not be blank; blank rows are skipped).
# $OverallCategoryId: "female" or "male"
# $Sex: "F" or "M"
# Returns list of PSCustomObject for the overall category.
# Position is inferred from row order (sheet is assumed sorted).
function Parse-OverallSheet {
    param($Sheet, [string]$OverallCategoryId, [string]$Sex, [int]$MaxCounting, [int]$ScoreColumn = 40, [switch]$NoScore)

    $raceColMap  = Get-RaceColMap
    $hasRaceCols = (-not $NoScore) -and ($ScoreColumn -gt 13)
    $totalRows   = $Sheet.UsedRange.Rows.Count
    $runners     = [System.Collections.Generic.List[PSCustomObject]]@()
    $posCounter  = 0

    for ($r = 2; $r -le $totalRows; $r++) {
        $first   = $Sheet.Cells.Item($r, 2).Text.Trim()
        $last    = $Sheet.Cells.Item($r, 3).Text.Trim()
        $cat     = $Sheet.Cells.Item($r, 4).Text.Trim()
        $clubRaw = $Sheet.Cells.Item($r, 5).Text.Trim()

        if (-not $first -and -not $last) { continue }
        if (-not $cat) { continue }

        if ($NoScore) {
            $score = $null
        } else {
            $scoreRaw = $Sheet.Cells.Item($r, $ScoreColumn).Text.Trim()
            $score    = if ($scoreRaw -match '^\d+$') { [int]$scoreRaw } else { 0 }
            if ($score -eq 0) { continue }
        }

        $posCounter++
        $position = $posCounter

        $catInfo     = Get-CategoryInfo $cat
        $ageCategory = if ($catInfo) { $catInfo.AgeCategory } else { "SEN" }

        $clubId = Get-ClubId $clubRaw
        if (-not $clubId) {
            Write-Warning "Row $r ($OverallCategoryId): unknown club '$clubRaw'"
            $clubId = "Guest"
        }

        $raceResults = [ordered]@{}
        if ($hasRaceCols) {
            $racePositions = [ordered]@{}
            foreach ($col in $raceColMap.Keys) {
                # Use .Value2 (not .Text) so narrow columns don't return '#' for multi-digit positions
                $rawVal = $Sheet.Cells.Item($r, [int]$col).Value2
                $racePositions[$raceColMap["$col"]] = if ($rawVal -is [double] -or $rawVal -is [int]) { [int]$rawVal } else { 999 }
            }
            $raceResults = Build-RaceResults -RacePositions $racePositions -MaxCounting $MaxCounting
        }

        $runners.Add([PSCustomObject]@{
            Name        = "$first $last".Trim()
            Club        = $clubId
            Sex         = $Sex
            AgeCategory = $ageCategory
            CategoryId  = $OverallCategoryId
            Position    = $position
            Total       = $score
            Results     = $raceResults
        })
    }

    return $runners
}

# --- Output builder -----------------------------------------------------------

# Returns ordered list of all recognised category definitions (id, Sex, AgeCategory, Name).
# Categories absent from the parsed data are automatically skipped by Build-IndividualStandingsJson.
function Get-AllCategoryDefinitions {
    $defs = [System.Collections.Generic.List[hashtable]]::new()
    # Overall categories first (no AgeCategory — span all ages).
    # Name is intentionally not set: the site's chipLabel falls back to 'Overall' when
    # both name and ageCategory are absent, giving the correct chip label automatically.
    $defs.Add(@{ Id = "male";   Sex = "M"; AgeCategory = $null; Name = $null })
    $defs.Add(@{ Id = "female"; Sex = "F"; AgeCategory = $null; Name = $null })
    # Juniors
    $defs.Add(@{ Id = "jun-male";   Sex = "M"; AgeCategory = "JUN"; Name = $null })
    $defs.Add(@{ Id = "jun-female"; Sex = "F"; AgeCategory = "JUN"; Name = $null })
    # Seniors
    $defs.Add(@{ Id = "sen-male";   Sex = "M"; AgeCategory = "SEN"; Name = $null })
    $defs.Add(@{ Id = "sen-female"; Sex = "F"; AgeCategory = "SEN"; Name = $null })
    # V35 female only
    $defs.Add(@{ Id = "v35-female"; Sex = "F"; AgeCategory = "V35"; Name = $null })
    # V40 and above — male then female for each age band
    foreach ($age in @(40, 45, 50, 55, 60, 65, 70, 75, 80, 85)) {
        $defs.Add(@{ Id = "v$age-male";   Sex = "M"; AgeCategory = "V$age"; Name = $null })
        $defs.Add(@{ Id = "v$age-female"; Sex = "F"; AgeCategory = "V$age"; Name = $null })
    }
    return $defs
}

function Build-IndividualStandingsJson {
    param(
        $AllRunners,
        [string[]]$RaceIds,
        [int]$MaxCounting,
        [bool]$IsProvisional
    )

    $categories = [System.Collections.Generic.List[object]]@()

    foreach ($catDef in (Get-AllCategoryDefinitions)) {
        $catRunners = @($AllRunners | Where-Object { $_.CategoryId -eq $catDef.Id })
        if ($catRunners.Count -eq 0) { continue }

        $sorted = @($catRunners | Sort-Object Position)

        $runnerEntries = [System.Collections.Generic.List[object]]@()
        foreach ($runner in $sorted) {
            $resultsMap = [ordered]@{}
            foreach ($raceId in $RaceIds) {
                if ($runner.Results.Contains($raceId)) {
                    $rr = $runner.Results[$raceId]
                    $resultsMap[$raceId] = [ordered]@{
                        points   = $rr.points
                        counting = $rr.counting
                    }
                }
            }

            $runnerEntries.Add([ordered]@{
                position    = $runner.Position
                name        = $runner.Name
                club        = $runner.Club
                sex         = $runner.Sex
                ageCategory = $runner.AgeCategory
                total       = $runner.Total
                results     = $resultsMap
            })
        }

        # Build category object with only the fields that are set
        $catObj = [ordered]@{}
        $catObj['id'] = $catDef.Id
        if ($catDef.Sex)         { $catObj['sex']         = $catDef.Sex }
        if ($catDef.AgeCategory) { $catObj['ageCategory'] = $catDef.AgeCategory }
        if ($catDef.Name)        { $catObj['name']        = $catDef.Name }
        $catObj['runners'] = $runnerEntries.ToArray()
        $categories.Add($catObj)
    }

    $root = [ordered]@{}
    $root['provisional'] = $IsProvisional
    if ($MaxCounting -gt 0) { $root['maxCountingRaces'] = $MaxCounting }
    $root['races']      = $RaceIds
    $root['categories'] = $categories.ToArray()
    return $root
}

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Individual Standings Parser" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if (-not $ExcelFile) {
    $ExcelFile = Prompt-Value "Excel file path"
}
$ExcelFile = [System.IO.Path]::GetFullPath($ExcelFile)
if (-not (Test-Path $ExcelFile)) { throw "Excel file not found: $ExcelFile" }

if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path $ProjectRoot)) { throw "Project root not found: $ProjectRoot" }

if (-not $PSBoundParameters.ContainsKey('Provisional')) {
    $provInput   = Read-Host "Mark as provisional? (y/N)"
    $Provisional = $provInput -match '^[yY]'
}

# Determine score columns for each sheet type.
# <= 2017: no score data in the standings sheets at all; NoScore is auto-enabled below.
# 2018: Age Category uses col 15 (O), Ladies/Men use col 7 (G), no per-race columns.
# 2019: all sheets use col 9, no per-race columns.
# 2020+: all sheets use col 40, with per-race columns.
if ($AgeCatScoreColumn -eq 0 -or $OverallScoreColumn -eq 0) {
    if ([int]$Year -eq 2018) {
        if ($AgeCatScoreColumn -eq 0) { $AgeCatScoreColumn = 15 }
        if ($OverallScoreColumn -eq 0) { $OverallScoreColumn = 7 }
    } elseif ([int]$Year -le 2019) {
        if ($AgeCatScoreColumn -eq 0) { $AgeCatScoreColumn = 9 }
        if ($OverallScoreColumn -eq 0) { $OverallScoreColumn = 9 }
    } else {
        if ($AgeCatScoreColumn -eq 0) { $AgeCatScoreColumn = 40 }
        if ($OverallScoreColumn -eq 0) { $OverallScoreColumn = 40 }
    }
}
$ScoreColumn = $OverallScoreColumn

# Auto-enable NoScore for years where the standings sheets contain no score column.
if (-not $PSBoundParameters.ContainsKey('NoScore') -and [int]$Year -le 2017) {
    $NoScore = $true
}

$dataDir     = Join-Path $ProjectRoot "src\data\$Year\$Series"
$configFile  = Join-Path $dataDir "config.json"
$racesFile   = Join-Path $dataDir "races.json"
$outputFile  = Join-Path $dataDir "individual-standings.json"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Excel:       $ExcelFile"
Write-Host "  Year:        $Year  |  Series: $Series"
Write-Host "  Provisional: $Provisional"
Write-Host "  NoScore:     $NoScore$(if ($NoScore) { ' (total will be null; position from row order)' })"
Write-Host "  AgeCatScoreColumn: $AgeCatScoreColumn$(if ($AgeCatScoreColumn -le 13) { ' (legacy format - no per-race data)' })"
Write-Host "  OverallScoreColumn: $OverallScoreColumn$(if ($OverallScoreColumn -le 13) { ' (legacy format - no per-race data)' })"
Write-Host "  Output:      $outputFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

$config      = Get-Content $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
$maxCounting = if ($config.maxCountingRaces) { [int]$config.maxCountingRaces } else { 4 }
$races       = Get-Content $racesFile -Raw -Encoding UTF8 | ConvertFrom-Json
$raceIds     = @($races | ForEach-Object { $_.id })

Write-Host "Series config" -ForegroundColor Yellow
Write-Host "  Max counting races: $maxCounting"
Write-Host "  Race IDs: $($raceIds -join ', ')"
Write-Host "  Individual categories: derived from parsed data (all recognised bands)"
Write-Host ""

$raceColMap    = Get-RaceColMap
$expectedRaces = @($raceColMap.Values)
$missingRaces  = $raceIds | Where-Object { $expectedRaces -notcontains $_ }
if ($missingRaces) {
    Write-Warning "Races in config not found in Excel column map: $($missingRaces -join ', ')"
    Write-Warning "Only these races will be processed: $($expectedRaces -join ', ')"
}

Write-Host "Opening Excel..." -ForegroundColor DarkGray
$excel = New-Object -ComObject Excel.Application
$excel.Visible       = $false
$excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Open($ExcelFile)

try {
    $sheetNames = @($wb.Sheets | ForEach-Object { $_.Name })
    Write-Host "Sheets: $($sheetNames -join ', ')" -ForegroundColor DarkGray

    $allRunners = [System.Collections.Generic.List[PSCustomObject]]@()

    # 1. Y2D - Age Category
    $ageCatSheetName = $sheetNames | Where-Object { $_ -imatch 'age.?category' } | Select-Object -First 1
    if (-not $ageCatSheetName) { throw "Could not find 'Y2D - Age Category' sheet" }

    Write-Host ""
    Write-Host "Parsing '$ageCatSheetName'..." -ForegroundColor DarkGray
    $ageCatSheet  = $wb.Sheets.Item($ageCatSheetName)
    $ageCatResult = @(Parse-AgeCategory -Sheet $ageCatSheet -MaxCounting $maxCounting -ScoreColumn $AgeCatScoreColumn -NoScore:$NoScore)

    $ageCatGroups = $ageCatResult | Group-Object CategoryId
    foreach ($g in ($ageCatGroups | Sort-Object Name)) {
        Write-Host ("  {0,-15} {1} runners" -f $g.Name, $g.Count)
    }
    Write-Host "  Total: $($ageCatResult.Count) runners across $($ageCatGroups.Count) age categories"
    foreach ($item in $ageCatResult) { $allRunners.Add($item) }

    # 2. Y2D - Ladies
    $ladiesSheetName = $sheetNames | Where-Object { $_ -imatch 'ladies' } | Select-Object -First 1
    if ($ladiesSheetName) {
        Write-Host ""
        Write-Host "Parsing '$ladiesSheetName'..." -ForegroundColor DarkGray
        $ladiesSheet  = $wb.Sheets.Item($ladiesSheetName)
        $ladiesResult = @(Parse-OverallSheet -Sheet $ladiesSheet -OverallCategoryId "female" -Sex "F" -MaxCounting $maxCounting -ScoreColumn $ScoreColumn -NoScore:$NoScore)
        Write-Host "  female: $($ladiesResult.Count) runners"
        foreach ($item in $ladiesResult) { $allRunners.Add($item) }
    } else {
        Write-Warning "No 'Y2D - Ladies' sheet found - 'female' category will be omitted"
    }

    # 3. Y2D - Men
    $menSheetName = $sheetNames | Where-Object { $_ -imatch '^y2d\s*-\s*men' } | Select-Object -First 1
    if ($menSheetName) {
        Write-Host ""
        Write-Host "Parsing '$menSheetName'..." -ForegroundColor DarkGray
        $menSheet  = $wb.Sheets.Item($menSheetName)
        $menResult = @(Parse-OverallSheet -Sheet $menSheet -OverallCategoryId "male" -Sex "M" -MaxCounting $maxCounting -ScoreColumn $ScoreColumn -NoScore:$NoScore)
        Write-Host "  male: $($menResult.Count) runners"
        foreach ($item in $menResult) { $allRunners.Add($item) }
    } else {
        Write-Warning "No 'Y2D - Men' sheet found - 'male' category will be omitted"
    }

    Write-Host ""
    Write-Host "Total runners across all categories: $($allRunners.Count)" -ForegroundColor Yellow

    # 4. Validation spot-checks
    Write-Host ""
    Write-Host "Validation" -ForegroundColor Yellow

    $errCount = 0

    $overallCats = @("female", "male", "overall")
    foreach ($catId in @("female", "male", "v35-female", "v40-male")) {
        $isOverallCat = $overallCats -contains $catId
        $catHasRaceCols = if ($isOverallCat) { $OverallScoreColumn -gt 13 } else { $AgeCatScoreColumn -gt 13 }
        $sample = @($allRunners | Where-Object { $_.CategoryId -eq $catId }) | Select-Object -First 3
        foreach ($runner in $sample) {
            if ($catHasRaceCols) {
                $countingResults = $runner.Results.Values | Where-Object { $_.counting -eq $true }
                $expectedTotal   = 0
                foreach ($cr in $countingResults) { $expectedTotal += $cr.points }

                if ($expectedTotal -ne $runner.Total) {
                    Write-Warning ("  {0} ({1}): computed total {2} != stored {3}" -f $runner.Name, $catId, $expectedTotal, $runner.Total)
                    $errCount++
                } else {
                    Write-Host ("  OK  {0,-30} cat={1,-15} pos={2,3}  total={3}" -f $runner.Name, $catId, $runner.Position, $runner.Total) -ForegroundColor Green
                }
            } else {
                Write-Host ("  OK  {0,-30} cat={1,-15} pos={2,3}  total={3}  (no per-race data in sheet)" -f $runner.Name, $catId, $runner.Position, $runner.Total) -ForegroundColor Green
            }
        }
    }

    $countColor = if ($errCount -eq 0) { "Green" } else { "Red" }
    Write-Host ("  {0} validation error(s)" -f $errCount) -ForegroundColor $countColor

    # 5. Build JSON
    Write-Host ""
    Write-Host "Building individual standings JSON..." -ForegroundColor DarkGray

    $standingsJson = Build-IndividualStandingsJson `
        -AllRunners    $allRunners `
        -RaceIds       $raceIds `
        -MaxCounting   $maxCounting `
        -IsProvisional ([bool]$Provisional)
    $standingsJsonStr = $standingsJson | ConvertTo-Json -Depth 10

    $totalCats    = $standingsJson.categories.Count
    $totalEntries = 0
    foreach ($c in $standingsJson.categories) { $totalEntries += $c.runners.Count }
    Write-Host "  $totalCats categories, $totalEntries total runner-category entries"

    # 6. Write output
    Write-Host ""
    if ($DryRun) {
        Write-Host "DRY RUN - file NOT written" -ForegroundColor Magenta
        Write-Host "  Would write: $outputFile"
        Write-Host ""
        Write-Host "JSON preview (first 40 lines):" -ForegroundColor Yellow
        ($standingsJsonStr -split "`n") | Select-Object -First 40 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    } else {
        if (Test-Path $outputFile) {
            Write-Warning "File already exists and will be overwritten: $outputFile"
        }
        $standingsJsonStr | Set-Content -Path $outputFile -Encoding UTF8
        Write-Host "Written: $outputFile" -ForegroundColor Green
    }

    Write-Host ""
    if ($errCount -gt 0) {
        Write-Host "Completed with $errCount validation warning(s) - review above." -ForegroundColor Yellow
    } else {
        Write-Host "Completed successfully." -ForegroundColor Green
    }

} finally {
    $wb.Close($false)
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb)    | Out-Null
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
}
