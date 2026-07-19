<#
.SYNOPSIS
    Correlates results CSV rows to series runners.json entries, creating new
    runner entries as needed, and writes an updated CSV with series_runner_id
    populated.

.DESCRIPTION
    For each row in the results CSV that is not a Guest:
      - If a bib (race_number) is present, looks up the runner by the 'number'
        field in runners.json and validates the name matches.
      - If no bib is present (or bib lookup yields no result), looks up by
        firstName + lastName + club + ageCategory.
      - A partial match (name + club match but ageCategory differs) is flagged
        as an inconsistency warning; the runner is still matched.
      - If no match is found at all, a new series runner entry is created.
    Writes the updated CSV (with series_runner_id appended) and the updated
    series runners.json.

.PARAMETER CsvFile
    Path to the results CSV file to process.

.PARAMETER Year
    Series year (e.g. 2026).

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\correlate-runners.ps1 -CsvFile "src\data\2026\road-gp\results\blackpool.csv" -Year 2026

.EXAMPLE
    .\scripts\correlate-runners.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$CsvFile,
    [Parameter(Mandatory)][string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not $ProjectRoot) {
    $ProjectRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $ProjectRoot) { throw "ProjectRoot not supplied and could not be resolved from git" }
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$CsvFile     = [System.IO.Path]::GetFullPath($CsvFile)
if (-not (Test-Path $CsvFile)) { throw "CSV file not found: $CsvFile" }

# --- Helpers ------------------------------------------------------------------

function Normalize-Name {
    param([string]$Name)
    return $Name.Trim().ToLower()
}

function Names-Match {
    param([string]$CsvFirst, [string]$CsvLast, [string]$RunnerFirst, [string]$RunnerLast)
    return (Normalize-Name $CsvFirst) -eq (Normalize-Name $RunnerFirst) -and
           (Normalize-Name $CsvLast)  -eq (Normalize-Name $RunnerLast)
}

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Runner Correlator" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Derived paths
$seriesDir         = Join-Path $ProjectRoot "src\data\$Year\$Series"
$seriesRunnersFile = Join-Path $seriesDir "runners.json"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  CSV:            $CsvFile"
Write-Host "  Year:           $Year  |  Series: $Series"
Write-Host "  Series runners: $seriesRunnersFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# --- Load existing runner data ------------------------------------------------

$seriesRunners = [System.Collections.Generic.List[object]]::new()
if (Test-Path $seriesRunnersFile) {
    foreach ($r in (Get-Content $seriesRunnersFile -Raw -Encoding UTF8 | ConvertFrom-Json)) { $seriesRunners.Add($r) }
}

Write-Host "Loaded $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray

# Build lookup indexes
$bibIndex  = @{}   # bib (int)          -> series runner object
$nameIndex = @{}   # "first|last|club"  -> list of series runner objects

foreach ($r in $seriesRunners) {
    if ($null -ne $r.number -and $r.number -ne "") {
        $bib = [int]$r.number
        if (-not $bibIndex.ContainsKey($bib)) { $bibIndex[$bib] = $r }
    }
    $nFirst  = Normalize-Name $r.firstName
    $nLast   = Normalize-Name $r.lastName
    $nClub   = $r.club.Trim().ToLower()
    $nameKey = $nFirst + "|" + $nLast + "|" + $nClub
    if (-not $nameIndex.ContainsKey($nameKey)) { $nameIndex[$nameKey] = [System.Collections.Generic.List[object]]::new() }
    $nameIndex[$nameKey].Add($r)
}

# Determine next available series ID (starts at 100 if empty, else max+1)
$nextSeriesId = 100
foreach ($r in $seriesRunners) {
    $rid = [int]($r.id)
    if ($rid -ge $nextSeriesId) { $nextSeriesId = $rid + 1 }
}

# --- Parse CSV ----------------------------------------------------------------

Write-Host "Parsing CSV..." -ForegroundColor DarkGray

$rawLines = Get-Content $CsvFile -Encoding UTF8
if ($rawLines.Count -lt 1) { throw "CSV file is empty" }

$header     = $rawLines[0]
$dataLines  = $rawLines[1..($rawLines.Count - 1)]
$headerCols = $header -split ','

