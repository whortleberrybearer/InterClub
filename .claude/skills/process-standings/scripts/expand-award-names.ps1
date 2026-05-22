<#
.SYNOPSIS
    Expands abbreviated award winner names in an awards.json file.

.DESCRIPTION
    For each individual award entry whose name looks abbreviated (e.g. "K. Littlefair"):
      - Matches against the series runners.json by first initial + surname.
      - Narrows candidates using club (if present on the award entry) and sex
        inferred from the parent awards category id (e.g. "v35-female" -> F).
      - If a unique match is found, replaces the abbreviated name with the full name.
      - If multiple candidates or no match, reports the issue without changing the name.
    Entries that already contain a space-separated full name are left unchanged.
    Writes the updated awards.json in-place.

.PARAMETER AwardsFile
    Path to the awards.json file to process.

.PARAMETER Year
    Series year (e.g. 2025).

.PARAMETER Series
    Series name: "road-gp" or "fell". Defaults to "road-gp".

.PARAMETER ProjectRoot
    Root of the InterClub repository. Defaults to the parent of the scripts folder.

.PARAMETER DryRun
    Parse and match everything but do not write any files.

.EXAMPLE
    .\scripts\expand-award-names.ps1 -Year 2025 -Series road-gp

.EXAMPLE
    .\scripts\expand-award-names.ps1 -AwardsFile "src\data\2025\road-gp\awards.json" -Year 2025 -DryRun
#>

