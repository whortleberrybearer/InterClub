<#
.SYNOPSIS
    Correlates series runners.json entries to the global runners.json registry,
    creating new global runner entries as needed.

.DESCRIPTION
    For each entry in the series runners.json that has no runnerId:
      - Looks for an exact match in global runners.json by firstName, lastName,
        club, sex, and ageCategory.
      - If an exact match is found, sets runnerId on the series runner.
      - If possible (partial) matches are found (same name, different club/sex/ageCategory),
        reports them to the user and skips that runner.
      - If no match at all, creates a new global runner entry (ids start at 10000)
        and links the series runner via runnerId.
    Writes the updated series runners.json and global runners.json.

.PARAMETER Year
    Series year (e.g. 2026).

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\correlate-global-runners.ps1 -Year 2026 -Series road-gp

.EXAMPLE
    .\scripts\correlate-global-runners.ps1 -Year 2026 -DryRun
#>

[CmdletBinding()]
param(
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

# --- Helpers ------------------------------------------------------------------

function Normalize-Name {
    param([string]$Name)
    return $Name.Trim().ToLower()
}

function Names-Match {
    param([string]$First1, [string]$Last1, [string]$First2, [string]$Last2)
    return (Normalize-Name $First1) -eq (Normalize-Name $First2) -and
           (Normalize-Name $Last1)  -eq (Normalize-Name $Last2)
}

function Exact-Match {
    param($SeriesRunner, $GlobalRunner)
    return (Names-Match $SeriesRunner.firstName $SeriesRunner.lastName $GlobalRunner.firstName $GlobalRunner.lastName) -and
           ($SeriesRunner.club        -ieq $GlobalRunner.club) -and
           ($SeriesRunner.sex         -ieq $GlobalRunner.sex) -and
           ($SeriesRunner.ageCategory -ieq $GlobalRunner.ageCategory)
}

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Global Runner Correlator" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Derived paths
$globalRunnersFile = Join-Path $ProjectRoot "src\data\runners.json"
$seriesDir         = Join-Path $ProjectRoot "src\data\$Year\$Series"
$seriesRunnersFile = Join-Path $seriesDir "runners.json"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Year:           $Year  |  Series: $Series"
Write-Host "  Global runners: $globalRunnersFile"
Write-Host "  Series runners: $seriesRunnersFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# --- Load data ----------------------------------------------------------------

if (-not (Test-Path $globalRunnersFile)) { throw "Global runners.json not found: $globalRunnersFile" }
if (-not (Test-Path $seriesRunnersFile)) { throw "Series runners.json not found: $seriesRunnersFile" }

$globalRunners = [System.Collections.Generic.List[object]]::new()
foreach ($r in (Get-Content $globalRunnersFile -Raw -Encoding UTF8 | ConvertFrom-Json)) { $globalRunners.Add($r) }

$seriesRunners = [System.Collections.Generic.List[object]]::new()
foreach ($r in (Get-Content $seriesRunnersFile -Raw -Encoding UTF8 | ConvertFrom-Json)) { $seriesRunners.Add($r) }

Write-Host "Loaded $($globalRunners.Count) global runner(s) and $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray
Write-Host ""

# Determine next available global ID (minimum 10000)
$nextGlobalId = 10000
foreach ($r in $globalRunners) {
    $rid = [int]($r.id)
    if ($rid -ge $nextGlobalId) { $nextGlobalId = $rid + 1 }
}

# --- Correlate ----------------------------------------------------------------

Write-Host "Correlating runners..." -ForegroundColor Yellow
Write-Host ""

$matched        = 0
$created        = 0
$skipped        = 0   # already has runnerId
$needsReview    = 0

foreach ($sr in $seriesRunners) {
    # Skip runners already linked
    if ($null -ne $sr.runnerId -and $sr.runnerId -ne "") {
        $skipped++
        continue
    }

    $exactMatches    = [System.Collections.Generic.List[object]]::new()
    $possibleMatches = [System.Collections.Generic.List[object]]::new()

    foreach ($gr in $globalRunners) {
        if (Exact-Match $sr $gr) {
            $exactMatches.Add($gr)
        } elseif (Names-Match $sr.firstName $sr.lastName $gr.firstName $gr.lastName) {
            $possibleMatches.Add($gr)
        }
    }

    if ($exactMatches.Count -gt 0) {
        # Use first exact match (duplicates in global file would be a data problem)
        $linked = $exactMatches[0]
        $sr | Add-Member -NotePropertyName runnerId -NotePropertyValue ([int]$linked.id) -Force
        Write-Host "  = Matched:  id=$($sr.id)  $($sr.firstName) $($sr.lastName)  -> global id=$($linked.id)" -ForegroundColor DarkGray
        $matched++

    } elseif ($possibleMatches.Count -gt 0) {
        # Same name but something differs -- report and leave for manual review
        Write-Host ""
        Write-Host "  ? Possible match(es) for series id=$($sr.id)  $($sr.firstName) $($sr.lastName)  (club=$($sr.club) sex=$($sr.sex) ageCategory=$($sr.ageCategory)):" -ForegroundColor Yellow
        foreach ($pm in $possibleMatches) {
            $ageCatYear = if ($pm.PSObject.Properties["ageCategoryYear"]) { " ageCategoryYear=$($pm.ageCategoryYear)" } else { "" }
            Write-Host "      global id=$($pm.id)  club=$($pm.club)  sex=$($pm.sex)  ageCategory=$($pm.ageCategory)$ageCatYear" -ForegroundColor Yellow
        }
        Write-Host "    -> Skipped. Set runnerId manually or update the series runner to match." -ForegroundColor Yellow
        Write-Host ""
        $needsReview++

    } else {
        # No match at all -- create new global runner
        $newGlobal = [ordered]@{
            id              = $nextGlobalId
            firstName       = $sr.firstName
            lastName        = $sr.lastName
            club            = $sr.club
            sex             = $sr.sex
            ageCategory     = $sr.ageCategory
            ageCategoryYear = [int]$Year
        }
        $globalRunners.Add($newGlobal)
        $sr | Add-Member -NotePropertyName runnerId -NotePropertyValue $nextGlobalId -Force
        Write-Host "  + Created:  global id=$nextGlobalId  $($sr.firstName) $($sr.lastName)  club=$($sr.club)  sex=$($sr.sex)  ageCategory=$($sr.ageCategory)  ageCategoryYear=$Year" -ForegroundColor Green
        $nextGlobalId++
        $created++
    }
}

Write-Host ""
$summaryColor = if ($needsReview -gt 0) { "Yellow" } else { "Green" }
Write-Host "Correlation complete: $matched matched, $created created, $skipped already linked, $needsReview need manual review" -ForegroundColor $summaryColor

# --- Write files --------------------------------------------------------------

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - files NOT written" -ForegroundColor Magenta
    Write-Host "  Would update: $globalRunnersFile  ($($globalRunners.Count) entries)"
    Write-Host "  Would update: $seriesRunnersFile  ($($seriesRunners.Count) entries)"
} else {
    if ($created -gt 0) {
        $globalRunners | ConvertTo-Json -Depth 5 | Set-Content -Path $globalRunnersFile -Encoding UTF8
        Write-Host "Updated: $globalRunnersFile  ($($globalRunners.Count) entries)" -ForegroundColor Green
    } else {
        Write-Host "No new global runners -- runners.json unchanged." -ForegroundColor DarkGray
    }

    if ($matched -gt 0 -or $created -gt 0) {
        $seriesRunners | ConvertTo-Json -Depth 5 | Set-Content -Path $seriesRunnersFile -Encoding UTF8
        Write-Host "Updated: $seriesRunnersFile  ($($seriesRunners.Count) entries)" -ForegroundColor Green
    } else {
        Write-Host "No series runner changes -- series runners.json unchanged." -ForegroundColor DarkGray
    }
}

Write-Host ""
if ($needsReview -gt 0) {
    Write-Host "Completed with $needsReview runner(s) needing manual review -- see above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
