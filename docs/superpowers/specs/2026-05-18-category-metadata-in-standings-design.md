# Category Metadata in Standings and Awards

**Date:** 2026-05-18
**Status:** Approved

## Problem

`config.individualCategories` is verbose and duplicates information that either already exists (runner-level `sex`/`ageCategory`) or can be derived from the category ID. The 2025 road-gp config has 26 entries, most of which are purely mechanical:

```json
{ "id": "v40-male", "name": "V40 Men", "sex": "M" }
```

Similarly, `maxCountingRaces` in config is standings-specific metadata that belongs alongside the standings data it controls, not in the series config.

This means every new year requires boilerplate in config just to produce display names, drive awards column layout, and annotate the standings page — even when the information is implicit in the id or already present on every runner in the category.

Additionally, `awards.json` has no sex or name metadata, so it depends entirely on config for column layout and display names. And the 2025 road-gp awards have stray `"id": "SEN"` / `"id": "V35"` fields on individual award entries — an artefact of the terminology normalisation — which are not in the TypeScript type and currently ignored.

## Goals

- `individual-standings.json` categories carry their own `sex`, `ageCategory`, and optional `name` override
- `individual-standings.json` carries `maxCountingRaces`, removing it from config
- When category-level fields are set, runner objects do not need to repeat them
- `awards.json` individual award categories carry `sex`, `ageCategory`, and optional `name`, making them self-describing for display and column layout
- `config.individualCategories` and `config.maxCountingRaces` are removed from the schema entirely
- Stray `"id"` fields on road-gp 2025 award entries are renamed to `ageCategory` and added to `IndividualAwardEntry`
- Existing data files remain valid without migration — the new fields are additive

## Schema Changes

### `IndividualStandings`

Gains `maxCountingRaces`:

```typescript
interface IndividualStandings {
  provisional: boolean;
  maxCountingRaces?: number;  // moved from SeriesConfig; when set, page shows "Best N races count"
  races: string[];
  categories: IndividualStandingsCategory[];
}
```

### `IndividualStandingsCategory`

Gains three optional fields:

```typescript
interface IndividualStandingsCategory {
  id: string;
  sex?: 'M' | 'F';       // when set, runners inherit it (omit sex on runners)
  ageCategory?: string;   // when set, runners inherit it (omit ageCategory on runners)
  name?: string;          // explicit display name override (e.g. "Overall", "Men")
  runners: IndividualStandingsRunner[];
}
```

### `IndividualStandingsRunner`

`sex` and `ageCategory` become optional. When absent on a runner, they are inherited from the enclosing category at the point where they are needed (filter attributes, display label).

```typescript
interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex?: string;           // optional when defined on category
  ageCategory?: string;   // optional when defined on category
  total: number;
  results: Record<string, IndividualRaceResult>;
  seriesRunnerId?: number;
}
```

### `IndividualAward`

Gains three optional fields:

```typescript
interface IndividualAward {
  id: string;
  sex?: 'M' | 'F';       // drives overall/male/female column split in SeriesAwards
  ageCategory?: string;   // used for name derivation
  name?: string;          // explicit display name override
  awards: IndividualAwardEntry[];
}
```

### `IndividualAwardEntry`

Gains an optional `ageCategory` field (formalising the stray `"id"` values that already exist in 2025 road-gp awards):

```typescript
interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;
  ageCategory?: string;   // runner's age category, e.g. "SEN", "V40"; optional display hint
  seriesRunnerId?: number;
}
```

### `SeriesConfig`

`individualCategories` and `maxCountingRaces` are removed:

```typescript
interface SeriesConfig {
  ageCategories?: string[];
  teamCategories?: TeamCategory[];
  note?: string;
}
```

`IndividualCategory` type is also removed.

## Name Derivation

A shared utility `resolveIndividualCategoryName(id, sex?, ageCategory?, name?)` produces the display name used in standings tabs, awards sections, and runner profile awards summaries:

| `name` | `sex` | `ageCategory` | Result |
|--------|-------|---------------|--------|
| `"Overall"` | any | any | `"Overall"` |
| absent | `M` | `SEN` | `"Senior Men"` |
| absent | `F` | `JUN` | `"Junior Women"` |
| absent | `M` | `V40` | `"V40 Men"` |
| absent | `M` | absent | `"Men"` |
| absent | `F` | absent | `"Women"` |
| absent | absent | absent | raw `id` (fallback) |

Age label mapping: `SEN` → `"Senior"`, `JUN` → `"Junior"`, all other values (e.g. `V40`, `V55`) used as-is.

## Awards Column Layout

`ResolvedSeriesAwards` currently partitions individual awards into `overallAwards`, `maleAwards`, `femaleAwards` based on `config.individualCategories[].sex`. After this change, the partition is driven by `IndividualAward.sex` directly:

