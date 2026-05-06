<#
.SYNOPSIS
    Parses an InterClub results Excel file and generates the required data files.

.DESCRIPTION
    Reads the Excel file and generates:
      - Individual results CSV         (from "Positions" tab)
      - Team results JSON              (from "Team Scorers" + "Team Positions" tabs)
      - Updated team standings JSON    (from "Season Totals" tab)

    The script prompts for any parameters not supplied on the command line.

.PARAMETER ExcelFile
    Path to the Excel results file.

.PARAMETER RaceId
    Race ID as used in the site data (e.g. "blackpool", "red-rose").

.PARAMETER Year
    Series year (e.g. 2026).

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER Provisional
    When set, writes provisional file names and marks standings as provisional.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\parse-results.ps1 -ExcelFile "C:\Downloads\blackpool 2026.xlsx" -RaceId blackpool -Year 2026

.EXAMPLE
    .\scripts\parse-results.ps1 -Provisional -DryRun
#>

[CmdletBinding()]
param(
    [string]$ExcelFile,
    [string]$RaceId,
    [string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$Provisional,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ─── Helpers ──────────────────────────────────────────────────────────────────

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
        "chorley*"   { return "chorley"   }
        "lytham*"    { return "lytham"    }
        "preston*"   { return "preston"   }
        "red rose*"  { return "red-rose"  }
        "thornton*"  { return "thornton"  }
        "wesham*"    { return "wesham"    }
        "guest*"     { return "Guest"     }
    }
    return $null
}

# Populated from config after it is loaded - maps Excel display names -> config category IDs
$script:categoryMap = @{}

function Build-CategoryMap {
    param($teamCategories)

    $map = @{}

    foreach ($cat in $teamCategories) {
        $lname = $cat.name.ToLower()

        # Exact config name always resolves to its own ID
        $map[$lname] = $cat.id

        # Pattern aliases so Excel display names resolve regardless of config naming convention
        if ($lname -match '\bopen\b') {
            $map["open"]  = $cat.id
            $map["team"]  = $cat.id
        }
        if ($lname -match 'ladies' -and $lname -notmatch 'vet') {
            $map["ladies"] = $cat.id
        }
        # Female-vets category: config may call it "FV40", "Lady Vets", etc.
        if ($lname -match '(fv.?40|lady.?vet|female.?vet)' -and $lname -notmatch '(50|60)') {
            $map["fv40"]       = $cat.id
            $map["lady vets"]  = $cat.id
        }
        if ($lname -match 'vets?' -and $lname -notmatch '(50|60|lady|female|fv)') {
            $map["vets"] = $cat.id
        }
        if ($lname -match '50') {
            $map["vet 50s"] = $cat.id
        }
        if ($lname -match '60') {
            $map["vet 60s"] = $cat.id
        }
    }

    return $map
}

function Get-TeamCategoryId {
    param([string]$Name)
    $key = $Name.Trim().ToLower()
    if ($script:categoryMap.ContainsKey($key)) { return $script:categoryMap[$key] }
    return $null
}

# ─── Sheet parsers ────────────────────────────────────────────────────────────

