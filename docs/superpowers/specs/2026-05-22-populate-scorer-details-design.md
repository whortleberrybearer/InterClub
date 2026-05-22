# Design: Populate Scorer Details Script

**Date:** 2026-05-22
**Status:** Approved

## Overview

A PowerShell script that populates the `name` field on scorer entries in fell team results JSON files. Most fell results contain scorer positions but no names. The script calculates category-relative positions from the individual results CSV, validates club assignments, and writes names once all issues are resolved.

## Location and Invocation

```powershell
# Dry run (report only — default):
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle

# Write mode (only executes if zero mismatches):
.\scripts\Populate-ScorerDetails.ps1 -Race 2025/fell/pendle -Write
```

The `-Race` parameter is `year/series/raceId`. The script derives file paths relative to `src/data/`:

- CSV: `src/data/{year}/{series}/results/{raceId}.csv`
- Teams JSON: `src/data/{year}/{series}/results/{raceId}-teams.json`

## Category Eligibility Rules

Eligibility is inferred from the team category `id` using pattern matching. All categories require a non-empty `ic_position` (guest runners are excluded). Runners within a category are ranked by `ic_position` ascending.

| ID pattern | Eligible runners |
|---|---|
| `open`, `overall`, `mixed` | All IC runners |
| `ladies`, `women`, `female` | `sex = F` |
| `vets`, `veterans` | age_category numeric part ≥ 40 |
| `v40` | ≥ 40 |
| `v45` | ≥ 45 |
| `v50` | ≥ 50 |
| `v55` | ≥ 55 |
| `v60` | ≥ 60 |
| `v65` | ≥ 65 |
| `v70` | ≥ 70 |

The numeric threshold is extracted from the id (e.g. `v50` → 50). Age categories in the CSV follow the pattern `SEN`, `V40`, `V50`, `V60`, `V70`, `V80`, etc. The numeric part is extracted by stripping the leading `V`.

An unrecognised category id causes the script to exit with an error listing the unmatched id.

## Report Format

The script prints a categorised report to the console with colour coding (green for matches, red for mismatches, yellow for warnings).

```
Processing: 2025/fell/pendle
CSV: 43 inter-club runners

══ OPEN (all runners) ══════════════════════════

  chorley  (scorerCount: 5)
    Pos  7  →  John Griffiths      (preston)   ❌  expected chorley
    Pos  8  →  John Rainford       (preston)   ❌  expected chorley
    Pos 11  →  Amelia Websdale     (preston)   ❌  expected chorley
    Pos 16  →  Darren McDermott    (preston)   ❌  expected chorley

  wesham  (scorerCount: 5)
    Pos  3  →  Thomas Crabtree     (wesham)    ✓
    ...

══ VETS (V40+) ══════════════════════════════════

  chorley  (scorerCount: 4)
    Pos  2  →  David Cowburn       (chorley)   ✓
    Pos  6  →  Paul Bass           (chorley)   ✓
    Pos  7  →  Chris Farrimond     (chorley)   ✓
    Pos 10  →  Mark Ellithorn      (chorley)   ✓

══ SUMMARY ══════════════════════════════════════

  ✓  18 scorers matched
  ❌  12 mismatches
  ⚠   0 positions not found (position exceeds eligible runner count)

  Fix all mismatches before running with -Write.
```

Three result states per scorer:
- **Match (✓):** calculated runner's club matches the scorer's expected club
- **Mismatch (❌):** calculated runner's club does not match — shown in red with the actual club found
- **Not found (⚠):** the position number exceeds the count of eligible runners in the CSV — shown in yellow

## Write Behaviour

When `-Write` is passed:

- Any mismatches or not-found positions → exit without touching the file; print a summary of all issues
- Zero issues → add `"name": "F. Lastname"` to each scorer object, preserving all existing fields; write the file back using `ConvertTo-Json -Depth 10`; print `✓ Written: <path>`

**Name format:** first character of `first_name` + `. ` + `last_name`. Examples: `"Luke Minns"` → `"L. Minns"`, `"Simon J Shaw"` → `"S. Shaw"`. This matches the existing schema convention.

**Idempotency:** scorers that already have a `name` field are skipped for population but still validated for club match. Re-running on already-populated files is safe.

## Error Cases

| Condition | Behaviour |
|---|---|
| CSV file not found | Exit with error |
| Teams JSON not found | Exit with error |
| Unrecognised category id | Exit with error listing the id |
| Scorer position > eligible runner count | Reported as ⚠ not-found; blocks `-Write` |
| Club mismatch | Reported as ❌; blocks `-Write` |

## Constraints

- Guest runners (empty `ic_position`) are never eligible scorers in any category
- The script does not recalculate or validate `points`, `total`, or club `position` fields — only scorer names and club assignments are checked
- The script processes one race at a time; run separately for each race file that needs updating
