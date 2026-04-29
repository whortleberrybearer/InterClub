# Race Number Display and Search

**Date:** 2026-04-29

## Overview

Race results CSVs sometimes include a bib/race number for each runner. This number should be stored in the data, displayed in the results table, and searchable via the existing name search input.

## Data Layer

### CSV schema

Add an optional `race_number` column to result CSVs. The column may be absent (old files) or present with empty cells (runner has no number). Position in the header row is not significant — the parser uses header names.

```
position,ic_position,race_number,first_name,last_name,club,category,sex,time
1,1,42,Luke,Minns,blackpool,V35,M,19:35
9,, ,T.,Guest,Guest,SEN,M,22:14
```

### `RaceResult` type (`src/lib/types.ts`)

Add one field:

```ts
raceNumber: number | null;
```

### Parser (`src/lib/results.ts` — `parseResultsCsv`)

Read `race_number` using the existing `num()` helper:

```ts
raceNumber: num('race_number'),
```

When the column is absent, `idx('race_number')` returns `-1`, `cols[-1]` is `undefined`, and `num()` returns `null`. Old CSVs continue to parse correctly with no code changes required beyond adding the field.

## Table Display

A `Num` column is inserted between the IC and Name columns. It is hidden on mobile using `hidden sm:table-cell` — the same pattern as the existing `Pos` column. When `raceNumber` is null the cell renders `–`.

| Pos | IC | Num | Name | Cat | Club | Time |
|---|---|---|---|---|---|---|
| 1 | 1 | 42 | Luke Minns | V35 | Blackpool | 19:35 |
| 9 | – | – | T. Guest | SEN | Guest | 22:14 |

The `Num` column is added in:
- The static Astro table (`<thead>` and `<tbody>`) in both `results.astro` pages
- The `row()` function in the client-side `<script>` block (used during filtered renders)

The race number is included in the JSON data island (`results-data`) so the client-side script can access it for filtering.

## Search

The existing "Search name…" input is repurposed to search name **or** race number. No second input is added.

**Placeholder text:** `Search name or number…`

**Filter logic:** on each keystroke, the input value is checked against:
1. `firstName` (substring, case-insensitive) — existing behaviour
2. `lastName` (substring, case-insensitive) — existing behaviour
3. `raceNumber` converted to string, checked with `startsWith` — new behaviour

Typing `42` matches runners whose race number starts with `42` (e.g. 42, 420). Typing `Smith` matches on name as before. Both checks run simultaneously — no mode switching or type detection.

## Affected Files

- `src/lib/types.ts` — add `raceNumber: number | null` to `RaceResult`
- `src/lib/results.ts` — read `race_number` column in `parseResultsCsv`
- `src/pages/road-gp/[year]/[raceId]/results.astro` — add Num column, update search
- `src/pages/fell/[year]/[raceId]/results.astro` — same changes as road-gp page

## Out of Scope

- Team results, individual standings, and awards pages — race numbers are not relevant there
- HistoryRaceList — archive view does not show result detail
- Any validation that race numbers are unique within a race