[CmdletBinding()]
param(
    [string]$AwardsFile,
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

$seriesDir = Join-Path $ProjectRoot "src\data\$Year\$Series"
$seriesRunnersFile = Join-Path $seriesDir "runners.json"

if (-not $AwardsFile) {
    $AwardsFile = Join-Path $seriesDir "awards.json"
}
$AwardsFile = [System.IO.Path]::GetFullPath($AwardsFile)
if (-not (Test-Path $AwardsFile)) { throw "Awards file not found: $AwardsFile" }

# --- Helpers ------------------------------------------------------------------

function Normalize { param([string]$s) return $s.Trim().ToLower() }

# Returns true when the name looks like an abbreviation: single initial + surname.
function Is-Abbreviated {
    param([string]$Name)
    return $Name -match '^[A-Za-z]\.?\s+\S'
}

# Parse "K. Littlefair", "M. Osinski-Gray" -> @{ Initial; LastName }
function Parse-Abbreviated {
    param([string]$Name)
    if ($Name -match '^([A-Za-z])\.?\s+(.+)$') {
        return @{ Initial = $matches[1].ToUpper(); LastName = $matches[2].Trim() }
    }
    return $null
}

# Infer sex from awards category id (e.g. "v35-female" -> "F", "sen-male" -> "M")
function Infer-Sex {
    param([string]$CategoryId)
    if ($CategoryId -match 'female') { return "F" }
    if ($CategoryId -match '\bmale\b') { return "M" }
    return ""
}

# Find candidates in runners list matching initial + surname, optionally narrowed
# by club and sex. Returns the filtered list.
function Find-Candidates {
    param(
        [string]$Initial,
        [string]$LastName,
        [string]$Club,
        [string]$Sex,
        [System.Collections.Generic.List[object]]$Runners
    )
    $candidates = @($Runners | Where-Object {
        $_.firstName[0].ToString().ToUpper() -eq $Initial -and
        (Normalize $_.lastName) -eq (Normalize $LastName)
    })

    if ($Club -and $candidates.Count -gt 1) {
        $byClub = @($candidates | Where-Object { (Normalize $_.club) -eq (Normalize $Club) })
        if ($byClub.Count -gt 0) { $candidates = $byClub }
    }

    if ($Sex -and $candidates.Count -gt 1) {
        $bySex = @($candidates | Where-Object { $_.sex -ieq $Sex })
        if ($bySex.Count -gt 0) { $candidates = $bySex }
    }

    return $candidates
}

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Award Name Expander" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration" -ForegroundColor Yellow
Write-Host "  Awards:         $AwardsFile"
Write-Host "  Year:           $Year  |  Series: $Series"
Write-Host "  Series runners: $seriesRunnersFile"
if ($DryRun) { Write-Host "  *** DRY RUN - no files written ***" -ForegroundColor Magenta }
Write-Host ""

# --- Load series runners ------------------------------------------------------

$seriesRunners = [System.Collections.Generic.List[object]]::new()
if (Test-Path $seriesRunnersFile) {
    foreach ($r in (Get-Content $seriesRunnersFile -Raw | ConvertFrom-Json)) { $seriesRunners.Add($r) }
}
Write-Host "Loaded $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray

# --- Load awards --------------------------------------------------------------

$awardsData = Get-Content $AwardsFile -Raw | ConvertFrom-Json

# --- Expand names -------------------------------------------------------------

Write-Host ""
Write-Host "Expanding names..." -ForegroundColor Yellow
Write-Host ""

$updated   = 0
$skipped   = 0   # already full name
$failed    = [System.Collections.Generic.List[string]]::new()
$ambiguous = [System.Collections.Generic.List[string]]::new()

foreach ($catGroup in $awardsData.individualAwards) {
    $catId    = $catGroup.id
    $inferSex = Infer-Sex $catId

    foreach ($award in $catGroup.awards) {
        if (-not $award.PSObject.Properties['name'] -or -not $award.name) { continue }

        $originalName = $award.name.Trim()

        if (-not (Is-Abbreviated $originalName)) {
            $skipped++
            continue
        }

        $parsed = Parse-Abbreviated $originalName
        if (-not $parsed) {
            $failed.Add("[$catId] '$originalName' -- could not parse abbreviated name")
            continue
        }

        $awardClub = if ($award.PSObject.Properties['club'] -and $award.club) { $award.club } else { "" }

        $candidates = @(Find-Candidates `
            -Initial   $parsed.Initial `
            -LastName  $parsed.LastName `
            -Club      $awardClub `
            -Sex       $inferSex `
            -Runners   $seriesRunners)

        if ($candidates.Count -eq 1) {
            $fullName     = "$($candidates[0].firstName) $($candidates[0].lastName)"
            $award.name   = $fullName
            $updated++
            Write-Host "  '$originalName' -> '$fullName'  [$catId]$(if ($awardClub) { " ($awardClub)" })" -ForegroundColor Green
        } elseif ($candidates.Count -eq 0) {
            $clubHint = if ($awardClub) { " club=$awardClub" } else { "" }
            $sexHint  = if ($inferSex)  { " sex=$inferSex" }  else { "" }
            $failed.Add("[$catId] '$originalName'$clubHint$sexHint -- no match")
        } else {
            $opts = ($candidates | ForEach-Object { "$($_.firstName) $($_.lastName) (id=$($_.id) club=$($_.club))" }) -join "; "
            $ambiguous.Add("[$catId] '$originalName' -- ambiguous: $opts")
        }
    }
}

# --- Summary ------------------------------------------------------------------

Write-Host ""
$issueCount   = $failed.Count + $ambiguous.Count
$summaryColor = if ($issueCount -gt 0) { "Yellow" } else { "Green" }
Write-Host "Complete: $updated expanded, $skipped already full name, $($failed.Count) failed, $($ambiguous.Count) ambiguous" -ForegroundColor $summaryColor

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "FAILED -- no match found:" -ForegroundColor Red
    foreach ($msg in $failed) { Write-Host "  $msg" -ForegroundColor Red }
}

if ($ambiguous.Count -gt 0) {
    Write-Host ""
    Write-Host "AMBIGUOUS -- name not updated:" -ForegroundColor Yellow
    foreach ($msg in $ambiguous) { Write-Host "  $msg" -ForegroundColor Yellow }
}

# --- Write output -------------------------------------------------------------

Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN - file NOT written" -ForegroundColor Magenta
    Write-Host "  Would update: $AwardsFile"
} else {
    $updatedJson = $awardsData | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($AwardsFile, $updatedJson, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $AwardsFile" -ForegroundColor Green
}

Write-Host ""
if ($issueCount -gt 0) {
    Write-Host "Completed with $issueCount issue(s) -- review above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
