# Populate Scorer Details Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `scripts/Populate-ScorerDetails.ps1` — a PowerShell script that reads a fell race CSV, calculates category-relative positions, validates scorer club assignments in the teams JSON, and optionally writes runner names.

**Architecture:** Single standalone PowerShell script. Reads `src/data/{year}/{series}/results/{raceId}.csv` and `src/data/{year}/{series}/results/{raceId}-teams.json`, derives runner eligibility from team category ids via pattern matching, cross-references positions, and reports mismatches. Writes only when `-Write` is passed and there are zero issues.

**Tech Stack:** PowerShell 5.1+, built-in `Import-Csv`, `ConvertFrom-Json`, `ConvertTo-Json`, `Add-Member`.

---

### Task 1: Script scaffold with parameter handling and file validation

**Files:**
- Create: `scripts/Populate-ScorerDetails.ps1`

- [ ] **Step 1: Create the script file with parameters and path resolution**

Create `scripts/Populate-ScorerDetails.ps1` with this exact content:

```powershell
#Requires -Version 5.1
param(
    [Parameter(Mandatory)]
    [string]$Race,
    [switch]$Write
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve paths from the race argument (year/series/raceId)
$parts = $Race -split '/'
if ($parts.Count -ne 3) {
    Write-Error "Race must be year/series/raceId (e.g. 2025/fell/pendle)"
    exit 1
}
$year   = $parts[0]
$series = $parts[1]
$raceId = $parts[2]

$dataRoot  = Join-Path $PSScriptRoot '..' 'src' 'data'
$csvPath   = Join-Path $dataRoot $year $series 'results' "$raceId.csv"
$teamsPath = Join-Path $dataRoot $year $series 'results' "$raceId-teams.json"

foreach ($p in @($csvPath, $teamsPath)) {
    if (-not (Test-Path $p)) {
        Write-Error "File not found: $p"
        exit 1
    }
}

Write-Host "Processing: $Race" -ForegroundColor Cyan
Write-Host ""
```

- [ ] **Step 2: Verify parameter validation works**

Run from the project root:

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race badformat
```

Expected output:
```
Write-Error: Race must be year/series/raceId (e.g. 2025/fell/pendle)
```

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/doesnotexist
```

Expected: error saying the CSV file was not found.

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle
```

Expected:
```
Processing: 2025/fell/pendle

```

- [ ] **Step 3: Commit**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: add Populate-ScorerDetails script scaffold"
```

---

### Task 2: Load CSV and teams JSON

**Files:**
- Modify: `scripts/Populate-ScorerDetails.ps1`

- [ ] **Step 1: Add CSV and JSON loading after the existing validation block**

Append to the end of `scripts/Populate-ScorerDetails.ps1`:

```powershell
# Load CSV — Import-Csv uses the header row automatically
$allRows   = Import-Csv $csvPath
# IC runners are those with a non-empty ic_position (guests have blank ic_position)
$icRunners = @($allRows | Where-Object { $_.ic_position -ne '' })

Write-Host "CSV: $($icRunners.Count) inter-club runners"
Write-Host ""

# Load teams JSON
$teamsJson = Get-Content $teamsPath -Raw | ConvertFrom-Json
```

- [ ] **Step 2: Verify CSV loading**

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle
```

Expected:
```
Processing: 2025/fell/pendle

CSV: 43 inter-club runners

```

Check a different race to confirm the count changes:

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/waddington
```

Expected: shows the Waddington CSV runner count (not 43).

- [ ] **Step 3: Commit**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: load CSV and teams JSON in scorer details script"
```

---

### Task 3: Category eligibility function

**Files:**
- Modify: `scripts/Populate-ScorerDetails.ps1`

- [ ] **Step 1: Add the eligibility function before the CSV loading block**

Insert this function block immediately after the `$ErrorActionPreference = 'Stop'` line (before the `$parts = $Race -split '/'` line):

```powershell
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
```

Note: each `if` block uses `$Matches[1]` from the immediately preceding `-match` on `$id`, not from within `Where-Object`. Inside `Where-Object`, the `-match` on `$_.age_category` sets its own `$Matches[1]`. The `$minAge` variable is captured before the `Where-Object` lambda runs.

- [ ] **Step 2: Add a temporary debug line to verify the function**

Temporarily append to the end of the script (after the `$teamsJson` line):

```powershell
# DEBUG: verify eligibility counts for pendle
$openRunners  = Get-EligibleRunners -Runners $icRunners -CategoryId 'open'
$vetsRunners  = Get-EligibleRunners -Runners $icRunners -CategoryId 'vets'
$v50Runners   = Get-EligibleRunners -Runners $icRunners -CategoryId 'v50'
$v60Runners   = Get-EligibleRunners -Runners $icRunners -CategoryId 'v60'
$ladiesRunners = Get-EligibleRunners -Runners $icRunners -CategoryId 'ladies'
Write-Host "DEBUG open=$($openRunners.Count) vets=$($vetsRunners.Count) v50=$($v50Runners.Count) v60=$($v60Runners.Count) ladies=$($ladiesRunners.Count)"
# DEBUG end
```

- [ ] **Step 3: Run and verify counts against the pendle CSV**

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle
```

