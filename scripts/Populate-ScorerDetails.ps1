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