# Strip existing series_runner_id column if present
$existingIdCol = $headerCols | Where-Object { $_ -ieq "series_runner_id" }
if ($existingIdCol) {
    Write-Host "  Existing series_runner_id column detected -- values will be replaced." -ForegroundColor Yellow
}

# Find column indices
function Get-ColIndex {
    param([string[]]$Cols, [string]$Name)
    for ($i = 0; $i -lt $Cols.Count; $i++) {
        if ($Cols[$i].Trim() -ieq $Name) { return $i }
    }
    return -1
}

$colRaceNum  = Get-ColIndex $headerCols "race_number"
$colFirst    = Get-ColIndex $headerCols "first_name"
$colLast     = Get-ColIndex $headerCols "last_name"
$colClub     = Get-ColIndex $headerCols "club"
$colCat      = Get-ColIndex $headerCols "age_category"
$colSex      = Get-ColIndex $headerCols "sex"
$colSeriesId = Get-ColIndex $headerCols "series_runner_id"

if ($colFirst -lt 0 -or $colLast -lt 0) {
    throw "CSV must have first_name and last_name columns"
}

Write-Host "  race_number col: $colRaceNum | first_name: $colFirst | last_name: $colLast" -ForegroundColor DarkGray

# --- Correlate each row -------------------------------------------------------

Write-Host ""
Write-Host "Correlating runners..." -ForegroundColor Yellow

$matched          = 0
$created          = 0
$nameMismatch     = 0
$catMismatch      = 0   # partial match: name+club match, category differs
$skippedGuests    = 0
$updatedLines     = [System.Collections.Generic.List[string]]@()

foreach ($line in $dataLines) {
    if ($line.Trim() -eq "") {
        $updatedLines.Add($line)
        continue
    }

    $cols = $line -split ','

    $bibRaw = if ($colRaceNum -ge 0 -and $colRaceNum -lt $cols.Count) { $cols[$colRaceNum].Trim() } else { "" }
    $first  = if ($colFirst   -ge 0 -and $colFirst   -lt $cols.Count) { $cols[$colFirst].Trim()   } else { "" }
    $last   = if ($colLast    -ge 0 -and $colLast    -lt $cols.Count) { $cols[$colLast].Trim()    } else { "" }
    $club   = if ($colClub    -ge 0 -and $colClub    -lt $cols.Count) { $cols[$colClub].Trim()    } else { "" }
    $cat    = if ($colCat     -ge 0 -and $colCat     -lt $cols.Count) { $cols[$colCat].Trim()     } else { "" }
    $sex    = if ($colSex     -ge 0 -and $colSex     -lt $cols.Count) { $cols[$colSex].Trim()     } else { "" }

    $seriesId = $null
    $isGuest  = $club -ieq "Guest"

    if ($isGuest) {
        $skippedGuests++
    } else {
        $resolved = $null

        # --- Step 1: try bib lookup -------------------------------------------
        if ($bibRaw -match '^\d+$') {
            $bib = [int]$bibRaw
            if ($bibIndex.ContainsKey($bib)) {
                $found = $bibIndex[$bib]
                if (-not (Names-Match $first $last $found.firstName $found.lastName)) {
                    Write-Warning "Bib $bib name mismatch: CSV='$first $last'  runners.json='$($found.firstName) $($found.lastName)'"
                    $nameMismatch++
                }
                $resolved = $found
            }
        }

        # --- Step 2: try name + club + ageCategory lookup ---------------------
        if (-not $resolved) {
            $normFirst = Normalize-Name $first
            $normLast  = Normalize-Name $last
            $normClub  = $club.ToLower()
            $nameKey   = $normFirst + "|" + $normLast + "|" + $normClub
            if ($nameIndex.ContainsKey($nameKey)) {
                $candidates = @($nameIndex[$nameKey])

                # Prefer exact ageCategory match
                $exactCat = @($candidates | Where-Object { $_.ageCategory -ieq $cat })
                if ($exactCat.Count -gt 0) {
                    $resolved = $exactCat[0]
                } else {
                    # Partial match: name + club found but ageCategory differs
                    $resolved = $candidates[0]
                    $catMismatch++
                    $resId  = $resolved.id
                    $resCat = $resolved.ageCategory
                    $warnMsg = ("Category mismatch for {0} {1} ({2}): CSV={3}  runners.json={4} [id={5}]" -f $first, $last, $club, $cat, $resCat, $resId)
                    Write-Warning $warnMsg
                }
            }
        }

        # --- Step 3: create new series runner ---------------------------------
        if (-not $resolved) {
            $newRunner = [ordered]@{
                id          = $nextSeriesId
                firstName   = $first
                lastName    = $last
                club        = $club
                sex         = $sex
                ageCategory = $cat
            }
            if ($bibRaw -match '^\d+$') {
                $newRunner["number"] = [int]$bibRaw
                $bibIndex[[int]$bibRaw] = $newRunner
            }
            $seriesRunners.Add($newRunner)
            $normFirst = Normalize-Name $first
            $normLast  = Normalize-Name $last
            $normClub  = $club.ToLower()
            $nameKey   = $normFirst + "|" + $normLast + "|" + $normClub
            if (-not $nameIndex.ContainsKey($nameKey)) { $nameIndex[$nameKey] = [System.Collections.Generic.List[object]]::new() }
            $nameIndex[$nameKey].Add($newRunner)

            $resolved = $newRunner
            $nextSeriesId++
            $created++
            $newId = $newRunner.id
            if ($bibRaw -match '^\d+$') {
                Write-Host ("  + New runner: id={0}  bib={1}  {2} {3}  ({4} {5})" -f $newId, $bibRaw, $first, $last, $club, $cat) -ForegroundColor Green
            } else {
                Write-Host ("  + New runner: id={0}  {1} {2}  ({3} {4})" -f $newId, $first, $last, $club, $cat) -ForegroundColor Green
            }
        } else {
            $matched++
        }

        $seriesId = $resolved.id
    }

    # Rebuild the CSV line with series_runner_id appended (or replaced)
    $outputCols = [System.Collections.Generic.List[string]]@($cols)
    if ($colSeriesId -ge 0) {
        $outputCols.RemoveAt($colSeriesId)
    }
    $idValue = if ($null -ne $seriesId) { [string]$seriesId } else { "" }
    $outputCols.Add($idValue)
    $updatedLines.Add($outputCols -join ",")
}

