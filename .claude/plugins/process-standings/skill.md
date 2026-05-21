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

Collect ambiguities from Steps 2–4 into a single list. Resolve all at once in Step 5.

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