function Parse-Positions {
    param($Sheet)

    # Column layout (1-based):
    #  1=RaceNum  2=Pos  3=IC  4=Vet  5=V50  6=V60  7=Lady  8=FV40
    #  9=First  10=Last  11=Cat  12=Sex  13=(empty)  14=Club  15=Time

    # Find the first data row (runner number is numeric; rows 1-3 are headers/empty)
    $script:dataStartRow = -1
    for ($r = 2; $r -le 10; $r++) {
        if ($Sheet.Cells.Item($r, 1).Text -match '^\d+$') {
            $script:dataStartRow = $r
            break
        }
    }
    if ($script:dataStartRow -eq -1) { throw "Could not find first data row in Positions sheet" }

    $totalRows = $Sheet.UsedRange.Rows.Count

    for ($r = $script:dataStartRow; $r -le $totalRows; $r++) {
        $pos = $Sheet.Cells.Item($r, 2).Text.Trim()
        if ($pos -notmatch '^\d+$') { continue }   # skip blank / non-runner rows

        $raceNum = $Sheet.Cells.Item($r, 1).Text.Trim()
        $icPos   = $Sheet.Cells.Item($r, 3).Text.Trim()
        $first   = $Sheet.Cells.Item($r, 9).Text.Trim()
        $last    = $Sheet.Cells.Item($r, 10).Text.Trim()
        $cat     = $Sheet.Cells.Item($r, 11).Text.Trim()
        $sex     = $Sheet.Cells.Item($r, 12).Text.Trim()
        $club    = $Sheet.Cells.Item($r, 14).Text.Trim()
        $time    = $Sheet.Cells.Item($r, 15).Text.Trim()

        $clubId = Get-ClubId $club
        if ($null -eq $clubId) {
            Write-Warning "Row ${r}: unknown club '$club' - treating as Guest"
            $clubId = "Guest"
        }

        Write-Output ([PSCustomObject]@{
            ExcelRow = $r
            Position = [int]$pos
            IcPos    = if ($icPos -match '^\d+$') { [int]$icPos } else { $null }
            RaceNum  = if ($raceNum -match '^\d+$') { [int]$raceNum } else { $null }
            First    = $first
            Last     = $last
            Club     = $clubId
            Category = $cat
            Sex      = $sex
            Time     = $time
        })
    }
}

function Parse-TeamScorers {
    param($Sheet)

    # Header row: club name headers in columns 3+ (name column of each pair, pos column is one to the left)
    # Data rows: [scorer#][category?][pos1][name1][pos2][name2]...
    # Header row may not be row 1 — scan up to row 15 to find it.

    $totalCols = $Sheet.UsedRange.Columns.Count
    $totalRows = $Sheet.UsedRange.Rows.Count

    # Detect club columns — find first row with 2+ club name headers
    $headerRow = -1
    $clubCols  = [ordered]@{}   # club_name -> { PosCol; NameCol }
    for ($hr = 1; $hr -le [Math]::Min(15, $totalRows); $hr++) {
        $found = [ordered]@{}
        for ($c = 3; $c -le $totalCols; $c++) {
            $header = $Sheet.Cells.Item($hr, $c).Text.Trim()
            if ($header -and (Get-ClubId $header)) {
                $found[$header] = [PSCustomObject]@{ PosCol = $c - 1; NameCol = $c }
            }
        }
        if ($found.Count -ge 2) {
            $headerRow = $hr
            $clubCols  = $found
            break
        }
    }
    if ($clubCols.Count -eq 0) { throw "Could not detect club columns in Team Scorers sheet" }
    Write-Host "  Team Scorers header row: $headerRow  ($($clubCols.Count) clubs)" -ForegroundColor DarkGray

    $data = @{}       # category_id -> club_name -> List[PSCustomObject]
    $currentCat = $null

    for ($r = $headerRow + 1; $r -le $totalRows; $r++) {
        $scorerNum = $Sheet.Cells.Item($r, 1).Text.Trim()
        $catName   = $Sheet.Cells.Item($r, 2).Text.Trim()

        if ($catName) {
            $catId = Get-TeamCategoryId $catName
            if ($catId) {
                $currentCat = $catId
                $data[$catId] = @{}
                foreach ($cn in $clubCols.Keys) { $data[$catId][$cn] = [System.Collections.Generic.List[PSCustomObject]]@() }
            }
        }

        if (-not $currentCat) { continue }
        if ($scorerNum -notmatch '^\d+$') { continue }

        foreach ($clubName in $clubCols.Keys) {
            $cols       = $clubCols[$clubName]
            $scorerPos  = $Sheet.Cells.Item($r, $cols.PosCol).Text.Trim()
            $scorerName = $Sheet.Cells.Item($r, $cols.NameCol).Text.Trim()

            if (-not $scorerPos -or $scorerPos -notmatch '^\d+$') { continue }
            if ($scorerName -ieq "Incomplete Team" -or -not $scorerName) { continue }

            $data[$currentCat][$clubName].Add([PSCustomObject]@{
                Position = [int]$scorerPos
                Name     = $scorerName
            })
        }
    }

    return $data
}

