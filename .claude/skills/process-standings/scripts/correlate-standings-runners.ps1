<#
.SYNOPSIS
    Assigns seriesRunnerId to runner entries in individual-standings.json.

.DESCRIPTION
    For each runner in individual-standings.json without a seriesRunnerId:
      - Splits the runner name into first/last on the final space.
      - Looks for an exact match in series runners.json by firstName, lastName, club, and category.
      - If found, sets seriesRunnerId on the standings entry.
      - If name matches but club/sex differs, reports for review and skips.
      - If no match, reports failure and skips.
    Does not create new runner entries. Writes updated individual-standings.json in-place.

.PARAMETER Year
    Series year (e.g. 2025).

.PARAMETER Series
    Series name: "road-gp" or "fell". Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.

.PARAMETER DryRun
    Parse and match everything but do not write any files.

.EXAMPLE
    .\correlate-standings-runners.ps1 -Year 2025 -Series road-gp -ProjectRoot C:\repos\InterClub
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

$seriesDir     = Join-Path $ProjectRoot "src\data\$Year\$Series"
$standingsFile = Join-Path $seriesDir "individual-standings.json"
$runnersFile   = Join-Path $seriesDir "runners.json"

Write-Host ""
Write-Host "InterClub Standings Runner Correlator" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Year:      $Year  |  Series: $Series"
Write-Host "  Standings: $standingsFile"
Write-Host "  Runners:   $runnersFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

if (-not (Test-Path $standingsFile)) { throw "individual-standings.json not found: $standingsFile" }
if (-not (Test-Path $runnersFile))   { throw "runners.json not found: $runnersFile" }

function Normalize { param([string]$s) return $s.Trim().ToLower() }

# Return all possible (First, Last) splits of a full name, ordered from
# last-space split (most common) to first-space split.  This covers compound
# surnames: "Katherine Price Edwards" yields
#   ("Katherine Price", "Edwards") and ("Katherine", "Price Edwards")
# so the lookup succeeds regardless of which part runners.json stores as lastName.
function Get-NameSplits {
    param([string]$FullName)
    $n = $FullName.Trim()
    $splits = [System.Collections.Generic.List[hashtable]]::new()

    $positions = [System.Collections.Generic.List[int]]::new()
    for ($i = 0; $i -lt $n.Length; $i++) {
        if ($n[$i] -eq ' ') { $positions.Add($i) }
    }

    if ($positions.Count -eq 0) {
        $splits.Add(@{ First = $n; Last = "" })
        return $splits
    }

    # Emit splits from last space to first space (last-space first = most common case)
    for ($p = $positions.Count - 1; $p -ge 0; $p--) {
        $idx = $positions[$p]
        $splits.Add(@{ First = $n.Substring(0, $idx).Trim(); Last = $n.Substring($idx + 1).Trim() })
    }
    return $splits
}

$seriesRunners = [System.Collections.Generic.List[object]]::new()
foreach ($r in (Get-Content $runnersFile -Raw | ConvertFrom-Json)) { $seriesRunners.Add($r) }
Write-Host "Loaded $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray

# Exact index: "first|last|club|ageCategory" -> runner
$exactIndex = @{}
foreach ($r in $seriesRunners) {
    $key = "$(Normalize $r.firstName)|$(Normalize $r.lastName)|$(Normalize $r.club)|$(Normalize $r.ageCategory)"
    if (-not $exactIndex.ContainsKey($key)) { $exactIndex[$key] = $r }
}

# Name-only index: "first|last" -> list (for possible-match detection)
$nameIndex = @{}
foreach ($r in $seriesRunners) {
    $key = "$(Normalize $r.firstName)|$(Normalize $r.lastName)"
    if (-not $nameIndex.ContainsKey($key)) { $nameIndex[$key] = [System.Collections.Generic.List[object]]::new() }
    $nameIndex[$key].Add($r)
}

$standings = Get-Content $standingsFile -Raw | ConvertFrom-Json

$matched     = 0
$skipped     = 0
$needsReview = 0
$failed      = 0

Write-Host ""
Write-Host "Correlating standings runners..." -ForegroundColor Yellow
Write-Host ""

foreach ($cat in $standings.categories) {
    foreach ($runner in $cat.runners) {
        if (-not $runner.PSObject.Properties['name'] -or -not $runner.name) { continue }

        if ($runner.PSObject.Properties['seriesRunnerId'] -and $null -ne $runner.seriesRunnerId) {
            $skipped++
            continue
        }

        $splits   = Get-NameSplits $runner.name
        $club     = if ($runner.PSObject.Properties['club'])        { $runner.club }        else { "" }
        $ageCat   = if ($runner.PSObject.Properties['ageCategory']) { $runner.ageCategory } `
                    elseif ($cat.PSObject.Properties['ageCategory']) { $cat.ageCategory }   `
                    else { "" }

        # Try each split until an exact match is found
        $found = $null
        foreach ($np in $splits) {
            $exactKey = "$(Normalize $np.First)|$(Normalize $np.Last)|$(Normalize $club)|$(Normalize $ageCat)"
            if ($exactIndex.ContainsKey($exactKey)) {
                $found = $exactIndex[$exactKey]
                break
            }
        }

        if ($found) {
            $runner | Add-Member -NotePropertyName seriesRunnerId -NotePropertyValue ([int]$found.id) -Force
            Write-Host "  = Matched:  '$($runner.name)' [$($cat.id)] -> id=$($found.id)" -ForegroundColor DarkGray
            $matched++
        } else {
            # Try all splits against name-only index for possible-match hints
            $candidates = $null
            foreach ($np in $splits) {
                $nameKey = "$(Normalize $np.First)|$(Normalize $np.Last)"
                if ($nameIndex.ContainsKey($nameKey)) {
                    $candidates = $nameIndex[$nameKey]
                    break
                }
            }

            if ($candidates) {
                $opts = ($candidates | ForEach-Object { "id=$($_.id) club=$($_.club) sex=$($_.sex) cat=$($_.ageCategory)" }) -join "; "
                Write-Warning "Possible match for '$($runner.name)' [$($cat.id)] club=$club cat=$ageCat -- candidates: $opts"
                $needsReview++
            } else {
                Write-Warning "No match for '$($runner.name)' [$($cat.id)] club=$club cat=$ageCat"
                $failed++
            }
        }
    }
}

Write-Host ""
$issueCount   = $needsReview + $failed
$summaryColor = if ($issueCount -gt 0) { "Yellow" } else { "Green" }
Write-Host "Correlation complete: $matched matched, $skipped already set, $needsReview need review, $failed failed" -ForegroundColor $summaryColor

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - file NOT written" -ForegroundColor Magenta
    Write-Host "  Would update: $standingsFile"
} elseif ($matched -gt 0) {
    $updatedJson = $standings | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($standingsFile, $updatedJson, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $standingsFile" -ForegroundColor Green
} else {
    Write-Host "No matches found -- standings file unchanged." -ForegroundColor DarkGray
}

Write-Host ""
if ($issueCount -gt 0) {
    Write-Host "Completed with $issueCount issue(s) -- review above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
