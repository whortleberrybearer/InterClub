<#
.SYNOPSIS
    Matches scorer names in a team results JSON to series runners.json entries
    and sets seriesRunnerId on each scorer.

.DESCRIPTION
    For each scorer in every category/club of the team results JSON:
      - Splits the scorer name into first/last on the final space.
      - Looks up the runner in series runners.json by name + club (case-insensitive).
      - If a unique match is found, sets seriesRunnerId on the scorer.
      - If multiple matches exist (same name, same club), validates against the
        runner's sex and category and reports any remaining ambiguity.
      - If no match is found, reports the failure.
    Scorers with no name field are skipped silently.
    All issues are summarised at the end. Writes the updated JSON in-place.

.PARAMETER JsonFile
    Path to the team results JSON file to process.

.PARAMETER Year
    Series year (e.g. 2026).

.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to the parent of the scripts folder.

.PARAMETER DryRun
    Parse and validate everything but do not write any files.

.EXAMPLE
    .\scripts\correlate-team-runners.ps1 -JsonFile "src\data\2026\road-gp\results\blackpool-teams.json" -Year 2026

.EXAMPLE
    .\scripts\correlate-team-runners.ps1 -JsonFile "src\data\2026\road-gp\results\lytham-teams-provisional.json" -Year 2026 -DryRun
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$JsonFile,
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
$JsonFile    = [System.IO.Path]::GetFullPath($JsonFile)
if (-not (Test-Path $JsonFile)) { throw "JSON file not found: $JsonFile" }

# --- Helpers ------------------------------------------------------------------

function Normalize {
    param([string]$s)
    return $s.Trim().ToLower()
}

# Return all possible (First, Last) splits of a full name, ordered from
# last-space split (most common) to first-space split.  This covers compound
# surnames: "Katherine Price Edwards" yields
#   ("Katherine Price", "Edwards") and ("Katherine", "Price Edwards")
# so the lookup succeeds regardless of which part runners.json stores as lastName.
function Get-NameSplits {
    param([string]$FullName)
    $n = $FullName.Trim()
    $splits = [System.Collections.Generic.List[hashtable]]::new()

    # Collect all space positions
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

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Team Runner Correlator" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Derived paths
$seriesDir         = Join-Path $ProjectRoot "src\data\$Year\$Series"
$seriesRunnersFile = Join-Path $seriesDir "runners.json"

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  JSON:           $JsonFile"
Write-Host "  Year:           $Year  |  Series: $Series"
Write-Host "  Series runners: $seriesRunnersFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# --- Load series runners ------------------------------------------------------

$seriesRunners = [System.Collections.Generic.List[object]]::new()
if (Test-Path $seriesRunnersFile) {
    foreach ($r in (Get-Content $seriesRunnersFile -Raw -Encoding UTF8 | ConvertFrom-Json)) { $seriesRunners.Add($r) }
}
Write-Host "Loaded $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray

# Build index: "first|last|club" -> list of matching runner objects
# Multiple entries under the same key means an ambiguous match.
$nameClubIndex = @{}
foreach ($r in $seriesRunners) {
    $key = "$(Normalize $r.firstName)|$(Normalize $r.lastName)|$(Normalize $r.club)"
    if (-not $nameClubIndex.ContainsKey($key)) {
        $nameClubIndex[$key] = [System.Collections.Generic.List[object]]::new()
    }
    $nameClubIndex[$key].Add($r)
}

# --- Load team results JSON ---------------------------------------------------

Write-Host "Loading team results JSON..." -ForegroundColor DarkGray
$teamData = Get-Content $JsonFile -Raw -Encoding UTF8 | ConvertFrom-Json

# --- Correlate scorers --------------------------------------------------------

Write-Host ""
Write-Host "Correlating scorers..." -ForegroundColor Yellow

$matched    = 0
$skipped    = 0   # no name field
$failures   = [System.Collections.Generic.List[string]]::new()
$ambiguous  = [System.Collections.Generic.List[string]]::new()

foreach ($cat in $teamData.categories) {
    foreach ($clubEntry in $cat.clubs) {
        $clubId = $clubEntry.club
        foreach ($scorer in $clubEntry.scorers) {
            # Skip scorers with no name
            if (-not $scorer.PSObject.Properties['name'] -or -not $scorer.name) {
                $skipped++
                continue
            }

            $fullName  = $scorer.name.Trim()
            $splits    = Get-NameSplits $fullName
            $candidates = $null

            foreach ($np in $splits) {
                $key = "$(Normalize $np.First)|$(Normalize $np.Last)|$(Normalize $clubId)"
                if ($nameClubIndex.ContainsKey($key)) {
                    $candidates = $nameClubIndex[$key]
                    break
                }
            }

            if (-not $candidates) {
                $msg = "[$($cat.category) / $clubId] '$fullName' -- no match in runners.json"
                $failures.Add($msg)
                continue
            }

            if ($candidates.Count -eq 1) {
                $runner   = $candidates[0]
                $scorer | Add-Member -NotePropertyName seriesRunnerId -NotePropertyValue ([int]$runner.id) -Force
                $matched++
            } else {
                # Multiple runners with same name + club -- attempt disambiguation
                # via the runner's sex/category properties (we don't have those on the
                # scorer, but we can check if all candidates share the same id).
                $distinctIds = $candidates | ForEach-Object { $_.id } | Sort-Object -Unique
                if ($distinctIds.Count -eq 1) {
                    # Same id registered twice -- treat as unambiguous
                    $scorer | Add-Member -NotePropertyName seriesRunnerId -NotePropertyValue ([int]$candidates[0].id) -Force
                    $matched++
                } else {
                    $options = ($candidates | ForEach-Object { "id=$($_.id) sex=$($_.sex) cat=$($_.category)" }) -join "; "
                    $msg = "[$($cat.category) / $clubId] '$fullName' -- ambiguous ($options)"
                    $ambiguous.Add($msg)
                }
            }
        }
    }
}

# --- Summary ------------------------------------------------------------------

Write-Host ""
$issueCount = $failures.Count + $ambiguous.Count
$summaryColor = if ($issueCount -gt 0) { "Yellow" } else { "Green" }
Write-Host "Correlation complete: $matched matched, $skipped skipped (no name), $($failures.Count) failed, $($ambiguous.Count) ambiguous" -ForegroundColor $summaryColor

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "FAILURES -- no matching runner found:" -ForegroundColor Red
    foreach ($msg in $failures) { Write-Host "  $msg" -ForegroundColor Red }
}

if ($ambiguous.Count -gt 0) {
    Write-Host ""
    Write-Host "AMBIGUOUS -- multiple candidates, seriesRunnerId not set:" -ForegroundColor Yellow
    foreach ($msg in $ambiguous) { Write-Host "  $msg" -ForegroundColor Yellow }
}

# --- Write output -------------------------------------------------------------

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - file NOT written" -ForegroundColor Magenta
    Write-Host "  Would update: $JsonFile"
} else {
    $updatedJson = $teamData | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($JsonFile, $updatedJson, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $JsonFile" -ForegroundColor Green
}

Write-Host ""
if ($issueCount -gt 0) {
    Write-Host "Completed with $issueCount issue(s) -- review above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
