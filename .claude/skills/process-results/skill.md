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

On success, report: runner count, IC runner count, team categories found, and the output files written:
- `src/data/<Year>/<Series>/results/<RaceId>[–provisional].csv`
- `src/data/<Year>/<Series>/results/<RaceId>-teams[–provisional].json`
- `src/data/<Year>/<Series>/team-standings.json` (series directory, not results/)

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

The script matches runners without bibs too, using name + club + ageCategory. Collect into the batch:
- Any `WARNING: Bib N name mismatch` lines — note the bib, CSV name, and runners.json name.
- Any `WARNING: Category mismatch for ...` lines — note the runner name, club, CSV category, and runners.json category.

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
