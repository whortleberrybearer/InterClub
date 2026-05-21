# Results Ingestion Workflows — Design Spec

**Date:** 2026-05-21
**Scope:** Two Claude Code skills that orchestrate the existing PowerShell scripts for race results ingestion and end-of-season standings/awards processing.

---

## Problem

The existing scripts (`parse-results.ps1`, `correlate-runners.ps1`, etc.) are solid batch tools but run independently. Each reports ambiguities and failures to the console and either continues or pauses with `Read-Host`. There is no coordinated pipeline, and the interactive disambiguation experience is per-item and sequential.

The goal is to wrap these scripts in two Claude Code skills that:
- Run the full pipeline in the correct order
- Collect all ambiguities across steps
- Use AI reasoning to propose the best resolution for each
- Present the full batch for user review and correction in a single step
- Apply the confirmed resolutions to the data files

---

## Approach

**Claude as orchestrator.** Scripts remain the authoritative data processors. Claude runs them via the PowerShell tool, reads their console output for reported issues, reasons about each ambiguity, presents a batch proposal table, and patches data files with the confirmed resolutions. Only one script (`correlate-award-runners.ps1`) requires a code change; one new script is created.

---

## Directory Structure

Each skill is a self-contained directory under `.claude/plugins/`. The skill's PowerShell scripts live alongside the `skill.md` rather than in the repo-level `scripts/` directory. This keeps each skill cohesive and portable — the instruction file and its tools evolve together.

```
.claude/plugins/
  process-results/
    skill.md
    scripts/
      parse-results.ps1
      correlate-runners.ps1
      correlate-global-runners.ps1
      expand-team-results-names.ps1
      correlate-team-runners.ps1
  process-standings/
    skill.md
    scripts/
      parse-individual-standings.ps1
      correlate-standings-runners.ps1   ← new
      expand-award-names.ps1
      correlate-award-runners.ps1       ← -BatchMode added
```

The existing files in `scripts/` are **moved** (not copied) into their respective skill directories. The repo-level `scripts/` directory is left with only `parse-road-gp-awards.js`, which is not part of either workflow.

The `skill.md` references scripts via paths relative to the skill directory (e.g. `./scripts/parse-results.ps1`), so Claude always resolves them correctly regardless of the working directory.

---

## Architecture

```
User invokes skill (or natural language equivalent)
     │
     ▼
Claude collects parameters (file paths, year, series, race ID, provisional)
     │
     ▼
Claude runs each script step via PowerShell tool
     │
     ├─ Script exits cleanly → proceed to next step
     │
     └─ Script reports ambiguities / failures in output
              │
              ▼
         Claude collects all items into a disambiguation batch
              │
              ▼
         Disambiguation round: Claude proposes resolutions →
         presents batch table → user accepts or corrects →
         Claude patches affected data files
              │
              ▼
         Proceeds to next step (re-runs affected step to verify if needed)
```

**PowerShell scripts handle:** Excel COM automation, all data transformations, file I/O.
**Claude handles:** Orchestration, parsing console output for issues, AI-powered disambiguation proposals, the interactive review step, patching resolved data into files.

---

## Skill 1: `process-results`

**Trigger:** `/process-results` or natural language (e.g. "process the blackpool results file").

### Steps

1. **Collect parameters** — prompt for any not supplied: Excel file path, year, series (`road-gp`/`fell`), race ID, provisional flag.

2. **Parse Excel** — run `parse-results.ps1`. Confirm on completion: runner count, team categories found, output files written (`{raceId}.csv`, `{raceId}-teams.json`, `team-standings.json`).

3. **Correlate individual runners** — run `correlate-runners.ps1`. Collect any name-mismatch warnings into the disambiguation batch.

4. **Correlate global runners** — run `correlate-global-runners.ps1`. Collect any "needs manual review" items (same name, different club/sex/category) into the disambiguation batch.

5. **Expand team scorer names** — run `expand-team-results-names.ps1`. Collect any `ERROR: Could not resolve` lines into the disambiguation batch.

6. **Correlate team scorer IDs** — run `correlate-team-runners.ps1`. Collect any `FAILURES` and `AMBIGUOUS` items into the disambiguation batch.

7. **Disambiguation round** — if any items were collected across steps 3–6, run the disambiguation pattern (see below). Apply confirmed resolutions. Re-run only the affected downstream script(s) to verify.

8. **Summary** — list all files written, runner correlation coverage, any remaining unresolved items flagged for manual attention.

---

## Skill 2: `process-standings`

**Trigger:** `/process-standings` or natural language (e.g. "process the end of season standings").

### Steps

1. **Collect parameters** — Excel file path, year, series, provisional flag.

2. **Parse Excel standings** — run `parse-individual-standings.ps1`. Confirm categories and runner counts on completion.

3. **Correlate standings runners** — run `correlate-standings-runners.ps1` (new script). Collect any unmatched runners into the disambiguation batch. Since standings runners should already exist in `runners.json`, the script does not create new entries — it reports failures for any that don't match.

4. **Expand award names** — run `expand-award-names.ps1`. Collect any `FAILED` and `AMBIGUOUS` items.

