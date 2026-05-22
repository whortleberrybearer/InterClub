<#
.SYNOPSIS
    Sets the counting flag on each runner's race results in individual-standings.json.

.DESCRIPTION
    Applies the following rules to every runner in every category:

      1-3 races entered  ->  all results counting = true
      4 races entered    ->  the lowest-scoring race is set counting = false;
                             the remaining 3 are counting = true.
                             Ties (two races with equal lowest score) are broken
                             by setting the latest race in the season to false.

    The race order in the "races" array of the JSON file determines which race is
    considered latest for tie-breaking purposes.

.PARAMETER StandingsFile
    Full path to the individual-standings.json file to update in place.
    If omitted, derived from -Year, -Series and -ProjectRoot.

.PARAMETER Year
    Series year (e.g. 2025).  Defaults to 2025.  Ignored when -StandingsFile is supplied.

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "fell".  Ignored when -StandingsFile is supplied.

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the git root of the script location.
    Ignored when -StandingsFile is supplied.

.PARAMETER DryRun
    Parse and compute flags but do not write any files.

.EXAMPLE
    .\scripts\set-counting-flags.ps1 -Year 2025 -Series fell

.EXAMPLE
    .\scripts\set-counting-flags.ps1 -StandingsFile "C:\repos\InterClub\src\data\2025\fell\individual-standings.json"

.EXAMPLE
    .\scripts\set-counting-flags.ps1 -Year 2025 -Series fell -DryRun
#>

[CmdletBinding()]
param(
    [string]$StandingsFile,
    [string]$Year = "2025",
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "fell",
    [string]$ProjectRoot,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# --- Resolve file path --------------------------------------------------------

if (-not $StandingsFile) {
    if (-not $ProjectRoot) {
        $ProjectRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
        if (-not $ProjectRoot) { throw "Could not determine project root. Pass -ProjectRoot explicitly." }
    }
    $ProjectRoot   = [System.IO.Path]::GetFullPath($ProjectRoot)
    $StandingsFile = Join-Path $ProjectRoot "src\data\$Year\$Series\individual-standings.json"
}

$StandingsFile = [System.IO.Path]::GetFullPath($StandingsFile)
if (-not (Test-Path $StandingsFile)) { throw "Standings file not found: $StandingsFile" }

# --- Load JSON ----------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Counting-Flag Setter" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "File: $StandingsFile"
if ($DryRun) { Write-Host "*** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

$json     = Get-Content $StandingsFile -Raw -Encoding UTF8
$data     = $json | ConvertFrom-Json
$raceList = @($data.races)   # ordered list — index determines latest race for tie-breaking

# --- Apply counting rules to every runner -------------------------------------

$totalRunners  = 0
$totalModified = 0

foreach ($category in $data.categories) {
    foreach ($runner in $category.runners) {
        $totalRunners++

        # Collect the races this runner entered
        $raceEntries = @($runner.results.PSObject.Properties | ForEach-Object {
            [PSCustomObject]@{
                RaceId = $_.Name
                Points = [int]$_.Value.points
                Index  = $raceList.IndexOf($_.Name)   # position in season order
            }
        })

        $raceCount = $raceEntries.Count
        if ($raceCount -eq 0) { continue }

        if ($raceCount -le 3) {
            # 1, 2 or 3 races: all counting
            foreach ($entry in $raceEntries) {
                $runner.results.($entry.RaceId).counting = $true
            }
        } else {
            # 4 races: drop the lowest; ties broken by latest race in season
            $minPoints     = ($raceEntries | Measure-Object -Property Points -Minimum).Minimum
            $lowestEntries = @($raceEntries | Where-Object { $_.Points -eq $minPoints })

            # Among tied lowest scores, pick the one with the highest season index (latest)
            $nonCounting   = ($lowestEntries | Sort-Object Index -Descending | Select-Object -First 1).RaceId

            foreach ($entry in $raceEntries) {
                $isCounting = $entry.RaceId -ne $nonCounting
                if ($runner.results.($entry.RaceId).counting -ne $isCounting) {
                    $totalModified++
                }
                $runner.results.($entry.RaceId).counting = $isCounting
            }
        }
    }
}

Write-Host "Runners processed : $totalRunners"
Write-Host "Flags changed     : $totalModified"
Write-Host ""

# --- Write output -------------------------------------------------------------

$outputJson = $data | ConvertTo-Json -Depth 20

if ($DryRun) {
    Write-Host "DRY RUN - file NOT written." -ForegroundColor Magenta
    Write-Host "Would write: $StandingsFile"
} else {
    $outputJson | Set-Content -Path $StandingsFile -Encoding UTF8
    Write-Host "Written: $StandingsFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "Completed successfully." -ForegroundColor Green