function Parse-TeamPositions {
    param($Sheet)

    # Layout: two category tables side by side
    #   Left:  cols 1 (club name) + 2 (total)
    #   Right: cols 4 (club name) + 5 (total)
    # Category header rows have the category name in col 1 and/or col 4 with empty value cols.

    $totalRows = $Sheet.UsedRange.Rows.Count
    $data = @{}   # category_id -> ordered list of { Club; Total }

    $currentLeft  = $null
    $currentRight = $null

    for ($r = 1; $r -le $totalRows; $r++) {
        $c1 = $Sheet.Cells.Item($r, 1).Text.Trim()
        $c2 = $Sheet.Cells.Item($r, 2).Text.Trim()
        $c4 = $Sheet.Cells.Item($r, 4).Text.Trim()
        $c5 = $Sheet.Cells.Item($r, 5).Text.Trim()

        # Header row: category name present, value column empty
        $lCat = if ($c1 -and -not $c2) { Get-TeamCategoryId $c1 } else { $null }
        $rCat = if ($c4 -and -not $c5) { Get-TeamCategoryId $c4 } else { $null }

        if ($lCat -or $rCat) {
            if ($lCat) { $currentLeft  = $lCat; $data[$lCat] = [System.Collections.Generic.List[PSCustomObject]]@() }
            if ($rCat) { $currentRight = $rCat; $data[$rCat] = [System.Collections.Generic.List[PSCustomObject]]@() }
            continue
        }

        # Skip blank rows
        if (-not $c1 -and -not $c4) { continue }

        # Left data row
        if ($currentLeft -and $c1 -and $c2 -match '^\d+$') {
            $clubId = Get-ClubId $c1
            if ($clubId) {
                $data[$currentLeft].Add([PSCustomObject]@{ Club = $clubId; Total = [int]$c2 })
            }
        }

        # Right data row
        if ($currentRight -and $c4 -and $c5 -match '^\d+$') {
            $clubId = Get-ClubId $c4
            if ($clubId) {
                $data[$currentRight].Add([PSCustomObject]@{ Club = $clubId; Total = [int]$c5 })
            }
        }
    }

    return $data
}

function Parse-SeasonTotals {
    param($Sheet, [string]$RaceId)

    # Map race ID -> column header name used in Season Totals
    $raceHeaderMap = @{
        "blackpool" = "Blackpool"
        "lytham"    = "Lytham"
        "preston"   = "Preston"
        "thornton"  = "Thornton"
        "wesham"    = "Wesham"
        "chorley"   = "Chorley"
        "red-rose"  = "Red Rose"
    }

    $headerName = $raceHeaderMap[$RaceId.ToLower()]
    if (-not $headerName) {
        Write-Warning "Race '$RaceId' has no column mapping for Season Totals; skipping."
        return $null
    }

    # Find the race column — scan up to row 15 for the header row
    $totalCols = $Sheet.UsedRange.Columns.Count
    $totalRows = $Sheet.UsedRange.Rows.Count
    $raceCol   = -1
    $headerRow = -1
    for ($hr = 1; $hr -le [Math]::Min(15, $totalRows); $hr++) {
        for ($c = 1; $c -le $totalCols; $c++) {
            if ($Sheet.Cells.Item($hr, $c).Text.Trim() -ieq $headerName) {
                $raceCol   = $c
                $headerRow = $hr
                break
            }
        }
        if ($raceCol -ne -1) { break }
    }
    if ($raceCol -eq -1) {
        Write-Warning "Column '$headerName' not found in Season Totals header row; skipping."
        return $null
    }
    Write-Host "  Season Totals header row: $headerRow  (column $raceCol = '$headerName')" -ForegroundColor DarkGray

    $totals     = @{}   # category_id -> club_id -> points
    $currentCat = $null

    for ($r = $headerRow + 1; $r -le $totalRows; $r++) {
        $c1  = $Sheet.Cells.Item($r, 1).Text.Trim()
        $cRa = $Sheet.Cells.Item($r, $raceCol).Text.Trim()

        # Category header: known category name, race column empty
        if ($c1 -and -not $cRa) {
            $catId = Get-TeamCategoryId $c1
            if ($catId) {
                $currentCat = $catId
                $totals[$catId] = @{}
                continue
            }
        }

        if (-not $currentCat) { continue }

        # Data row: club name + points
        $clubId = Get-ClubId $c1
        if ($clubId -and $cRa -match '^\d+$') {
            $totals[$currentCat][$clubId] = [int]$cRa
        }
    }

    return $totals
}

