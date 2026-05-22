#Requires -Version 5.1
param(
    [Parameter(Mandatory)]
    [string]$Race,
    [switch]$Write
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-EligibleRunners {
    param(
        [Parameter(Mandatory)] $Runners,
        [Parameter(Mandatory)] [string] $CategoryId
    )

    $id = $CategoryId.ToLower()

    if ($id -match '^(open|overall|mixed)$') {
        return @($Runners | Sort-Object { [int]$_.ic_position })
    }

    if ($id -match '^(ladies|women|female)$') {
        return @($Runners | Where-Object { $_.sex -eq 'F' } | Sort-Object { [int]$_.ic_position })
    }

    if ($id -match '^(vets|veterans)$') {
        $minAge = 40
        return @($Runners | Where-Object {
            $_.age_category -match '^V(\d+)$' -and [int]$Matches[1] -ge $minAge
        } | Sort-Object { [int]$_.ic_position })
    }

    if ($id -match '^v(\d+)$') {
        $minAge = [int]$Matches[1]
        return @($Runners | Where-Object {
            $_.age_category -match '^V(\d+)$' -and [int]$Matches[1] -ge $minAge
        } | Sort-Object { [int]$_.ic_position })
    }

    Write-Error "Unrecognised category id: '$CategoryId'. Cannot determine eligibility rules."
    exit 1
}

# Resolve paths from the race argument (year/series/raceId)
$parts = $Race -split '/'
if ($parts.Count -ne 3) {
    Write-Error "Race must be year/series/raceId (e.g. 2025/fell/pendle)"
    exit 1
}
$year   = $parts[0]
$series = $parts[1]
$raceId = $parts[2]

$dataRoot  = Join-Path (Join-Path $PSScriptRoot '..') 'src\data'
$csvPath   = Join-Path $dataRoot "$year\$series\results\$raceId.csv"
$teamsPath = Join-Path $dataRoot "$year\$series\results\$raceId-teams.json"

foreach ($p in @($csvPath, $teamsPath)) {
    if (-not (Test-Path $p)) {
        Write-Error "File not found: $p"
        exit 1
    }
}

Write-Host "Processing: $Race" -ForegroundColor Cyan
Write-Host ""

# Load CSV — Import-Csv uses the header row automatically
$allRows   = Import-Csv $csvPath
# IC runners are those with a non-empty ic_position (guests have blank ic_position)
$icRunners = @($allRows | Where-Object { $_.ic_position -ne '' })

Write-Host "CSV: $($icRunners.Count) inter-club runners"
Write-Host ""

# Load teams JSON
$teamsJson = Get-Content $teamsPath -Raw | ConvertFrom-Json

$totalMatches    = 0
$totalMismatches = 0
$totalNotFound   = 0

foreach ($category in $teamsJson.categories) {
    $catId          = $category.id
    $eligible       = Get-EligibleRunners -Runners $icRunners -CategoryId $catId
    $eligibleCount  = $eligible.Count

    # Human-readable label for the category header
    $catLabel = if ($catId -match '^(open|overall|mixed)$')     { 'all runners' }
                elseif ($catId -match '^(ladies|women|female)$') { 'female runners' }
                elseif ($catId -match '^(vets|veterans)$')       { 'V40+' }
                elseif ($catId -match '^v(\d+)$')                { "V$($Matches[1])+" }
                else                                              { $catId }

    $header = "== $($catId.ToUpper()) ($catLabel) "
    Write-Host ($header.PadRight(52, '=')) -ForegroundColor White
    Write-Host ""

    foreach ($clubEntry in $category.clubs) {
        Write-Host "  $($clubEntry.club)  (scorers: $($clubEntry.scorers.Count))" -ForegroundColor White

        foreach ($scorer in $clubEntry.scorers) {
            $pos = [int]$scorer.position

            if ($pos -lt 1 -or $pos -gt $eligibleCount) {
                Write-Host ("    Pos {0,3}  ->  (not found - only {1} eligible runners)  !" -f $pos, $eligibleCount) -ForegroundColor Yellow
                $totalNotFound++
                continue
            }

            $runner   = $eligible[$pos - 1]   # positions are 1-based
            $fullName = "$($runner.first_name) $($runner.last_name)".Trim()
            $calcClub = $runner.club

            if ($calcClub -eq $clubEntry.club) {
                Write-Host ("    Pos {0,3}  ->  {1,-22} ({2})   OK" -f $pos, $fullName, $calcClub) -ForegroundColor Green
                $totalMatches++
            } else {
                Write-Host ("    Pos {0,3}  ->  {1,-22} ({2})   MISMATCH  expected $($clubEntry.club)" -f $pos, $fullName, $calcClub) -ForegroundColor Red
                $totalMismatches++
            }
        }
        Write-Host ""
    }
}

# Summary
$summaryLine = "== SUMMARY "
Write-Host ($summaryLine.PadRight(52, '=')) -ForegroundColor White
Write-Host ""
Write-Host "  OK   $totalMatches scorers matched" -ForegroundColor $(if ($totalMatches -gt 0) { 'Green' } else { 'White' })

$mismatchColour = if ($totalMismatches -eq 0) { 'Green' } else { 'Red' }
Write-Host "  !!   $totalMismatches mismatches" -ForegroundColor $mismatchColour

$notFoundColour = if ($totalNotFound -eq 0) { 'Green' } else { 'Yellow' }
Write-Host "  ??   $totalNotFound positions not found (position exceeds eligible runner count)" -ForegroundColor $notFoundColour
Write-Host ""

if ($Write) {
    if ($totalMismatches -gt 0 -or $totalNotFound -gt 0) {
        Write-Host "  Cannot write: fix all mismatches and missing positions first." -ForegroundColor Red
        exit 1
    }

    # Re-iterate and populate 'name' on each scorer
    foreach ($category in $teamsJson.categories) {
        $eligible = Get-EligibleRunners -Runners $icRunners -CategoryId $category.id

        foreach ($clubEntry in $category.clubs) {
            foreach ($scorer in $clubEntry.scorers) {
                $pos    = [int]$scorer.position
                $runner = $eligible[$pos - 1]
                $name   = "$($runner.first_name.Substring(0, 1)). $($runner.last_name)"

                # Only add if not already present (idempotent)
                if (-not ($scorer.PSObject.Properties.Name -contains 'name')) {
                    $scorer | Add-Member -NotePropertyName 'name' -NotePropertyValue $name
                }
            }
        }
    }

    $json = $teamsJson | ConvertTo-Json -Depth 10
    # Use UTF-8 without BOM (PS 5.1 lacks utf8NoBOM; use StreamWriter instead)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Resolve-Path $teamsPath).Path, $json, $utf8NoBom)
    Write-Host "  Written: $teamsPath" -ForegroundColor Green
} else {
    if ($totalMismatches -eq 0 -and $totalNotFound -eq 0) {
        Write-Host "  All scorers matched. Run with -Write to populate names." -ForegroundColor Cyan
    } else {
        Write-Host "  Fix all mismatches before running with -Write." -ForegroundColor Yellow
    }
}
