# Results Ingestion Workflows Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create two Claude Code skills (`process-results` and `process-standings`) that orchestrate the existing PowerShell scripts into interactive, AI-assisted ingestion pipelines with batch disambiguation.

**Architecture:** Each skill lives as a self-contained directory under `.claude/plugins/` containing `skill.md` and a `scripts/` subdirectory. Existing scripts are moved from the repo-level `scripts/` directory into their respective skill directories. Claude orchestrates the pipeline, collects reported ambiguities across all steps, proposes resolutions using AI reasoning, and presents a single batch review before patching data files.

**Tech Stack:** PowerShell 5.1, Claude Code skills (markdown), claude-haiku-4-5-20251001

---

## File Map

**Created:**
- `.claude/plugins/process-results/skill.md`
- `.claude/plugins/process-standings/skill.md`
- `.claude/plugins/process-standings/scripts/correlate-standings-runners.ps1` ← new script

**Moved** (git mv, preserving history):
- `scripts/parse-results.ps1` → `.claude/plugins/process-results/scripts/parse-results.ps1`
- `scripts/correlate-runners.ps1` → `.claude/plugins/process-results/scripts/correlate-runners.ps1`
- `scripts/correlate-global-runners.ps1` → `.claude/plugins/process-results/scripts/correlate-global-runners.ps1`
- `scripts/expand-team-results-names.ps1` → `.claude/plugins/process-results/scripts/expand-team-results-names.ps1`
- `scripts/correlate-team-runners.ps1` → `.claude/plugins/process-results/scripts/correlate-team-runners.ps1`
- `scripts/parse-individual-standings.ps1` → `.claude/plugins/process-standings/scripts/parse-individual-standings.ps1`
- `scripts/expand-award-names.ps1` → `.claude/plugins/process-standings/scripts/expand-award-names.ps1`
- `scripts/correlate-award-runners.ps1` → `.claude/plugins/process-standings/scripts/correlate-award-runners.ps1`

**Modified after move:**
- All 7 moved scripts: fix `ProjectRoot` default (see Task 2)
- `correlate-runners.ps1`, `correlate-global-runners.ps1`, `expand-team-results-names.ps1`, `correlate-team-runners.ps1`, `expand-award-names.ps1`: strip interactive prompting (Task 3)
- `correlate-award-runners.ps1`: add `-BatchMode` switch (Task 4)

**Not changed:** `parse-results.ps1`, `parse-individual-standings.ps1` (retain interactive prompting for standalone use)

---

## Task 1: Create skill directories and move scripts

**Files:**
- Create: `.claude/plugins/process-results/scripts/` (directory)
- Create: `.claude/plugins/process-standings/scripts/` (directory)
- Move: 8 scripts as listed in File Map above

- [ ] **Step 1: Create the skill directory tree**

```powershell
New-Item -ItemType Directory -Path ".claude\plugins\process-results\scripts" -Force
New-Item -ItemType Directory -Path ".claude\plugins\process-standings\scripts" -Force
```

- [ ] **Step 2: Move process-results scripts using git mv**

```bash
git mv scripts/parse-results.ps1 .claude/plugins/process-results/scripts/parse-results.ps1
git mv scripts/correlate-runners.ps1 .claude/plugins/process-results/scripts/correlate-runners.ps1
git mv scripts/correlate-global-runners.ps1 .claude/plugins/process-results/scripts/correlate-global-runners.ps1
git mv scripts/expand-team-results-names.ps1 .claude/plugins/process-results/scripts/expand-team-results-names.ps1
git mv scripts/correlate-team-runners.ps1 .claude/plugins/process-results/scripts/correlate-team-runners.ps1
```

- [ ] **Step 3: Move process-standings scripts using git mv**