Expected debug line (cross-check manually against `src/data/2025/fell/results/pendle.csv`):

Counting from the pendle CSV:
- Open: 43 (all IC runners)
- Vets (V40+): all runners whose age_category starts with V — Banks(V40), Cowburn(V50), Hall(V40), Griffiths(V60), Rainford(V60), Bass(V50), Farrimond(V40), Shaw(V60), McDermott(V50), Ellithorn(V60), Myerscough(V50), Butler(V60), Woodruffe(V60), Beckett(V50), Baker(V60), Quinn(V50), Singleton(V60), Hall(V40,F), Cann(V60), Lawler(V50,F), Blight(V50), Collier(V70), Salt(V50,F), Rolfe(V60,F), Schofield(V70), Plowman(V60,F), Scarr(V60), Wiggans(V40,F), Cooper(V50,F), McDermott(V80), Smith(V70) = 31
- V50+: subset of vets with V50, V60, V70, V80 — Cowburn(V50), Griffiths(V60), Rainford(V60), Bass(V50), Shaw(V60), McDermott(V50), Ellithorn(V60), Myerscough(V50), Butler(V60), Woodruffe(V60), Beckett(V50), Baker(V60), Quinn(V50), Singleton(V60), Cann(V60), Lawler(V50,F), Blight(V50), Collier(V70), Salt(V50,F), Rolfe(V60,F), Schofield(V70), Plowman(V60,F), Scarr(V60), Cooper(V50,F), McDermott(V80), Smith(V70) = 26
- V60+: Griffiths(V60), Rainford(V60), Shaw(V60), Ellithorn(V60), Butler(V60), Woodruffe(V60), Baker(V60), Singleton(V60), Cann(V60), Collier(V70), Rolfe(V60,F), Schofield(V70), Plowman(V60,F), Scarr(V60), McDermott(V80), Smith(V70) = 16
- Ladies (F): Websdale, Wiggans, Hall(V40,F), Lawler(V50,F), Salt(V50,F), Rolfe(V60,F), Plowman(V60,F), Hargreaves, Pawelczak, Cooper(V50,F), Wiggans(V40,F) = 11

```
DEBUG open=43 vets=31 v50=26 v60=16 ladies=11
```

- [ ] **Step 4: Remove the debug lines**

Delete the 8 DEBUG lines you added in Step 2 from the end of the script.

- [ ] **Step 5: Commit**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: add category eligibility function to scorer details script"
```

---

### Task 4: Main report loop

**Files:**
- Modify: `scripts/Populate-ScorerDetails.ps1`

- [ ] **Step 1: Add report loop and summary counters**

Append to the end of `scripts/Populate-ScorerDetails.ps1` (after the `$teamsJson` line):

```powershell
$totalMatches    = 0
$totalMismatches = 0
$totalNotFound   = 0

foreach ($category in $teamsJson.categories) {
    $catId          = $category.id
    $eligible       = Get-EligibleRunners -Runners $icRunners -CategoryId $catId
    $eligibleCount  = $eligible.Count

    # Human-readable label for the category header
    $catLabel = if ($catId -match '^(open|overall|mixed)$')    { 'all runners' }
                elseif ($catId -match '^(ladies|women|female)$') { 'female runners' }
                elseif ($catId -match '^(vets|veterans)$')      { 'V40+' }
                elseif ($catId -match '^v(\d+)$')               { "V$($Matches[1])+" }
                else                                             { $catId }

    $header = "══ $($catId.ToUpper()) ($catLabel) "
    Write-Host ($header.PadRight(52, '═')) -ForegroundColor White
    Write-Host ""

    foreach ($clubEntry in $category.clubs) {
        Write-Host "  $($clubEntry.club)  (scorers: $($clubEntry.scorers.Count))" -ForegroundColor White

        foreach ($scorer in $clubEntry.scorers) {
            $pos = [int]$scorer.position

            if ($pos -lt 1 -or $pos -gt $eligibleCount) {
                Write-Host ("    Pos {0,3}  →  (not found — only {1} eligible runners)  ⚠" -f $pos, $eligibleCount) -ForegroundColor Yellow
                $totalNotFound++
                continue
            }

            $runner   = $eligible[$pos - 1]   # positions are 1-based
            $fullName = "$($runner.first_name) $($runner.last_name)".Trim()
            $calcClub = $runner.club

            if ($calcClub -eq $clubEntry.club) {
                Write-Host ("    Pos {0,3}  →  {1,-22} ({2})   ✓" -f $pos, $fullName, $calcClub) -ForegroundColor Green
                $totalMatches++
            } else {
                Write-Host ("    Pos {0,3}  →  {1,-22} ({2})   ❌  expected $($clubEntry.club)" -f $pos, $fullName, $calcClub) -ForegroundColor Red
                $totalMismatches++
            }
        }
        Write-Host ""
    }
}

