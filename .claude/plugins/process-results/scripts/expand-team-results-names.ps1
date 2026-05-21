<#
.SYNOPSIS
    Expands abbreviated runner names in team results JSON.
.DESCRIPTION
    Matches abbreviated names (e.g. "M. Swarbrick") with full names from CSV by surname, first initial, and club.
.PARAMETER Year
    Series year (e.g. 2026).
.PARAMETER RaceId
    Race ID (e.g. "blackpool").
.PARAMETER Series
    Series name: "road-gp" or "fell".  Defaults to "road-gp".
.PARAMETER ProjectRoot
    Root of the InterClub repository.  Defaults to parent of scripts folder.
.EXAMPLE
    .\scripts\expand-team-results-names.ps1 -Year 2026 -RaceId blackpool
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Year,
    [Parameter(Mandatory)][string]$RaceId,
    [ValidateSet("road-gp","fell")][string]$Series = "road-gp",
    [string]$ProjectRoot
)
$ErrorActionPreference = "Stop"
if (-not $ProjectRoot) {
    $ProjectRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $ProjectRoot) { throw "ProjectRoot not supplied and could not be resolved from git" }
}
$srcDir  = Join-Path $ProjectRoot "src"
$dataDir = Join-Path $srcDir "data"
$yearDir = Join-Path $dataDir $Year
$seriesDir = Join-Path $yearDir $Series
$DataDir = Join-Path $seriesDir "results"
$CsvPath  = Join-Path $DataDir "$RaceId.csv"
$JsonPath = Join-Path $DataDir "$RaceId-teams.json"
Write-Output "Reading CSV: $CsvPath"
Write-Output "Reading JSON: $JsonPath"
if(-not(Test-Path $CsvPath)){Write-Error "CSV file not found: $CsvPath"}
if(-not(Test-Path $JsonPath)){Write-Error "Team results JSON not found: $JsonPath"}
$csvContent=Get-Content $CsvPath -Raw
$lines=$csvContent-split "`n"
$headers=$lines[0]-split','
$runners=@()
for($i=1;$i-lt $lines.Count;$i++){
if([string]::IsNullOrWhiteSpace($lines[$i])){continue}
$values=$lines[$i]-split','
$record=@{}
for($j=0;$j-lt $headers.Count;$j++){$record[$headers[$j].Trim()]=if($j-lt $values.Count){$values[$j]}else{""}}
$runners+=@{firstName=$record["first_name"];lastName=$record["last_name"];club=$record["club"];sex=$record["sex"];category=$record["category"]}
}
Write-Output "Loaded $($runners.Count) runners from CSV"
function Find-MatchingRunner{
param([string]$AbbreviatedName,[string]$Club,[array]$Runners)
$AbbreviatedName=$AbbreviatedName.Trim()
# Check if name starts with initial (with or without dot)
if($AbbreviatedName-notmatch '^[A-Z]'){return $null}
$firstInitial=$AbbreviatedName[0].ToString().ToUpper()
$surname=$null
# Pattern 1: Has dot after initial ("D." or "D. ")
if($AbbreviatedName-match '^[A-Z]\.(.+)$'){
$surname=$matches[1].Trim()
}
# Pattern 2: Has space after initial ("D Rigby")
elseif($AbbreviatedName-match '^[A-Z]\s(.+)$'){
$surname=$matches[1].Trim()
}
# Pattern 3: No dot, no space - directly concatenated ("DRigby")
elseif($AbbreviatedName.Length-gt 1){
$surname=$AbbreviatedName.Substring(1)
}
if([string]::IsNullOrWhiteSpace($surname)){return $null}
# Split on space in case of multi-part surnames and rejoin
$surnameParts=$surname-split'\s+'
$surname=$surnameParts-join' '
# Try exact match first
$candidates=@($runners|Where-Object{$_.lastName-eq $surname-and$_.firstName[0].ToString().ToUpper()-eq $firstInitial-and$_.club-eq $Club})
if($candidates.Count-eq 0){
  # If no exact match, try matching against the full name in case surname is stored differently
  $candidates=@($runners|Where-Object{($_.firstName+' '+$_.lastName)-eq $surname-and$_.firstName[0].ToString().ToUpper()-eq $firstInitial-and$_.club-eq $Club})
}
if($candidates.Count-eq 0){return $null}
if($candidates.Count-eq 1){return $candidates[0]}
return $candidates[0]
}
$teamResults=Get-Content $JsonPath -Raw|ConvertFrom-Json
$updateCount=0
$errorCount=0
foreach($categoryGroup in $teamResults.categories){
foreach($clubResult in $categoryGroup.clubs){
foreach($scorer in $clubResult.scorers){
$originalName=$scorer.name
# Skip if name doesn't start with initial letter (with or without dot)
if($originalName-notmatch'^[A-Z]'){continue}
$matched=Find-MatchingRunner -AbbreviatedName $originalName -Club $clubResult.club -Runners $runners
if($matched){
$newName="$($matched.firstName) $($matched.lastName)"
$scorer.name=$newName
$updateCount++
Write-Output "Updated: '$originalName' -> '$newName' ($($clubResult.club))"
}else{
$errorCount++
Write-Output "ERROR: Could not resolve: '$originalName' in club '$($clubResult.club)'"
}
}
}
}
$json=ConvertTo-Json $teamResults -Depth 100
$json|Out-File $JsonPath -Encoding UTF8 -NoNewline
Add-Content $JsonPath "`n" -Encoding UTF8
Write-Output "Completed: $updateCount names updated, $errorCount errors"
if($errorCount-gt 0){Write-Error "Script completed with errors"}