# ─── Output builders ──────────────────────────────────────────────────────────

function Build-TeamResultsJson {
    param($TeamPositions, $TeamScorers, [string[]]$CategoryOrder)

    $numClubs = 7   # always 7 clubs in the series

    # Mapping from Team Scorers display name -> club ID
    $scorerClubMap = @{
        "Blackpool" = "blackpool"
        "Chorley"   = "chorley"
        "Lytham"    = "lytham"
        "Preston"   = "preston"
        "Red Rose"  = "red-rose"
        "Thornton"  = "thornton"
        "Wesham"    = "wesham"
    }

    $categories = [System.Collections.Generic.List[object]]@()

    foreach ($catId in $CategoryOrder) {
        if (-not $TeamPositions.ContainsKey($catId)) { continue }

        $orderedClubs = $TeamPositions[$catId]
        $clubs = [System.Collections.Generic.List[object]]@()

        for ($i = 0; $i -lt $orderedClubs.Count; $i++) {
            $entry    = $orderedClubs[$i]
            $position = $i + 1
            $points   = $numClubs - $i   # 7 for 1st … 1 for 7th

            # Collect scorers from Team Scorers sheet
            $scorers = [System.Collections.Generic.List[object]]@()
            if ($TeamScorers.ContainsKey($catId)) {
                foreach ($displayName in $scorerClubMap.Keys) {
                    if ($scorerClubMap[$displayName] -eq $entry.Club) {
                        if ($TeamScorers[$catId].ContainsKey($displayName)) {
                            foreach ($s in $TeamScorers[$catId][$displayName]) {
                                $scorers.Add([ordered]@{ position = $s.Position; name = $s.Name })
                            }
                        }
                        break
                    }
                }
            }

            $clubs.Add([ordered]@{
                position = $position
                points   = $points
                club     = $entry.Club
                total    = $entry.Total
                scorers  = $scorers.ToArray()
            })
        }

        $categories.Add([ordered]@{
            category = $catId
            clubs    = $clubs.ToArray()
        })
    }

    return [ordered]@{ categories = $categories.ToArray() }
}

function Update-TeamStandings {
    param(
        [string]$StandingsPath,
        [string]$RaceId,
        $PointsSource,         # hashtable: cat_id -> club_id -> points  (from Season Totals or Team Positions)
        [string[]]$AllClubs,
        [string[]]$AllCategories,
        [bool]$IsProvisional
    )

    # Load existing standings or start fresh
    if (Test-Path $StandingsPath) {
        $existing = Get-Content $StandingsPath -Raw | ConvertFrom-Json
        $races = [System.Collections.Generic.List[string]]@($existing.races)
    } else {
        $existing = $null
        $races    = [System.Collections.Generic.List[string]]@()
    }

    # Add race if not already present
    $raceIdx = $races.IndexOf($RaceId)
    if ($raceIdx -eq -1) {
        $races.Add($RaceId)
        $raceIdx = $races.Count - 1
    }

    $newCategories = [System.Collections.Generic.List[object]]@()

    foreach ($catId in $AllCategories) {
        # Find existing category entry
        $existingCat = if ($existing) {
            $existing.categories | Where-Object { $_.category -eq $catId } | Select-Object -First 1
        } else { $null }

        $clubs = [System.Collections.Generic.List[object]]@()

        foreach ($clubId in $AllClubs) {
            # Find existing club entry
            $existingClub = if ($existingCat) {
                $existingCat.clubs | Where-Object { $_.club -eq $clubId } | Select-Object -First 1
            } else { $null }

            # Build points array, extending to cover this race index
            $pointsArr = [System.Collections.Generic.List[object]]@()
            if ($existingClub -and $existingClub.points) {
                foreach ($p in $existingClub.points) { $pointsArr.Add($p) }
            }
            while ($pointsArr.Count -le $raceIdx) { $pointsArr.Add($null) }

            # Set this race's points
            $pts = $null
            if ($PointsSource.ContainsKey($catId) -and $PointsSource[$catId].ContainsKey($clubId)) {
                $pts = $PointsSource[$catId][$clubId]
            }
            $pointsArr[$raceIdx] = $pts

            # Recalculate total
            $total = 0
            foreach ($p in $pointsArr) { if ($null -ne $p) { $total += $p } }

            $clubs.Add([ordered]@{
                club       = $clubId
                points     = $pointsArr.ToArray()
                total      = $total
                tiebreaker = $null
            })
        }

        # Sort by total descending, assign positions
        $sorted = $clubs | Sort-Object { -$_.total }
        for ($i = 0; $i -lt $sorted.Count; $i++) {
            # Share position when tied
            $pos = $i + 1
            if ($i -gt 0 -and $sorted[$i].total -eq $sorted[$i - 1].total) {
                $pos = $sorted[$i - 1].position
            }
            $sorted[$i] = [ordered]@{
                position   = $pos
                club       = $sorted[$i].club
                points     = $sorted[$i].points
                total      = $sorted[$i].total
                tiebreaker = $null
            }
        }

        $newCategories.Add([ordered]@{
            category = $catId
            clubs    = @($sorted)
        })
    }

    return [ordered]@{
        provisional = $IsProvisional
        races       = $races.ToArray()
        categories  = $newCategories.ToArray()
    }
}

