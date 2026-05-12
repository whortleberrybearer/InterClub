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
param([string]$Year,[string]$RaceId,[ValidateSet("road-gp","fell")][string]$Series="road-gp",[string]$ProjectRoot)
$ErrorActionPreference="Stop"
if(-not $ProjectRoot){$ProjectRoot=Split-Path -Parent $PSScriptRoot}
if(-not $Year){$Year=Read-Host "Enter series year (e.g. 2026)"}
if(-not $RaceId){$RaceId=Read-Host "Enter race ID (e.g. blackpool)"}
$srcDir=Join-Path -Path $ProjectRoot -ChildPath "src"
$dataDir=Join-Path -Path $srcDir -ChildPath "data"
$yearDir=Join-Path -Path $dataDir -ChildPath $Year
$seriesDir=Join-Path -Path $yearDir -ChildPath $Series
$DataDir=Join-Path -Path $seriesDir -ChildPath "results"
$CsvPath=Join-Path -Path $DataDir -ChildPath "$RaceId.csv"
$JsonPath=Join-Path -Path $DataDir -ChildPath "$RaceId-teams.json"
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
$parts=$AbbreviatedName.Trim()-split'\s+'
if($parts.Count-lt 2){return $null}
$firstInitial=$parts[0][0].ToString().ToUpper()
# For multi-part surnames like "K. Price Edwards", join all parts after the initial
$surname=$parts[1..($parts.Count-1)]-join' '
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
if($originalName-notmatch'^[A-Z]\.'){continue}
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