5. **Correlate award runners** — run `correlate-award-runners.ps1 -BatchMode`. Read the ambiguity report JSON it writes on exit and add all items to the disambiguation batch.

6. **Disambiguation round** — present full batch proposal table for items from steps 3–5. Apply resolutions. Also fills in any missing `club`, `ageCategory`, `sex` fields on award entries from the matched runner data.

7. **Summary** — list all files written, runner correlation coverage, unresolved items.

---

## Disambiguation Pattern

Used by both skills whenever ambiguities are collected from one or more steps.

### Collection

As each script runs, Claude captures reported issues from stdout into a structured list. Each item records:
- Source step and script
- Abbreviated or unmatched name
- Club and category context
- Candidate list (if any)
- File path and location to patch if resolved

### Proposal

Claude reasons over each item using:
- Name similarity — initial + surname matching against `runners.json`
- Sex inference from category ID (e.g. `ladies` team → F, `v35-female` award → F)
- Club context from the result row or award entry
- Position/category context for tiebreaking between candidates with the same name

### Presentation

Claude outputs a formatted table annotated with confidence:

```
Disambiguation required — 4 items:

 #  Source              Abbreviated       Proposed                    Confidence
 1  team-scorers        M. Swarbrick      Matthew Swarbrick [id=42]   HIGH  (unique match, wesham)
 2  team-scorers        J. Smith          John Smith [id=15]           MED   (2 candidates; male open team → M)
 3  award-runners       K. Littlefair     Karen Littlefair [id=31]     HIGH  (unique match, v35-female → F)
 4  global-runners      A. Danson         — no match found —           NONE  (suggest: create new global runner)
```

Followed by a single `AskUserQuestion`:

> **Accept all proposals?** — `Accept all` / `Correct specific items` / `Handle each individually`

- **Accept all** → Claude applies all patches immediately.
- **Correct specific items** → Claude asks in plain text which numbers need changing and what they should be. User replies (e.g. "2 should be Janet Smith id=28, 4 create with club=wesham sex=F cat=V40"). Claude parses and applies.
- **Handle each individually** → Claude steps through each item with its own `AskUserQuestion`, listing the actual candidates as options.

### Apply

Claude patches each affected file directly:
- Sets `seriesRunnerId` on CSV rows, team scorer entries, standings runners, and award entries
- Replaces abbreviated names with full names in team results and awards JSON
- Fills missing `club`, `ageCategory`, `sex` fields on award entries from the matched runner

---

## Script Adaptations

### `correlate-award-runners.ps1` — add `-BatchMode` switch

The only script that currently blocks on `Read-Host`. When `-BatchMode` is set:
- Collects all ambiguities without prompting
- Writes a JSON report to `{awardsFile}.ambiguities.json`
- Exits with a non-zero code if any ambiguities exist
- Existing interactive mode is unchanged

Report format:
```json
[
  {
    "categoryId": "v35-female",
    "position": 1,
    "name": "K. Littlefair",
    "club": "wesham",
    "inferredSex": "F",
    "candidates": [
      { "id": 31, "firstName": "Karen", "lastName": "Littlefair", "club": "wesham", "sex": "F", "category": "V35" }
    ]
  }
]
```

### New: `correlate-standings-runners.ps1`

Assigns `seriesRunnerId` to each runner entry in `individual-standings.json` by matching against `{year}/{series}/runners.json`.

**Match criteria:** `firstName` + `lastName` + `club` + `category` (case-insensitive), same rules as the other correlation scripts.

**Behaviour:**
- Exact match → sets `seriesRunnerId` on the standings runner entry
- Possible match (name matches, other field differs) → reports for review, does not assign
- No match → reports failure, does not create new entries (standings runners must already exist)
- Writes updated `individual-standings.json` in-place
- Supports `-DryRun` switch consistent with other scripts

**Parameters:** `ExcelFile` (not needed — reads `individual-standings.json` directly), `Year`, `Series`, `ProjectRoot`, `DryRun`.

### All other scripts — interactive prompting removed

All scripts except `parse-results.ps1` and `parse-individual-standings.ps1` currently contain `Prompt-Value` / `Read-Host` blocks for collecting parameters interactively. Since the skill always supplies all parameters as arguments, this code is removed. Scripts become pure data processors: all parameters required, no fallback prompting.

`parse-results.ps1` and `parse-individual-standings.ps1` retain their interactive prompting — they involve Excel COM automation and may occasionally be run directly for testing or debugging.

Console output format is already consistent and parseable by Claude:
- `Write-Warning` lines for name mismatches and unknown runners
- `FAILURES` / `AMBIGUOUS` summary blocks from `correlate-team-runners.ps1` and `expand-team-results-names.ps1`
- `needs manual review` entries from `correlate-global-runners.ps1`

---

## Out of Scope

- Changes to `parse-results.ps1` or `parse-individual-standings.ps1`
- Any changes to the site's Astro/TypeScript code
- Automated git commit after ingestion (can be a follow-up)
- Support for multiple races in a single invocation
