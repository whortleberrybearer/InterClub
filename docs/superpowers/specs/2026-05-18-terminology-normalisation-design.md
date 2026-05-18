# Terminology Normalisation

**Date:** 2026-05-18
**Status:** Approved

## Problem

The word `category` is overloaded across the codebase — it is used for three distinct concepts:

1. **Age band** — the runner's age group (`SEN`, `V35`, `V40`, … `JUN`)
2. **Team category ID** — identifies a team scoring group (`open`, `ladies`, `vets`, …)
3. **Individual category ID** — identifies an individual standings group (`sen-m`, `v40-f`, …)

This makes types like `TeamCategoryResult.category` and `RaceResult.category` ambiguous at a glance, and makes grep results noisy.

Sex is already consistent (`sex` field, `M`/`F` values) throughout but the TypeScript types use `string` rather than a union — this is left as-is (out of scope).

## Goals

- Every reference to an age band uses the field name `ageCategory` (TypeScript/JSON) or `age_category` (CSV).
- Every in-context ID reference (team category, individual category) uses `id` — the surrounding type makes the meaning unambiguous.
- No data values change (`SEN`, `V35`, `M`, `F`, `open`, `sen-m`, etc. are all preserved).
- All data files (CSV and JSON) are updated to match; no parser shims needed.

## Rename Table

### Age band (`SEN`, `V35`, `JUN`, etc.)

| Location | Old | New |
|---|---|---|
| `types.ts` — `RaceResult` | `.category` | `.ageCategory` |
| `types.ts` — `GlobalRunner` | `.category` | `.ageCategory` |
| `types.ts` — `SeriesRunner` | `.category` | `.ageCategory` |
| Results CSVs | `category` column | `age_category` column |
| `src/data/runners.json` | `"category"` key | `"ageCategory"` key |
| `src/data/{year}/{series}/runners.json` | `"category"` key | `"ageCategory"` key |

`IndividualStandingsRunner.ageCategory` is already correct — no change.

### Category ID references (`open`, `sen-m`, etc.)

| Location | Old | New |
|---|---|---|
| `types.ts` — `TeamCategoryResult` | `.category` | `.id` |
| `types.ts` — `TeamStandingsCategory` | `.category` | `.id` |
| `types.ts` — `TeamAward` | `.category` | `.id` |
| `types.ts` — `IndividualAward` (grouping type) | `.category` | `.id` |
| `types.ts` — `IndividualStandingsCategory` | `.category` | `.id` |
| Team results JSON: `categories[]` | `"category"` key | `"id"` key |
| Team standings JSON: `categories[]` | `"category"` key | `"id"` key |
| Awards JSON: `teamAwards[]` | `"category"` key | `"id"` key |
| Awards JSON: `individualAwards[]` | `"category"` key | `"id"` key |
| Individual standings JSON: `categories[]` | `"category"` key | `"id"` key |

## Execution Order

The TypeScript compiler is used as the change checklist for code:

1. **Rename fields in `types.ts`** — all changes above; build now has TS errors
2. **Fix all compiler errors** — follow errors through `.ts` and `.astro` files; every code call site is caught
3. **Update CSV parser** — `results.ts`: read `age_category` column instead of `category`
4. **Update JSON loaders** — `results.ts` / `runners.ts`: update any code that reads `.category` from parsed JSON for team results, standings, awards, runners
5. **Update all JSON data files** — rename keys in every `runners.json`, `awards.json`, team results, team standings, and individual standings file across all years
6. **Update all CSV data files** — rename the `category` column header to `age_category` in every results CSV
7. **`npm run build`** — confirms zero TypeScript errors and all data loads correctly

## Data File Scope

All changes are key renames only — no values change.

- **CSV files** — every `src/data/{year}/{series}/results/*.csv`; only the column header on line 1 changes
- **Global runner registry** — `src/data/runners.json`
- **Series runner files** — `src/data/{year}/{series}/runners.json` (one per year/series)
- **Awards files** — `src/data/{year}/{series}/awards.json` (past years only)
- **Team results JSON** — `src/data/{year}/{series}/results/{race-id}-teams.json` and `-teams-provisional.json`
- **Team standings** — `src/data/{year}/{series}/team-standings.json`
- **Individual standings** — `src/data/{year}/{series}/individual-standings.json`

The build catches any missed file because TypeScript will reject the old key names in parsed output.

## Out of Scope

- Tightening `sex: string` to `sex: 'M' | 'F'` in types
- Renaming age band values (`SEN`, `V35`, `JUN`, etc.)
- Renaming sex values (`M`, `F`)
- Renaming `SeriesConfig.ageCategories` — already correctly named