# ─── Main ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "InterClub Results Parser" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Collect missing parameters interactively
if (-not $ExcelFile) {
    $ExcelFile = Prompt-Value "Excel file path"
}
$ExcelFile = [System.IO.Path]::GetFullPath($ExcelFile)
if (-not (Test-Path $ExcelFile)) { throw "Excel file not found: $ExcelFile" }

if (-not $ProjectRoot) {
    $defaultRoot = Split-Path -Parent $PSScriptRoot
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path $ProjectRoot)) { throw "Project root not found: $ProjectRoot" }

if (-not $Year) {
    $Year = Prompt-Value "Series year (e.g. 2026)" "2026"
}

if (-not $RaceId) {
    $RaceId = Prompt-Value "Race ID (e.g. blackpool, red-rose)"
}
$RaceId = $RaceId.ToLower()

if (-not $PSBoundParameters.ContainsKey('Provisional')) {
    $provInput  = Read-Host "Mark as provisional? (y/N)"
    $Provisional = $provInput -match '^[yY]'
}

# Derived paths
$dataDir       = Join-Path $ProjectRoot "src\data\$Year\$Series"
$resultsDir    = Join-Path $dataDir "results"
$suffix        = if ($Provisional) { "-provisional" } else { "" }
$csvFile       = Join-Path $resultsDir "$RaceId$suffix.csv"
$teamsFile     = Join-Path $resultsDir "$RaceId-teams$suffix.json"
$standingsFile = Join-Path $dataDir "team-standings.json"
$configFile    = Join-Path $dataDir "config.json"
$clubsFile     = Join-Path $ProjectRoot "src\data\$Year\clubs.json"
$xlsxExt       = [System.IO.Path]::GetExtension($ExcelFile)
$xlsxDest      = Join-Path $resultsDir "$RaceId$xlsxExt"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Excel:       $ExcelFile"
Write-Host "  Year:        $Year  |  Series: $Series  |  Race: $RaceId"
Write-Host "  Provisional: $Provisional"
Write-Host "  CSV out:     $csvFile"
Write-Host "  Teams out:   $teamsFile"
Write-Host "  Standings:   $standingsFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# Warn if output files already exist
foreach ($outFile in @($csvFile, $teamsFile)) {
    if (Test-Path $outFile) {
        Write-Warning "File already exists and will be overwritten: $outFile"
    }
}

# Load config
$config       = Get-Content $configFile -Raw | ConvertFrom-Json
$categoryIds  = @($config.teamCategories | ForEach-Object { $_.id })
$clubs        = Get-Content $clubsFile -Raw | ConvertFrom-Json
$clubIds      = @($clubs | ForEach-Object { $_.id })

# Build dynamic category map from config so Excel display names resolve to correct config IDs
$script:categoryMap = Build-CategoryMap $config.teamCategories
Write-Host "Category map: $(($script:categoryMap.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ', ')" -ForegroundColor DarkGray