Write-Host ""
$hasWarnings  = ($nameMismatch -gt 0) -or ($catMismatch -gt 0)
$summaryColor = if ($hasWarnings) { "Yellow" } else { "Green" }
Write-Host "Correlation complete: $matched matched, $created created, $skippedGuests guest(s) skipped, $nameMismatch name mismatch(es), $catMismatch category mismatch(es)" -ForegroundColor $summaryColor

# --- Build output header -------------------------------------------------------

$outputHeaderCols = [System.Collections.Generic.List[string]]@($headerCols)
if ($colSeriesId -ge 0) { $outputHeaderCols.RemoveAt($colSeriesId) }
$outputHeaderCols.Add("series_runner_id")
$outputHeader = $outputHeaderCols -join ","

$csvOutput = ([System.Collections.Generic.List[string]]@($outputHeader) + $updatedLines) -join "`n"

# --- Write files --------------------------------------------------------------

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - files NOT written" -ForegroundColor Magenta
    Write-Host "  Would update: $CsvFile  (series_runner_id column added)"
    Write-Host "  Would update: $seriesRunnersFile  ($($seriesRunners.Count) entries)"
    Write-Host ""
    Write-Host "CSV preview (first 4 data lines):" -ForegroundColor Yellow
    ($csvOutput -split "`n") | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
} else {
    $csvOutput | Set-Content -Path $CsvFile -Encoding UTF8 -NoNewline
    Write-Host "Updated: $CsvFile" -ForegroundColor Green

    if ($created -gt 0 -or $seriesRunners.Count -gt 0) {
        $seriesJson = $seriesRunners | ConvertTo-Json -Depth 5
        $seriesJson | Set-Content -Path $seriesRunnersFile -Encoding UTF8
        Write-Host "Updated: $seriesRunnersFile  ($($seriesRunners.Count) entries)" -ForegroundColor Green
    } else {
        Write-Host "No new runners -- series runners.json unchanged." -ForegroundColor DarkGray
    }
}

Write-Host ""
if ($nameMismatch -gt 0 -or $catMismatch -gt 0) {
    Write-Host "Completed with warnings -- review mismatches above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