- `sex` absent → `overallAwards` (full-width)
- `sex === 'M'` → `maleAwards` (left column)
- `sex === 'F'` → `femaleAwards` (right column)

## Stray `"id"` Fields on Award Entries

The 2025 road-gp `awards.json` has `"id": "SEN"` / `"id": "V35"` etc. on individual award entries — artefacts of the automated terminology normalisation that were never added to `IndividualAwardEntry`. These are renamed to `ageCategory` and the field is added to the `IndividualAwardEntry` type as an optional display hint.

## Backward Compatibility

- `sex` and `ageCategory` on runners remain valid — existing files parse correctly
- `maxCountingRaces` in `SeriesConfig` continues to parse (TypeScript `unknown` fields are silently ignored) but is no longer read; the standings page reads it from `IndividualStandings` instead
- If a runner has no `sex`/`ageCategory` and neither does its category, filter attributes are absent (graceful degradation)
- No data migration is required for historical files; the new fields are additive

## Data File Format (New Style)

### `individual-standings.json` — top level with maxCountingRaces

```json
{
  "provisional": true,
  "maxCountingRaces": 4,
  "races": ["pendle", "hutton-roof-crags", "leo-pollard", "waddington"],
  "categories": [ ... ]
}
```

### `individual-standings.json` — category with shared sex/ageCategory

```json
{
  "id": "v40-male",
  "sex": "M",
  "ageCategory": "V40",
  "runners": [
    { "position": 1, "name": "Chris Banks", "club": "wesham", "total": 95, "results": { ... } }
  ]
}
```

Category with name override (no sex/ageCategory derivation):

```json
{
  "id": "overall",
  "name": "Overall",
  "runners": [ ... ]
}
```

### `awards.json` — individual award category

```json
{
  "id": "v40-male",
  "sex": "M",
  "ageCategory": "V40",
  "awards": [
    { "position": 1, "name": "C. Banks", "club": "wesham", "seriesRunnerId": 12 }
  ]
}
```

Award with name override:

```json
{
  "id": "overall",
  "name": "Overall",
  "awards": [ ... ]
}
```

Award entry with runner ageCategory:

```json
{ "position": 1, "name": "Katie Littlefair", "club": "preston", "ageCategory": "SEN", "seriesRunnerId": 164 }
```

## Code Changes

### `src/lib/types.ts`

- Update `IndividualStandings` — add `maxCountingRaces?`
- Update `IndividualStandingsCategory` — add `sex?`, `ageCategory?`, `name?`
- Update `IndividualStandingsRunner` — make `sex` and `ageCategory` optional
- Update `IndividualAward` — add `sex?`, `ageCategory?`, `name?`
- Update `IndividualAwardEntry` — add `ageCategory?`
- Remove `IndividualCategory` interface
- Remove `individualCategories?` and `maxCountingRaces?` from `SeriesConfig`
- Update `ResolvedSeriesAwards` comments to remove references to `config category`

### `src/lib/results.ts`

Add `resolveIndividualCategoryName(id, sex?, ageCategory?, name?): string`.

Exported and unit-tested as a pure function.

### `src/pages/fell/[year]/individual-standings.astro` and `src/pages/road-gp/[year]/individual-standings.astro`

- Replace `categoryById` config lookup with `resolveIndividualCategoryName` called on the category object
- Read `maxCountingRaces` from `standings.maxCountingRaces` instead of `config.maxCountingRaces`
- For runner rows, compute `effectiveSex = runner.sex ?? cat.sex` and `effectiveAgeCategory = runner.ageCategory ?? cat.ageCategory` inline in the template — no data transformation in the loader

### `src/pages/fell/[year]/index.astro` and `src/pages/road-gp/[year]/index.astro`

Replace `resolveIndividualCategory(ia.id)` config lookup with direct use of `ia.sex` / `ia.ageCategory` / `ia.name` for partitioning and display.

### `src/lib/runners.ts`

Replace config `individualCategories` lookup with `resolveIndividualCategoryName` called on the award's own fields.

### `src/data/2025/road-gp/awards.json`

Rename stray `"id"` fields on `IndividualAwardEntry` objects to `"ageCategory"`.

### `src/data/config` files (all years)

Remove `individualCategories` and `maxCountingRaces` from all `config.json` files. Existing runner-level `sex`/`ageCategory` fields continue to work.

## Out of Scope

- Migrating existing `individual-standings.json` files to use category-level fields (opt-in; old format continues to work)
- Migrating existing `awards.json` files to add category-level `sex`/`ageCategory` (opt-in)
- Moving `maxCountingRaces` into existing historical `individual-standings.json` files (opt-in)
- Tightening `sex: string` to `sex: 'M' | 'F'` on runner types (separate concern)
- Changes to team categories or team standings
