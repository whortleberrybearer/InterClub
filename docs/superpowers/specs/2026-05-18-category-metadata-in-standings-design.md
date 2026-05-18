# Category Metadata in Standings and Awards

**Date:** 2026-05-18
**Status:** Approved

## Problem

`config.individualCategories` is verbose and duplicates information that either already exists (runner-level `sex`/`ageCategory`) or can be derived from the category ID. The 2025 road-gp config has 26 entries, most of which are purely mechanical:

```json
{ "id": "v40-male", "name": "V40 Men", "sex": "M" }
```

This means every new year requires a full category list in config just to produce display names and drive awards column layout — even when the information is implicit in the id or already present on every runner in the category.

Additionally, `awards.json` has no sex metadata, so it depends entirely on config for column layout. And the 2025 road-gp awards have stray `"id": "SEN"` / `"id": "V35"` fields on individual award entries — an artefact of the terminology normalisation — which are not in the TypeScript type and currently ignored.

## Goals

- `individual-standings.json` categories carry their own `sex`, `ageCategory`, and optional `name` override
- When category-level fields are set, runner objects do not need to repeat them
- `awards.json` individual award categories carry the same fields, making them self-describing for display and column layout
- `config.individualCategories` is removed from the schema entirely
- Stray `"id"` fields on road-gp 2025 award entries are cleaned up (removed)
- Existing data files remain valid without migration — the new fields are additive

## Schema Changes

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

Gains the same three optional fields:

```typescript
interface IndividualAward {
  id: string;
  sex?: 'M' | 'F';       // drives overall/male/female column split in SeriesAwards
  ageCategory?: string;   // used for name derivation
  name?: string;          // explicit display name override
  awards: IndividualAwardEntry[];
}
```

### `SeriesConfig`

`individualCategories` is removed:

```typescript
interface SeriesConfig {
  ageCategories?: string[];
  maxCountingRaces?: number;
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

The 2025 road-gp `awards.json` has `"id": "SEN"` / `"id": "V35"` etc. on individual award entries — artefacts of the automated terminology normalisation that were never added to `IndividualAwardEntry`. These are removed as part of this change. Since `ageCategory` now lives at the category level (not the entry level), no replacement field is needed on entries.

## Backward Compatibility

- `sex` and `ageCategory` on runners remain valid — existing files parse correctly
- If a runner has no `sex`/`ageCategory` and neither does its category, filter attributes are absent (graceful degradation, same as today for categories with no config entry)
- No data migration is required for historical files; the new format is opt-in

## Data File Format (New Style)

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

## Code Changes

### `src/lib/types.ts`

- Update `IndividualStandingsCategory` — add `sex?`, `ageCategory?`, `name?`
- Update `IndividualStandingsRunner` — make `sex` and `ageCategory` optional
- Update `IndividualAward` — add `sex?`, `ageCategory?`, `name?`
- Remove `IndividualCategory` interface
- Remove `individualCategories?` from `SeriesConfig`
- Update `ResolvedSeriesAwards` comments to remove references to `config category`

### `src/lib/results.ts`

Add `resolveIndividualCategoryName(id, sex?, ageCategory?, name?): string`.

Exported and unit-tested as a pure function.

### `src/pages/fell/[year]/individual-standings.astro` and `src/pages/road-gp/[year]/individual-standings.astro`

Replace `categoryById` config lookup with `resolveIndividualCategoryName` called on the category object. For runner rows, compute `effectiveSex = runner.sex ?? cat.sex` and `effectiveAgeCategory = runner.ageCategory ?? cat.ageCategory` inline in the template — no data transformation in the loader.

### `src/pages/fell/[year]/index.astro` and `src/pages/road-gp/[year]/index.astro`

Replace `resolveIndividualCategory(ia.id)` config lookup with direct use of `ia.sex` / `ia.ageCategory` / `ia.name` for partitioning and display.

### `src/lib/runners.ts`

Replace config `individualCategories` lookup with `resolveIndividualCategoryName` called on the award's own fields.

### `src/data/2025/road-gp/awards.json`

Remove stray `"id"` fields from all `IndividualAwardEntry` objects.

### `src/data/config` files (all years)

Remove `individualCategories` arrays. No other changes needed — existing runner-level `sex`/`ageCategory` fields continue to work.

## Out of Scope

- Migrating existing `individual-standings.json` files to use category-level fields (opt-in; old format continues to work)
- Migrating existing `awards.json` files to add category-level `sex`/`ageCategory` (opt-in)
- Tightening `sex: string` to `sex: 'M' | 'F'` on runner types (separate concern)
- Changes to team categories or team standings
