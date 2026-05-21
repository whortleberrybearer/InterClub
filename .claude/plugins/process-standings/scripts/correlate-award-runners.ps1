<#
.SYNOPSIS
    Assigns seriesRunnerId to individual award winners in an awards.json file.

.DESCRIPTION
    For each individual award entry without a seriesRunnerId:
      - Parses the abbreviated name (e.g. "K. Littlefair") into initial + surname.
      - Filters the series runners.json by initial, surname, and optionally club
        and age category when present on the award entry.
      - Infers sex from the parent awards category id (e.g. "v35-female" -> F).
      - If a unique match is found, sets seriesRunnerId automatically.
      - If multiple candidates or no match, prompts interactively.
    Also fills in missing club and category fields on the award entry from the
    matched runner.
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
    .\scripts\correlate-award-runners.ps1 -Year 2025 -Series road-gp

.EXAMPLE
    .\scripts\correlate-award-runners.ps1 -AwardsFile "src\data\2025\road-gp\awards.json" -Year 2025
#>

[CmdletBinding()]
param(
    [string]$AwardsFile,
    [string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$DryRun
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

function Normalize { param([string]$s) return $s.Trim().ToLower() }

# Parse "K. Littlefair", "M. Osinski-Gray", "Rob Danson" etc.
# Returns @{ Initial = "K"; LastName = "Littlefair" } or $null if unparseable.
function Parse-AbbreviatedName {
    param([string]$Name)
    $n = $Name.Trim()
    if ($n -match '^([A-Za-z])\.?\s+(.+)$') {
        return @{ Initial = $matches[1].ToUpper(); LastName = $matches[2].Trim() }
    }
    # Full name (no abbreviation) -- split on last space
    $idx = $n.LastIndexOf(' ')
    if ($idx -gt 0) {
        return @{ Initial = $n[0].ToString().ToUpper(); LastName = $n.Substring($idx + 1).Trim() }
    }
    return $null
}

# Returns true for broad categories (male, female, overall) where the runner's
# age category is not implied and should be stored on the award entry.
# Age-specific categories (jun-*, sen-*, v35-*, etc.) already encode the age group.
function Is-BroadCategory {
    param([string]$CategoryId)
    return $CategoryId -notmatch '^(jun|sen|v\d+)'
}

# Infer sex ("M" or "F" or "") from awards category id like "v35-female", "sen-male", "female", "male"
function Infer-Sex {
    param([string]$CategoryId)
    if ($CategoryId -match 'female') { return "F" }
    if ($CategoryId -match 'male')   { return "M" }
    return ""
}

# --- Main ---------------------------------------------------------------------

Write-Host ""
Write-Host "InterClub Award Runner Correlator" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path $ProjectRoot)) { throw "Project root not found: $ProjectRoot" }

if (-not $Year) {
    $Year = Prompt-Value "Series year (e.g. 2025)" "2025"
}

$seriesDir         = Join-Path $ProjectRoot "src\data\$Year\$Series"
$seriesRunnersFile = Join-Path $seriesDir "runners.json"

if (-not $AwardsFile) {
    $default = Join-Path $seriesDir "awards.json"
    $AwardsFile = Prompt-Value "Awards JSON file path" $default
}
$AwardsFile = [System.IO.Path]::GetFullPath($AwardsFile)
if (-not (Test-Path $AwardsFile)) { throw "Awards file not found: $AwardsFile" }

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

# --- Correlate ----------------------------------------------------------------

Write-Host ""
Write-Host "Correlating award winners..." -ForegroundColor Yellow
Write-Host ""

$matched  = 0
$skipped  = 0   # already has seriesRunnerId
$prompted = 0
$unresolved = [System.Collections.Generic.List[string]]::new()