# Open Excel via COM
Write-Host "Opening Excel..." -ForegroundColor DarkGray
$excel = New-Object -ComObject Excel.Application
$excel.Visible       = $false
$excel.DisplayAlerts = $false
$wb = $excel.Workbooks.Open($ExcelFile)

try {

    # ── 1. Individual Results ──────────────────────────────────────────────
    Write-Host "Parsing Positions sheet..." -ForegroundColor DarkGray
    $posSheet = $wb.Sheets.Item("Positions")
    $results = @(Parse-Positions $posSheet)

    $icCount    = ($results | Where-Object { $null -ne $_.IcPos }).Count
    $guestCount = ($results | Where-Object { $null -eq $_.IcPos }).Count
    Write-Host "  $($results.Count) runners - $icCount IC, $guestCount guest"

    # Build CSV lines
    $csvLines = [System.Collections.Generic.List[string]]@(
        "position,ic_position,race_number,first_name,last_name,club,category,sex,time"
    )
    foreach ($r in $results) {
        $ic  = if ($null -ne $r.IcPos)  { $r.IcPos  } else { "" }
        $num = if ($null -ne $r.RaceNum) { $r.RaceNum } else { "" }
        $csvLines.Add("$($r.Position),$ic,$num,$($r.First),$($r.Last),$($r.Club),$($r.Category),$($r.Sex),$($r.Time)")
    }

    # ── 2. Validation - spot-check every 5 results ──────────────────────────
    Write-Host ""
    Write-Host "Validation" -ForegroundColor Yellow

    $errCount = 0
    for ($i = 0; $i -lt $results.Count; $i += 5) {
        $runner   = $results[$i]
        $exRow    = $script:dataStartRow + $i
        $exPos    = $posSheet.Cells.Item($exRow, 2).Text.Trim()
        $exFirst  = $posSheet.Cells.Item($exRow, 9).Text.Trim()
        $exLast   = $posSheet.Cells.Item($exRow, 10).Text.Trim()
        $exTime   = $posSheet.Cells.Item($exRow, 15).Text.Trim()

        $rowLabel = "Result #$($i + 1) (Excel row $exRow)"
        $ok = $true

        if ([string]$runner.Position -ne $exPos) {
            Write-Warning "  $rowLabel position: expected '$exPos', got '$($runner.Position)'"
            $errCount++; $ok = $false
        }
        if ($runner.First -ne $exFirst) {
            Write-Warning "  $rowLabel first name: expected '$exFirst', got '$($runner.First)'"
            $errCount++; $ok = $false
        }
        if ($runner.Last.Trim() -ne $exLast.Trim()) {
            Write-Warning "  $rowLabel last name: expected '$exLast', got '$($runner.Last)'"
            $errCount++; $ok = $false
        }
        if ($runner.Time -ne $exTime) {
            Write-Warning "  $rowLabel time: expected '$exTime', got '$($runner.Time)'"
            $errCount++; $ok = $false
        }

        if ($ok) {
            $color = "Green"
            Write-Host ("  OK  #{0,-4} pos={1}  {2} {3}  {4}" -f ($i+1), $runner.Position, $runner.First, $runner.Last.Trim(), $runner.Time) -ForegroundColor $color
        }
    }

    $countColor = if ($errCount -eq 0) { "Green" } else { "Red" }
    Write-Host ("  Total: {0} runners, {1} validation error(s)" -f $results.Count, $errCount) -ForegroundColor $countColor

    # ── 3. Team Scorers ────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "Parsing Team Scorers..." -ForegroundColor DarkGray
    $scorersSheet = $wb.Sheets.Item("Team Scorers")
    $teamScorers  = Parse-TeamScorers $scorersSheet
    Write-Host "  Categories: $($teamScorers.Keys -join ', ')"

    # ── 4. Team Positions ──────────────────────────────────────────────────
    Write-Host "Parsing Team Positions..." -ForegroundColor DarkGray
    $positionsSheet = $wb.Sheets.Item("Team Positions")
    $teamPositions  = Parse-TeamPositions $positionsSheet
    Write-Host "  Categories: $($teamPositions.Keys -join ', ')"

    # ── 5. Season Totals ───────────────────────────────────────────────────
    Write-Host "Parsing Season Totals..." -ForegroundColor DarkGray
    $totalsSheet  = $wb.Sheets.Item("Season Totals")
    $seasonTotals = Parse-SeasonTotals $totalsSheet $RaceId

    # Choose points source for standings
    if ($seasonTotals -and $seasonTotals.Count -gt 0) {
        Write-Host "  Categories: $($seasonTotals.Keys -join ', ')"
        $pointsSource = $seasonTotals

        # Cross-check Season Totals vs Team Positions order
        Write-Host "  Cross-checking Season Totals vs Team Positions..." -ForegroundColor DarkGray
        $crossErr = 0
        foreach ($catId in $teamPositions.Keys) {
            if (-not $seasonTotals.ContainsKey($catId)) { continue }
            $ordered = $teamPositions[$catId]
            for ($i = 0; $i -lt $ordered.Count; $i++) {
                $expectedPts = $ordered.Count - $i
                $clubId      = $ordered[$i].Club
                $actualPts   = if ($seasonTotals[$catId].ContainsKey($clubId)) { $seasonTotals[$catId][$clubId] } else { 0 }
                if ($expectedPts -ne $actualPts) {
                    Write-Warning "    Cross-check mismatch: $catId / $clubId expected $expectedPts pts (rank $($i+1)), got $actualPts from Season Totals"
                    $crossErr++
                }
            }
        }
        if ($crossErr -eq 0) {
            Write-Host "    All cross-checks passed" -ForegroundColor Green
        }
    } else {
        # Fall back to deriving points from Team Positions order
        Write-Host "  Season Totals unavailable - deriving points from Team Positions" -ForegroundColor Yellow
        $pointsSource = @{}
        foreach ($catId in $teamPositions.Keys) {
            $pointsSource[$catId] = @{}
            $ordered = $teamPositions[$catId]
            for ($i = 0; $i -lt $ordered.Count; $i++) {
                $pointsSource[$catId][$ordered[$i].Club] = $ordered.Count - $i
            }
        }
    }

    # ── 6. Build output JSON ───────────────────────────────────────────────
    Write-Host ""
    Write-Host "Building team results JSON..." -ForegroundColor DarkGray
    $teamsJson    = Build-TeamResultsJson $teamPositions $teamScorers $categoryIds
    $teamsJsonStr = $teamsJson | ConvertTo-Json -Depth 10

    Write-Host "Building team standings JSON..." -ForegroundColor DarkGray
    $newStandings    = Update-TeamStandings `
        -StandingsPath  $standingsFile `
        -RaceId         $RaceId `
        -PointsSource   $pointsSource `
        -AllClubs       $clubIds `
        -AllCategories  $categoryIds `
        -IsProvisional  ([bool]$Provisional)
    $standingsJsonStr = $newStandings | ConvertTo-Json -Depth 10

    # ── 7. Write files ─────────────────────────────────────────────────────
    Write-Host ""
    if ($DryRun) {
        Write-Host "DRY RUN - files NOT written" -ForegroundColor Magenta
        $rowCount = $csvLines.Count - 1
        Write-Host "  Would write: $csvFile  ($rowCount data rows)"
        Write-Host "  Would write: $teamsFile"
        Write-Host "  Would write: $standingsFile"
        Write-Host "  Would copy:  $ExcelFile -> $xlsxDest"
        Write-Host ""
        Write-Host "CSV preview (first 6 lines):" -ForegroundColor Yellow
        $csvLines | Select-Object -First 6 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
    } else {
        if (-not (Test-Path $resultsDir)) {
            New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
        }

        ($csvLines -join "`n") | Set-Content -Path $csvFile -Encoding UTF8 -NoNewline
        Write-Host "Written: $csvFile" -ForegroundColor Green

        $teamsJsonStr | Set-Content -Path $teamsFile -Encoding UTF8
        Write-Host "Written: $teamsFile" -ForegroundColor Green

        $standingsJsonStr | Set-Content -Path $standingsFile -Encoding UTF8
        Write-Host "Written: $standingsFile" -ForegroundColor Green

        Copy-Item -Path $ExcelFile -Destination $xlsxDest -Force
        Write-Host "Copied:  $xlsxDest" -ForegroundColor Green
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
