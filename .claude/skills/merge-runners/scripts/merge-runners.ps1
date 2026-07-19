<#
.SYNOPSIS
    Merges duplicate global runner identities in src/data/runners.json.

.DESCRIPTION
    Two modes:

    Search mode (-Search) finds candidate global runners by last name so a
    master id can be chosen. No files are modified.

    Merge mode (-MasterId + -MergeIds) repoints every series-local
    runners.json entry (across all years/series) that links to a MergeIds
    entry so it links to MasterId instead, then deletes the MergeIds
    entries from the global registry. Series-local ids, CSV
    series_runner_id values, and awards/standings seriesRunnerId values
    are untouched -- they reference the series-local id, not the global
    id, so they keep working automatically once the series-local entry's
    runnerId is repointed.

.PARAMETER Search
    Last-name substring to search the global registry for merge candidates.

.PARAMETER MasterId
    The global runner id that survives the merge.

.PARAMETER MergeIds
    One or more global runner ids to merge into MasterId and delete.

.PARAMETER ProjectRoot
    Root of the InterClub repository. Defaults to the parent of the scripts folder.

.PARAMETER DryRun
    Report what would change but do not write any files.

.EXAMPLE
    .\scripts\merge-runners.ps1 -Search Smith

.EXAMPLE
    .\scripts\merge-runners.ps1 -MasterId 10 -MergeIds 50 -DryRun

.EXAMPLE
    .\scripts\merge-runners.ps1 -MasterId 10 -MergeIds 50,60
#>

[CmdletBinding()]
param(
    [string]$Search,
    [int]$MasterId,
    [int[]]$MergeIds,
    [string]$ProjectRoot,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not $ProjectRoot) {
    $ProjectRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $ProjectRoot) { throw "ProjectRoot not supplied and could not be resolved from git" }
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)

$globalRunnersFile = Join-Path $ProjectRoot "src\data\runners.json"
if (-not (Test-Path $globalRunnersFile)) { throw "Global runners.json not found: $globalRunnersFile" }

Write-Host ""
Write-Host "InterClub Runner Merger" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

$globalRunners = [System.Collections.Generic.List[object]]::new()
foreach ($r in (Get-Content $globalRunnersFile -Raw -Encoding UTF8 | ConvertFrom-Json)) { $globalRunners.Add($r) }

function Format-Runner {
    param($R)
    $year = if ($R.PSObject.Properties["ageCategoryYear"]) { " ageCategoryYear=$($R.ageCategoryYear)" } else { "" }
    "id=$($R.id)  $($R.firstName) $($R.lastName)  club=$($R.club)  sex=$($R.sex)  ageCategory=$($R.ageCategory)$year"
}

# --- Search mode ---------------------------------------------------------------

if ($Search) {
    $matches = @($globalRunners | Where-Object { $_.lastName -ilike "*$Search*" -or $_.firstName -ilike "*$Search*" })
    if ($matches.Count -eq 0) {
        Write-Host "No global runners match '$Search'." -ForegroundColor Yellow
        return
    }
    Write-Host "Candidates matching '$Search':" -ForegroundColor Yellow
    foreach ($m in ($matches | Sort-Object lastName, firstName)) {
        Write-Host "  $(Format-Runner $m)"
    }
    Write-Host ""
    Write-Host "Choose a MasterId and one or more MergeIds, then re-run with -MasterId/-MergeIds." -ForegroundColor DarkGray
    return
}

# --- Merge mode ------------------------------------------------------------------

if (-not $MasterId -or -not $MergeIds -or $MergeIds.Count -eq 0) {
    throw "Either -Search <name>, or both -MasterId <id> and -MergeIds <id[,id...]>, are required."
}
if ($MergeIds -contains $MasterId) { throw "MasterId $MasterId cannot also appear in MergeIds." }

$master = $globalRunners | Where-Object { [int]$_.id -eq $MasterId } | Select-Object -First 1
if (-not $master) { throw "MasterId $MasterId not found in $globalRunnersFile" }

$mergeSet = [System.Collections.Generic.HashSet[int]]::new([int[]]$MergeIds)
$mergeRunners = @($globalRunners | Where-Object { $mergeSet.Contains([int]$_.id) })
$foundIds = [System.Collections.Generic.HashSet[int]]::new([int[]]($mergeRunners | ForEach-Object { [int]$_.id }))
foreach ($id in $MergeIds) {
    if (-not $foundIds.Contains($id)) { throw "MergeId $id not found in $globalRunnersFile" }
}

Write-Host "Master:" -ForegroundColor Yellow
Write-Host "  $(Format-Runner $master)"
Write-Host "Merging into master and deleting:" -ForegroundColor Yellow
foreach ($m in $mergeRunners) { Write-Host "  $(Format-Runner $m)" }
if ($DryRun) { Write-Host ""; Write-Host "*** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# --- Repoint series-local runners.json files ------------------------------------

$seriesRunnerFiles = Get-ChildItem -Path (Join-Path $ProjectRoot "src\data") -Recurse -Filter "runners.json" |
    Where-Object { $_.FullName -ne $globalRunnersFile }

$totalRepointed = 0
$touchedFiles = 0

foreach ($file in $seriesRunnerFiles) {
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($r in (Get-Content $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json)) { $entries.Add($r) }

    $fileRepointed = 0
    foreach ($e in $entries) {
        if ($null -ne $e.runnerId -and $e.runnerId -ne "" -and $mergeSet.Contains([int]$e.runnerId)) {
            $oldId = $e.runnerId
            $e.runnerId = $MasterId
            Write-Host "  $($file.FullName.Substring($ProjectRoot.Length + 1)):  series id=$($e.id) $($e.firstName) $($e.lastName)  runnerId $oldId -> $MasterId" -ForegroundColor DarkGray
            $fileRepointed++
        }
    }

    if ($fileRepointed -gt 0) {
        $totalRepointed += $fileRepointed
        $touchedFiles++
        if (-not $DryRun) {
            $entries | ConvertTo-Json -Depth 5 | Set-Content -Path $file.FullName -Encoding UTF8
        }
    }
}

# --- Remove merged entries from global registry ---------------------------------

$remaining = $globalRunners | Where-Object { -not $mergeSet.Contains([int]$_.id) }

if (-not $DryRun) {
    $remaining | ConvertTo-Json -Depth 5 | Set-Content -Path $globalRunnersFile -Encoding UTF8
}

Write-Host ""
Write-Host "Repointed $totalRepointed series-local link(s) across $touchedFiles file(s)." -ForegroundColor Green
Write-Host "Removed $($mergeRunners.Count) merged entr$(if ($mergeRunners.Count -eq 1) { 'y' } else { 'ies' }) from global runners.json." -ForegroundColor Green
if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN - no files were written." -ForegroundColor Magenta
} else {
    Write-Host ""
    Write-Host "NOTE: ConvertTo-Json reformats whole files (4-space indent). Reformat touched files back to the repo's 2-space style before committing." -ForegroundColor Yellow
}