foreach ($catGroup in $awardsData.individualAwards) {
    $catId    = $catGroup.category
    $inferSex = Infer-Sex $catId

    foreach ($award in $catGroup.awards) {
        if (-not $award.PSObject.Properties['name'] -or -not $award.name) { continue }

        # Skip if already assigned
        if ($award.PSObject.Properties['seriesRunnerId'] -and $null -ne $award.seriesRunnerId) {
            $skipped++
            continue
        }

        $displayName = $award.name
        $awardClub   = if ($award.PSObject.Properties['club']     -and $award.club)     { $award.club }     else { "" }
        $awardCat    = if ($award.PSObject.Properties['category'] -and $award.category) { $award.category } else { "" }

        $parsed = Parse-AbbreviatedName $displayName
        if (-not $parsed) {
            Write-Host "  [SKIP] Cannot parse name: '$displayName'" -ForegroundColor Yellow
            $unresolved.Add("[$catId] '$displayName' -- unparseable name")
            continue
        }

        $initial  = $parsed.Initial
        $lastName = $parsed.LastName

        # Build candidate list: initial + surname match
        $candidates = @($seriesRunners | Where-Object {
            $_.firstName[0].ToString().ToUpper() -eq $initial -and
            (Normalize $_.lastName) -eq (Normalize $lastName)
        })

        # Narrow by club if known
        if ($awardClub -and $candidates.Count -gt 1) {
            $byClub = @($candidates | Where-Object { (Normalize $_.club) -eq (Normalize $awardClub) })
            if ($byClub.Count -gt 0) { $candidates = $byClub }
        }

        # Narrow by inferred sex
        if ($inferSex -and $candidates.Count -gt 1) {
            $bySex = @($candidates | Where-Object { $_.sex -ieq $inferSex })
            if ($bySex.Count -gt 0) { $candidates = $bySex }
        }

        # Narrow by age category on award entry
        if ($awardCat -and $candidates.Count -gt 1) {
            $byCat = @($candidates | Where-Object { (Normalize $_.category) -eq (Normalize $awardCat) })
            if ($byCat.Count -gt 0) { $candidates = $byCat }
        }

        $chosenRunner = $null

        if ($candidates.Count -eq 1) {
            $chosenRunner = $candidates[0]
            $sexHint = if ($inferSex) { " sex=$inferSex" } else { "" }
            Write-Host "  [AUTO] [$catId] '$displayName' -> id=$($chosenRunner.id)  $($chosenRunner.firstName) $($chosenRunner.lastName) ($($chosenRunner.club))$sexHint" -ForegroundColor Green
        } else {
            # Need user input
            Write-Host ""
            if ($candidates.Count -eq 0) {
                Write-Host "  [?] [$catId] pos=$($award.position) '$displayName'" -ForegroundColor Yellow
                if ($awardClub) { Write-Host "      club: $awardClub" -ForegroundColor DarkGray }
                if ($awardCat)  { Write-Host "      category: $awardCat" -ForegroundColor DarkGray }
                if ($inferSex)  { Write-Host "      inferred sex: $inferSex" -ForegroundColor DarkGray }
                Write-Host "      No match found in runners.json." -ForegroundColor Red

                # Show all runners with matching surname as a hint
                $surnameHints = @($seriesRunners | Where-Object { (Normalize $_.lastName) -eq (Normalize $lastName) })
                if ($surnameHints.Count -gt 0) {
                    Write-Host "      Same surname in runners.json:" -ForegroundColor DarkGray
                    foreach ($h in $surnameHints) {
                        Write-Host "        id=$($h.id)  $($h.firstName) $($h.lastName)  club=$($h.club)  sex=$($h.sex)  cat=$($h.category)" -ForegroundColor DarkGray
                    }
                }
            } else {
                Write-Host "  [?] [$catId] pos=$($award.position) '$displayName' -- $($candidates.Count) candidates:" -ForegroundColor Yellow
                foreach ($c in $candidates) {
                    Write-Host "      id=$($c.id)  $($c.firstName) $($c.lastName)  club=$($c.club)  sex=$($c.sex)  cat=$($c.category)" -ForegroundColor DarkGray
                }
            }

            $input = Read-Host "      Enter runner ID to assign (or blank to skip)"
            $input = $input.Trim()

            if ($input -match '^\d+$') {
                $rid = [int]$input
                $chosenRunner = $seriesRunners | Where-Object { [int]$_.id -eq $rid } | Select-Object -First 1
                if (-not $chosenRunner) {
                    Write-Host "      ID $rid not found -- skipping." -ForegroundColor Red
                    $unresolved.Add("[$catId] '$displayName' -- ID $rid not found")
                } else {
                    Write-Host "      Assigned id=$rid  $($chosenRunner.firstName) $($chosenRunner.lastName)" -ForegroundColor Green
                    $prompted++
                }
            } else {
                Write-Host "      Skipped." -ForegroundColor DarkGray
                $unresolved.Add("[$catId] '$displayName' -- skipped by user")
            }
            Write-Host ""
        }

        if ($chosenRunner) {
            $award | Add-Member -NotePropertyName seriesRunnerId -NotePropertyValue ([int]$chosenRunner.id) -Force
            if ($candidates.Count -eq 1) { $matched++ }

            # Fill in missing club and category from runner
            if (-not $awardClub) {
                $award | Add-Member -NotePropertyName club -NotePropertyValue $chosenRunner.club -Force
            }
            if (-not $awardCat -and (Is-BroadCategory $catId)) {
                $award | Add-Member -NotePropertyName category -NotePropertyValue $chosenRunner.category -Force
            }
        }
    }
}

# --- Summary ------------------------------------------------------------------

Write-Host ""
$issueCount   = $unresolved.Count
$summaryColor = if ($issueCount -gt 0) { "Yellow" } else { "Green" }
Write-Host "Correlation complete: $matched auto-matched, $prompted prompted, $skipped already set, $issueCount unresolved" -ForegroundColor $summaryColor

if ($unresolved.Count -gt 0) {
    Write-Host ""
    Write-Host "UNRESOLVED:" -ForegroundColor Yellow
    foreach ($msg in $unresolved) { Write-Host "  $msg" -ForegroundColor Yellow }
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
    Write-Host "Completed with $issueCount unresolved item(s) -- review above." -ForegroundColor Yellow
} else {
    Write-Host "Completed successfully." -ForegroundColor Green
}