```bash
git mv scripts/parse-individual-standings.ps1 .claude/plugins/process-standings/scripts/parse-individual-standings.ps1
git mv scripts/expand-award-names.ps1 .claude/plugins/process-standings/scripts/expand-award-names.ps1
git mv scripts/correlate-award-runners.ps1 .claude/plugins/process-standings/scripts/correlate-award-runners.ps1
```

- [ ] **Step 4: Verify moves**

```bash
git status
```

Expected: 8 renames shown, `scripts/` directory now contains only `parse-road-gp-awards.js`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: move ingestion scripts into skill directories"
```

---

## Task 2: Fix ProjectRoot defaults in all moved scripts

Scripts were previously at `scripts/` (one level below project root). They are now at `.claude/plugins/{skill}/scripts/` (four levels below). The `Split-Path -Parent $PSScriptRoot` default no longer resolves to the project root. Replace with a git-based resolution in all 8 moved scripts.

**Files:**
- Modify: all 8 scripts listed in File Map under "Moved"

The fix is identical in all scripts. For the 5 scripts that are losing their `Prompt-Value` function entirely (Task 3), this is handled as part of that task. Apply the fix here only to the 3 scripts that keep their interactive prompting: `parse-results.ps1`, `parse-individual-standings.ps1`, and `correlate-award-runners.ps1` (which still needs its existing interactive mode working before Task 4 adds `-BatchMode`).

- [ ] **Step 1: Fix ProjectRoot in `parse-results.ps1`**

Find and replace the existing ProjectRoot block:
```powershell
# BEFORE (around line 1360):
if (-not $ProjectRoot) {
    $defaultRoot = Split-Path -Parent $PSScriptRoot
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

Replace with:
```powershell
if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

- [ ] **Step 2: Fix ProjectRoot in `parse-individual-standings.ps1`**

Find and replace (around line 398):
```powershell
# BEFORE:
if (-not $ProjectRoot) {
    $defaultRoot = Split-Path -Parent $PSScriptRoot
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

Replace with:
```powershell
if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

- [ ] **Step 3: Fix ProjectRoot in `correlate-award-runners.ps1`**

Find and replace (around line 105):
```powershell
# BEFORE:
if (-not $ProjectRoot) {
    $defaultRoot = Split-Path -Parent $PSScriptRoot
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

Replace with:
```powershell
if (-not $ProjectRoot) {
    $defaultRoot = (git -C $PSScriptRoot rev-parse --show-toplevel 2>$null)
    if (-not $defaultRoot) { $defaultRoot = "" }
    $ProjectRoot = Prompt-Value "Project root directory" $defaultRoot
}
```

- [ ] **Step 4: Verify the three scripts still run standalone**

```powershell
& ".\.claude\plugins\process-results\scripts\parse-results.ps1" -DryRun
```

Expected: prompts for ExcelFile path (script is interactive and expects input — Ctrl+C to cancel after confirming the prompt appears).

- [ ] **Step 5: Commit**

```bash
git add .claude/plugins/process-results/scripts/parse-results.ps1
git add .claude/plugins/process-standings/scripts/parse-individual-standings.ps1
git add .claude/plugins/process-standings/scripts/correlate-award-runners.ps1
git commit -m "fix: update ProjectRoot defaults after moving scripts to skill directories"
```

---

## Task 3: Strip interactive prompting from correlation/expansion scripts

These 5 scripts are only called by skills, never standalone. Remove the `Prompt-Value` helper function and all `Read-Host` / `Prompt-Value` parameter collection blocks. Make required parameters throw explicitly if not provided.

**Files:**
- Modify: `.claude/plugins/process-results/scripts/correlate-runners.ps1`
- Modify: `.claude/plugins/process-results/scripts/correlate-global-runners.ps1`
- Modify: `.claude/plugins/process-results/scripts/expand-team-results-names.ps1`
- Modify: `.claude/plugins/process-results/scripts/correlate-team-runners.ps1`
- Modify: `.claude/plugins/process-standings/scripts/expand-award-names.ps1`

Apply the same pattern to each script:

### `correlate-runners.ps1`

- [ ] **Step 1: Update param block and remove Prompt-Value function**

Replace the `Prompt-Value` function and parameter collection section. The script currently starts:

```powershell
[CmdletBinding()]
param(
    [string]$CsvFile,
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
```

Replace through to the end of the parameter collection block (ending just before `# Derived paths`) with:

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$CsvFile,
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
$CsvFile     = [System.IO.Path]::GetFullPath($CsvFile)
if (-not (Test-Path $CsvFile)) { throw "CSV file not found: $CsvFile" }
```

Delete the old interactive blocks:
```powershell
# DELETE these blocks entirely:
if (-not $ProjectRoot) { ... Prompt-Value ... }
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path $ProjectRoot)) { throw ... }

if (-not $Year) { ... Prompt-Value ... }

if (-not $CsvFile) { ... Prompt-Value ... }
$CsvFile = [System.IO.Path]::GetFullPath($CsvFile)
if (-not (Test-Path $CsvFile)) { throw ... }
```

### `correlate-global-runners.ps1`

- [ ] **Step 2: Strip prompting from `correlate-global-runners.ps1`**

Replace the `Prompt-Value` function and parameter collection (everything from the function definition through the parameter collection blocks, ending before `# Derived paths`) with:

```powershell
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
```

Delete the old `if (-not $ProjectRoot)` and `if (-not $Year)` interactive blocks that follow.

### `expand-team-results-names.ps1`

- [ ] **Step 3: Strip prompting from `expand-team-results-names.ps1`**

The script currently opens with a dense one-liner param block and inline `Read-Host`. Replace the entire opening section (param block through path derivation) with:

```powershell
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
```

Delete the old `if(-not $ProjectRoot)`, `if(-not $Year)`, `if(-not $RaceId)` Read-Host lines.

### `correlate-team-runners.ps1`

- [ ] **Step 4: Strip prompting from `correlate-team-runners.ps1`**

Replace from the `Prompt-Value` function definition through the end of parameter collection (before `# Derived paths`) with:

```powershell
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
```

### `expand-award-names.ps1`

- [ ] **Step 5: Strip prompting from `expand-award-names.ps1`**

Replace from the `Prompt-Value` function definition through parameter collection with:

```powershell
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
```

- [ ] **Step 6: Verify all 5 scripts fail cleanly when required params are missing**

```powershell
& ".\.claude\plugins\process-results\scripts\correlate-runners.ps1"
```

Expected: PowerShell mandatory parameter error asking for `CsvFile` and `Year`, or a throw — not a `Read-Host` prompt.

- [ ] **Step 7: Commit**

```bash
git add .claude/plugins/process-results/scripts/correlate-runners.ps1
git add .claude/plugins/process-results/scripts/correlate-global-runners.ps1
git add .claude/plugins/process-results/scripts/expand-team-results-names.ps1
git add .claude/plugins/process-results/scripts/correlate-team-runners.ps1
git add .claude/plugins/process-standings/scripts/expand-award-names.ps1
git commit -m "refactor: strip interactive prompting from correlation/expansion scripts"
```

---

## Task 4: Add -BatchMode to `correlate-award-runners.ps1`

**Files:**
- Modify: `.claude/plugins/process-standings/scripts/correlate-award-runners.ps1`

- [ ] **Step 1: Add `-BatchMode` to the param block**

```powershell
# BEFORE:
param(
    [string]$AwardsFile,
    [string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$DryRun
)
```

```powershell
# AFTER:
param(
    [string]$AwardsFile,
    [string]$Year,
    [ValidateSet("road-gp", "fell")]
    [string]$Series = "road-gp",
    [string]$ProjectRoot,
    [switch]$DryRun,
    [switch]$BatchMode
)
```

- [ ] **Step 2: Add ambiguity list initialisation after the banner**

After the `Write-Host "Correlating award winners..." -ForegroundColor Yellow` line, add:

```powershell
$ambiguities = [System.Collections.Generic.List[object]]::new()
```

- [ ] **Step 3: Replace the Read-Host block with batch/interactive branch**

Find the `else` block that contains `Write-Host "  [?]..."` and `Read-Host "Enter runner ID..."`. Replace the entire `else` block with:

```powershell
} else {
    if ($BatchMode) {
        $ambiguities.Add([ordered]@{
            categoryId  = $catId
            position    = $award.position
            name        = $displayName
            club        = $awardClub
            inferredSex = $inferSex
            candidates  = @($candidates | ForEach-Object {
                [ordered]@{
                    id        = [int]$_.id
                    firstName = $_.firstName
                    lastName  = $_.lastName
                    club      = $_.club
                    sex       = $_.sex
                    category  = $_.category
                }
            })
        })
    } else {
        # Interactive mode — existing Read-Host logic unchanged
        Write-Host ""
        if ($candidates.Count -eq 0) {
            Write-Host "  [?] [$catId] pos=$($award.position) '$displayName'" -ForegroundColor Yellow
            if ($awardClub) { Write-Host "      club: $awardClub" -ForegroundColor DarkGray }
            if ($awardCat)  { Write-Host "      category: $awardCat" -ForegroundColor DarkGray }
            if ($inferSex)  { Write-Host "      inferred sex: $inferSex" -ForegroundColor DarkGray }
            Write-Host "      No match found in runners.json." -ForegroundColor Red
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
}
```

- [ ] **Step 4: Write ambiguity report and exit in batch mode**

Add this block immediately before the `# --- Summary ---` comment:

```powershell
# Batch mode: write report and exit if ambiguities exist
if ($BatchMode -and $ambiguities.Count -gt 0) {
    $reportPath = "$AwardsFile.ambiguities.json"
    ($ambiguities | ConvertTo-Json -Depth 5) | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host ""
    Write-Host "Batch mode: $($ambiguities.Count) ambiguit$(if ($ambiguities.Count -eq 1) {'y'} else {'ies'}) written to: $reportPath" -ForegroundColor Yellow
    exit 1
}
```

- [ ] **Step 5: Verify batch mode writes the report file**

```powershell
# Create a minimal test awards.json with an abbreviated name
$testDir = "C:\Temp\test-batch-mode"
New-Item -ItemType Directory -Path $testDir -Force
'{"teamAwards":[],"individualAwards":[{"category":"v35-female","awards":[{"position":1,"name":"K. Test"}]}]}' | Set-Content "$testDir\awards.json"
'[]' | Set-Content "$testDir\runners.json"

& ".\.claude\plugins\process-standings\scripts\correlate-award-runners.ps1" `
  -AwardsFile "$testDir\awards.json" `
  -Year 2025 -Series road-gp `
  -ProjectRoot (git rev-parse --show-toplevel) `
  -BatchMode -DryRun
```

Expected: exit code 1, file `C:\Temp\test-batch-mode\awards.json.ambiguities.json` created containing one ambiguity entry with `name = "K. Test"`, `inferredSex = "F"`, `candidates = []`.

- [ ] **Step 6: Commit**

```bash
git add .claude/plugins/process-standings/scripts/correlate-award-runners.ps1
git commit -m "feat: add -BatchMode switch to correlate-award-runners.ps1"
```

---

## Task 5: Create `correlate-standings-runners.ps1`

**Files:**
- Create: `.claude/plugins/process-standings/scripts/correlate-standings-runners.ps1`

- [ ] **Step 1: Create the script**

```powershell
<#
.SYNOPSIS
    Assigns seriesRunnerId to runner entries in individual-standings.json.

.DESCRIPTION
    For each runner in individual-standings.json without a seriesRunnerId:
      - Splits the runner name into first/last on the final space.
      - Looks for an exact match in series runners.json by firstName, lastName, club, and sex.
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

function Split-FullName {
    param([string]$FullName)
    $n   = $FullName.Trim()
    $idx = $n.LastIndexOf(' ')
    if ($idx -lt 0) { return @{ First = $n; Last = "" } }
    return @{ First = $n.Substring(0, $idx).Trim(); Last = $n.Substring($idx + 1).Trim() }
}

$seriesRunners = [System.Collections.Generic.List[object]]::new()
foreach ($r in (Get-Content $runnersFile -Raw | ConvertFrom-Json)) { $seriesRunners.Add($r) }
Write-Host "Loaded $($seriesRunners.Count) series runner(s)." -ForegroundColor DarkGray

# Exact index: "first|last|club|sex" -> runner
$exactIndex = @{}
foreach ($r in $seriesRunners) {
    $key = "$(Normalize $r.firstName)|$(Normalize $r.lastName)|$(Normalize $r.club)|$(Normalize $r.sex)"
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

        $np   = Split-FullName $runner.name
        $club = if ($runner.PSObject.Properties['club']) { $runner.club } else { "" }
        $sex  = if ($runner.PSObject.Properties['sex'])  { $runner.sex }  else { "" }

        $exactKey = "$(Normalize $np.First)|$(Normalize $np.Last)|$(Normalize $club)|$(Normalize $sex)"
        $nameKey  = "$(Normalize $np.First)|$(Normalize $np.Last)"

        if ($exactIndex.ContainsKey($exactKey)) {
            $found = $exactIndex[$exactKey]
            $runner | Add-Member -NotePropertyName seriesRunnerId -NotePropertyValue ([int]$found.id) -Force
            Write-Host "  = Matched:  '$($runner.name)' [$($cat.id)] -> id=$($found.id)" -ForegroundColor DarkGray
            $matched++
        } elseif ($nameIndex.ContainsKey($nameKey)) {
            $candidates = $nameIndex[$nameKey]
            $opts = ($candidates | ForEach-Object { "id=$($_.id) club=$($_.club) sex=$($_.sex) cat=$($_.category)" }) -join "; "
            Write-Warning "Possible match for '$($runner.name)' [$($cat.id)] club=$club sex=$sex -- candidates: $opts"
            $needsReview++
        } else {
            Write-Warning "No match for '$($runner.name)' [$($cat.id)] club=$club sex=$sex"
            $failed++
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
```

- [ ] **Step 2: Verify script runs with -DryRun against an existing year's data**

```powershell
$root = git rev-parse --show-toplevel
& ".\.claude\plugins\process-standings\scripts\correlate-standings-runners.ps1" `
  -Year 2025 -Series road-gp `
  -ProjectRoot $root `
  -DryRun
```

Expected: script loads runners, reports match/skip/fail counts, prints "DRY RUN - file NOT written". No errors on missing files (adjust year to one that has both `individual-standings.json` and `runners.json`).

- [ ] **Step 3: Commit**

```bash
git add .claude/plugins/process-standings/scripts/correlate-standings-runners.ps1
git commit -m "feat: add correlate-standings-runners.ps1 script"
```

---

## Task 6: Write `process-results/skill.md`

**Files:**
- Create: `.claude/plugins/process-results/skill.md`

- [ ] **Step 1: Write the skill file**

```markdown
---
name: process-results
description: Process an InterClub race results Excel file. Orchestrates the full ingestion pipeline — parsing Excel, correlating runners, expanding team scorer names — with AI-assisted batch disambiguation.
model: claude-haiku-4-5-20251001
---

# Process Race Results

Use this skill when the user wants to ingest a race results Excel file into the InterClub site data.

Announce: "Using process-results skill to run the ingestion pipeline."

## Parameters

Collect any missing values before starting. Ask for all absent ones in a single `AskUserQuestion` call.

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `ExcelFile` | Yes | Full path to the results Excel file | `C:\Downloads\blackpool 2026.xlsx` |
| `Year` | Yes | Series year | `2026` |
| `Series` | Yes | `road-gp` or `fell` | `road-gp` |
| `RaceId` | Yes | Race identifier matching `races.json` | `blackpool` |
| `Provisional` | No | Mark as provisional (default: n) | `y` / `n` |

Derive `ProjectRoot` by running:
```
git rev-parse --show-toplevel
```

The skill scripts are at `<skill_dir>/scripts/` where `<skill_dir>` is the base directory of this skill (shown when the skill was loaded).

---

## Disambiguation Batch

As you run Steps 2–5 below, collect every reported ambiguity and failure into a single list. Do NOT pause at each one. Run all steps first, then resolve everything in one batch (Step 6).

For each collected item, record:
- Which step it came from
- The name as reported
- Club and category context
- Candidates list if provided by the script
- The file and field to patch on resolution

---

## Step 1 — Parse Excel

Run `parse-results.ps1`. This script is interactive — it will prompt for missing values in the terminal. The key parameters it needs:

```
<skill_dir>/scripts/parse-results.ps1
  -ExcelFile  "<ExcelFile>"
  -Year       <Year>
  -Series     <Series>
  -RaceId     <RaceId>
  -ProjectRoot "<ProjectRoot>"
  [-Provisional]
```

On success, report: runner count, IC runner count, team categories found, and the three output files written:
- `src/data/<Year>/<Series>/results/<RaceId>[–provisional].csv`
- `src/data/<Year>/<Series>/results/<RaceId>-teams[–provisional].json`
- `src/data/<Year>/<Series>/team-standings.json`

Stop and report if the script errors.

---

## Step 2 — Correlate individual runners

```
<skill_dir>/scripts/correlate-runners.ps1
  -CsvFile     "src\data\<Year>\<Series>\results\<RaceId>[–provisional].csv"
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

Collect into the batch: any `WARNING: Bib N name mismatch` lines — note the bib, CSV name, and runners.json name.

---

## Step 3 — Correlate global runners

```
<skill_dir>/scripts/correlate-global-runners.ps1
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

Collect into the batch: any blocks containing `? Possible match(es) for series id=...` — note the series id, name, club, sex, ageCategory, and the listed global-runner candidates.

---

## Step 4 — Expand team scorer names

```
<skill_dir>/scripts/expand-team-results-names.ps1
  -Year        <Year>
  -RaceId      <RaceId>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

Collect into the batch: any lines matching `ERROR: Could not resolve: '<name>' in club '<club>'`.

---

## Step 5 — Correlate team scorer IDs

```
<skill_dir>/scripts/correlate-team-runners.ps1
  -JsonFile    "src\data\<Year>\<Series>\results\<RaceId>-teams[–provisional].json"
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

Collect into the batch: all entries under the `FAILURES -- no matching runner found:` and `AMBIGUOUS -- multiple candidates` sections of the output.

---

## Step 6 — Disambiguation Round

Skip this step if the batch is empty.

For each collected item, reason about the best resolution:
- **Name similarity** — match initial + surname against `src/data/<Year>/<Series>/runners.json`
- **Sex inference** — team category `ladies`/`women`/`fv40` → F; `open`/`vets`/`vet50`/`vet60` → check other signals
- **Club** — narrows candidates when multiple share the same name
- **Category** — age/sex breaks remaining ties

Build a formatted proposal table and annotate each with confidence (HIGH / MED / NONE):

```
Disambiguation required — N items:

 #  Step                    Name              Proposed                       Confidence
 1  team-scorer-expand      M. Swarbrick      Matthew Swarbrick [id=42]      HIGH  (unique match, wesham)
 2  team-scorer-correlate   J. Smith          John Smith [id=15]              MED   (2 candidates; open team → M)
 3  global-runners          A. Danson         — no match found —             NONE  (suggest: create new global runner)
```

Then use `AskUserQuestion`:

**Options:** `Accept all` / `Correct specific items` / `Handle each individually`

- **Accept all** — apply all proposals immediately
- **Correct specific items** — ask "Which numbers need changing, and what should they be?" Apply stated corrections
- **Handle each individually** — step through each with an `AskUserQuestion` showing actual candidates as options

### Applying resolutions

| Source step | What to patch | File |
|-------------|--------------|------|
| `correlate-runners` name mismatch | Update `first_name`/`last_name` in the CSV row matching that bib | `src/data/<Year>/<Series>/results/<RaceId>.csv` |
| `correlate-global-runners` possible match | Set `runnerId` on the series runner entry | `src/data/<Year>/<Series>/runners.json` |
| `expand-team-results-names` failure | Replace abbreviated `name` with full name on the scorer entry | `src/data/<Year>/<Series>/results/<RaceId>-teams.json` |
| `correlate-team-runners` failure/ambiguous | Set `seriesRunnerId` on the scorer entry | `src/data/<Year>/<Series>/results/<RaceId>-teams.json` |

After patching, re-run the affected downstream script(s) to confirm no remaining issues.

---

## Step 7 — Summary

Report:
- All files written (paths)
- Runner correlation: N individual runners matched, N new global runners created, N team scorers linked
- Any items still unresolved — flag for manual attention with the file and field that needs updating
```

- [ ] **Step 2: Commit**

```bash
git add .claude/plugins/process-results/skill.md
git commit -m "feat: add process-results skill"
```

---

## Task 7: Write `process-standings/skill.md`

**Files:**
- Create: `.claude/plugins/process-standings/skill.md`

- [ ] **Step 1: Write the skill file**

```markdown
---
name: process-standings
description: Process an InterClub end-of-season standings and awards Excel file. Parses individual standings, correlates runners, expands award names, and assigns seriesRunnerIds with AI-assisted batch disambiguation.
model: claude-haiku-4-5-20251001
---

# Process Standings and Awards

Use this skill when the user wants to process an end-of-season standings Excel file and/or populate an awards.json file for the InterClub site.

Announce: "Using process-standings skill to run the standings ingestion pipeline."

## Parameters

Collect any missing values before starting.

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `ExcelFile` | Yes | Full path to the standings Excel file | `C:\Downloads\inter club final 2025.xlsx` |
| `Year` | Yes | Series year | `2025` |
| `Series` | Yes | `road-gp` or `fell` | `road-gp` |
| `Provisional` | No | Mark standings as provisional (default: n) | `y` / `n` |

Derive `ProjectRoot` by running:
```
git rev-parse --show-toplevel
```

The skill scripts are at `<skill_dir>/scripts/` where `<skill_dir>` is the base directory of this skill.

---

## Disambiguation Batch

Collect ambiguities from Steps 3–5 into a single list. Resolve all at once in Step 6.

For each item, record: step, name, club, sex/category context, candidates list, file and field to patch.

---

## Step 1 — Parse Excel standings

Run `parse-individual-standings.ps1`. This script is interactive — it will prompt for missing values.

```
<skill_dir>/scripts/parse-individual-standings.ps1
  -ExcelFile   "<ExcelFile>"
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
  [-Provisional]
```

On success, report: category count and runner counts per category. Output file:
- `src/data/<Year>/<Series>/individual-standings.json`

Stop and report if the script errors.

---

## Step 2 — Correlate standings runners

```
<skill_dir>/scripts/correlate-standings-runners.ps1
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

These runners should already exist in `runners.json`. Collect into the batch:
- `WARNING: Possible match for ...` lines — note the runner name and candidates
- `WARNING: No match for ...` lines — note the name, club, and sex

---

## Step 3 — Expand award names

Only run this step if `src/data/<Year>/<Series>/awards.json` exists.

```
<skill_dir>/scripts/expand-award-names.ps1
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
```

Collect into the batch:
- Lines under `FAILED -- no match found:` — name, category, club
- Lines under `AMBIGUOUS -- name not updated:` — name, category, candidates

---

## Step 4 — Correlate award runners

Only run this step if `awards.json` exists.

```
<skill_dir>/scripts/correlate-award-runners.ps1
  -Year        <Year>
  -Series      <Series>
  -ProjectRoot "<ProjectRoot>"
  -BatchMode
```

Read the ambiguity report written to `src/data/<Year>/<Series>/awards.json.ambiguities.json`. Add each entry to the disambiguation batch, noting: `categoryId`, `position`, `name`, `club`, `inferredSex`, and `candidates`.

---

## Step 5 — Disambiguation Round

Skip if the batch is empty.

For each collected item, reason about the best resolution:
- **Name similarity** — initial + surname against `src/data/<Year>/<Series>/runners.json`
- **Sex inference** — category ID ending in `-female` → F; `-male` → M; broad categories (`female`, `male`) explicit
- **Club** — narrows when provided on the award entry
- **Age category** — narrows remaining ties

Build a formatted proposal table:

```
Disambiguation required — N items:

 #  Step              Name            Proposed                     Confidence
 1  standings         A. Johnson      Alice Johnson [id=18]        HIGH  (unique match, lytham, F)
 2  award-runners     K. Littlefair   Karen Littlefair [id=31]     HIGH  (unique match, v35-female → F)
 3  award-names       T. Unknown      — no match found —           NONE  (check runners.json manually)
```

Then use `AskUserQuestion`:

**Options:** `Accept all` / `Correct specific items` / `Handle each individually`

- **Accept all** — apply all proposals
- **Correct specific items** — ask which numbers need changing and what they should be, then apply
- **Handle each individually** — step through each with an `AskUserQuestion` listing actual candidates

### Applying resolutions

| Source step | What to patch | File |
|-------------|--------------|------|
| `correlate-standings-runners` possible/no match | Set `seriesRunnerId` on the runner entry | `src/data/<Year>/<Series>/individual-standings.json` |
| `expand-award-names` failure/ambiguous | Replace abbreviated `name` with full name on the award entry | `src/data/<Year>/<Series>/awards.json` |
| `correlate-award-runners` ambiguity | Set `seriesRunnerId` on the award entry; also fill missing `club`, `ageCategory`, `sex` from matched runner | `src/data/<Year>/<Series>/awards.json` |

---

## Step 6 — Summary

Report:
- Files written or updated (paths)
- Standings runner correlation: N matched, N need review, N failed
- Award name expansion: N expanded
- Award runner correlation: N matched, N auto-matched, N unresolved
- Any items still unresolved — flag with file and field that needs updating
```

- [ ] **Step 2: Commit**

```bash
git add .claude/plugins/process-standings/skill.md
git commit -m "feat: add process-standings skill"
```

---

## Self-Review Checklist

- [x] **Spec coverage**
  - Directory structure → Task 1
  - ProjectRoot defaults fixed → Task 2
  - Interactive prompting stripped from 5 scripts → Task 3
  - `-BatchMode` added to `correlate-award-runners.ps1` → Task 4
  - `correlate-standings-runners.ps1` created → Task 5
  - `process-results/skill.md` with all 7 steps + disambiguation pattern → Task 6
  - `process-standings/skill.md` with all 6 steps + disambiguation pattern → Task 7
  - Haiku model specified in both skill frontmatters → Tasks 6 & 7 ✓
  - Scripts reference `<skill_dir>/scripts/` paths → Tasks 6 & 7 ✓

- [x] **Placeholder scan** — no TBDs. All script changes show exact before/after code. Skill.md files show complete content.

- [x] **Consistency** — `Split-FullName`, `Normalize`, index patterns in `correlate-standings-runners.ps1` match the conventions in `correlate-global-runners.ps1`. `-BatchMode` ambiguity JSON shape matches what `process-standings/skill.md` instructs Claude to read.