# Summary
$summaryLine = "══ SUMMARY "
Write-Host ($summaryLine.PadRight(52, '═')) -ForegroundColor White
Write-Host ""
Write-Host "  ✓  $totalMatches scorers matched" -ForegroundColor $(if ($totalMatches -gt 0) { 'Green' } else { 'White' })

$mismatchColour = if ($totalMismatches -eq 0) { 'Green' } else { 'Red' }
Write-Host "  ❌  $totalMismatches mismatches" -ForegroundColor $mismatchColour

$notFoundColour = if ($totalNotFound -eq 0) { 'Green' } else { 'Yellow' }
Write-Host "  ⚠   $totalNotFound positions not found (position exceeds eligible runner count)" -ForegroundColor $notFoundColour
Write-Host ""
```

- [ ] **Step 2: Run the report against pendle and check output structure**

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle
```

Expected structure (content will vary as existing positions may be wrong):
- A header line for each category (`══ OPEN (all runners) ══...`)
- Each club listed with scorer lines showing position → name (club) and ✓ or ❌
- Summary at the end showing counts

Check that:
1. VETS category chorley scorers at positions 2, 6, 7, 10 all show ✓ (these are correct per the design spec: Cowburn, Bass, Farrimond, Ellithorn)
2. OPEN category shows numerous ❌ (the existing positions in pendle-teams.json are incorrect for that category)
3. The summary counts are non-zero

- [ ] **Step 3: Commit**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: add report loop and summary to scorer details script"
```

---

### Task 5: Write mode

**Files:**
- Modify: `scripts/Populate-ScorerDetails.ps1`

- [ ] **Step 1: Add write mode block after the summary**

Append to the end of `scripts/Populate-ScorerDetails.ps1` (after the final `Write-Host ""` in the summary):

```powershell
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
    Set-Content -Path $teamsPath -Value $json -Encoding utf8NoBOM
    Write-Host "  ✓ Written: $teamsPath" -ForegroundColor Green
} else {
    if ($totalMismatches -eq 0 -and $totalNotFound -eq 0) {
        Write-Host "  All scorers matched. Run with -Write to populate names." -ForegroundColor Cyan
    } else {
        Write-Host "  Fix all mismatches before running with -Write." -ForegroundColor Yellow
    }
}
```

- [ ] **Step 2: Verify write mode blocks when there are mismatches**

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle -Write
```

Expected (since pendle has mismatches in the Open category):
```
  Cannot write: fix all mismatches and missing positions first.
```

And verify the JSON file is unchanged:

```powershell
git diff src/data/2025/fell/results/pendle-teams.json
```

Expected: no diff.

- [ ] **Step 3: Test write mode on a race that validates cleanly**

First check which 2025 fell races have clean data by running the script against each:

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/hutton-roof-crags
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/leo-pollard
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/waddington
```

If any show `All scorers matched`, test write mode on that race. If all have mismatches, skip this step and move on — write mode will be tested once the underlying JSON data is fixed.

- [ ] **Step 4: Verify JSON output format is valid**

After any successful write, check the output file is valid JSON:

```powershell
Get-Content src/data/2025/fell/results/<race>-teams.json -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

Expected: no errors, output matches the input structure.

- [ ] **Step 5: Commit**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: add write mode to scorer details script"
```

---

### Task 6: End-to-end smoke test across all 2025 fell races

**Files:**
- No changes

- [ ] **Step 1: Run the script against all four 2025 fell races**

```powershell
foreach ($race in @('hutton-roof-crags', 'leo-pollard', 'pendle', 'waddington')) {
    Write-Host "`n========== 2025/fell/$race ==========" -ForegroundColor Cyan
    .\scripts\Populate-ScorerDetails.ps1 -Race "2025/fell/$race"
}
```

- [ ] **Step 2: Check the script handles unknown category ids gracefully**

Add a temporary test: create a minimal teams JSON with an unknown category id and verify the error:

```powershell
$testJson = '{"categories":[{"id":"unknown-cat","clubs":[]}]}' 
$testJson | Set-Content "$env:TEMP\test-teams.json"
# Temporarily point the script at it by running directly with the path for a quick check:
# (Just confirm the error message text from the function in the script is correct)
```

Actually, to avoid modifying the script for a one-off test, just visually inspect that the `Write-Error "Unrecognised category id: '$CategoryId'"` line is present in `Get-EligibleRunners`.

- [ ] **Step 3: Verify the script is idempotent on already-named scorers**

If any race was successfully written in Task 5, run the dry-run again on it:

```powershell
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/<written-race>
```

Expected: all scorers still show ✓, summary shows 0 mismatches, 0 not found.

- [ ] **Step 4: Final commit if any cleanup needed**

```powershell
git add scripts/Populate-ScorerDetails.ps1
git commit -m "feat: complete Populate-ScorerDetails PowerShell script"
```

---

## Usage Reference

```powershell
# Dry run for any fell race:
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle

# Write names once all mismatches are resolved:
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle -Write

# Works for any year/series:
.\scripts\Populate-ScorerDetails.ps1 -Race 2019/fell/pendle
```
