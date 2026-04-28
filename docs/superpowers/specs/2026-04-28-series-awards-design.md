# Series Awards Design

## Overview

Display end-of-season award winners on the series year index page (e.g. `/fell/2026/`, `/road-gp/2026/`). Awards are manually curated in a per-year, per-series JSON file. The section appears above the race list only when the file exists.

---

## Data

### `src/data/{year}/{series}/awards.json`

```json
{
  "teamAwards": [
    { "category": "open",   "club": "wesham" },
    { "category": "ladies", "club": "lytham" },
    { "category": "vets",   "club": "preston" }
  ],
  "individualAwards": [
    {
      "category": "sen-m",
      "awards": [
        { "position": 1, "name": "L. Minns", "club": "blackpool" },
        { "position": 2, "name": "J. Smith", "club": "wesham" },
        { "position": 3, "name": "T. Guest", "club": "red-rose" }
      ]
    },
    {
      "category": "sen-f",
      "awards": [
        { "position": 1, "name": "A. Jones",   "club": "chorley" },
        { "position": 3, "name": "B. Clarke",  "club": "blackpool" }
      ]
    }
  ]
}
```

- `teamAwards[].category` — references `teamCategories[].id` in the series `config.json`; display name resolved at build time
- `individualAwards[].category` — references `individualCategories[].id` in the series `config.json`
- `individualAwards[].awards[].position` — explicit; gaps are allowed (e.g. no position 2 entry means that place was not awarded)
- One team award per category (no positions array); multiple individual placements per category

### Config change: `individualCategories[].sex`

Add an optional `sex` field to each entry in `individualCategories` in `config.json`:

```json
{
  "individualCategories": [
    { "id": "overall",  "name": "Overall"       },
    { "id": "sen-m",   "name": "Senior Men",   "sex": "M" },
    { "id": "sen-f",   "name": "Senior Women", "sex": "F" },
    { "id": "v40-m",   "name": "V40 Men",      "sex": "M" },
    { "id": "v40-f",   "name": "V40 Women",    "sex": "F" }
  ]
}
```

- `"sex": "M"` → rendered in the Male column
- `"sex": "F"` → rendered in the Female column
- absent / `undefined` → rendered full-width in the Overall zone above the M/F columns

This field is optional and only relevant when `awards.json` exists; the standings pages are unaffected.

---

## Types (`src/lib/types.ts`)

```typescript
export interface TeamAward {
  category: string;
  club: string;
}

export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;
}

export interface IndividualAward {
  category: string;
  awards: IndividualAwardEntry[];
}

export interface SeriesAwards {
  teamAwards: TeamAward[];
  individualAwards: IndividualAward[];
}
```

Also extend `IndividualCategory` (already in `types.ts` as part of `SeriesConfig`) with an optional `sex` field:

```typescript
export interface IndividualCategory {
  id: string;
  name: string;
  sex?: 'M' | 'F';
}
```

---

## Data loading (`src/lib/results.ts`)

Two new functions following the same pattern as `hasTeamStandings` / `getTeamStandings`:

- `hasAwards(year: number, series: Series): boolean` — returns true if `awards.json` exists for that year/series
- `getAwards(year: number, series: Series): SeriesAwards` — loads and returns the awards data via `import.meta.glob`

---

## Page changes

### `src/pages/fell/[year]/index.astro` and `src/pages/road-gp/[year]/index.astro`

When `hasAwards(year, series)` is true:

1. Load `getAwards(year, series)` and `getSeriesConfig(year, series)`
2. Resolve display names by looking up each `category` ID against `config.teamCategories` and `config.individualCategories`
3. Partition `individualAwards` into three groups based on the resolved category's `sex` field: `overall` (no sex), `male` (sex = M), `female` (sex = F)
4. Pass resolved data as an `awards` prop to `RaceList`

Resolved shape passed into `RaceList` (avoids any config dependency in the component). These four interfaces must be added to `src/lib/types.ts` and exported so both index pages and `RaceList.astro` can import them:

```typescript
export interface ResolvedTeamAward {
  categoryName: string;
  clubName: string;  // looked up from clubs.json
}

export interface ResolvedIndividualAwardEntry {
  position: number;
  name: string;
  clubName: string;  // looked up from clubs.json
}

export interface ResolvedIndividualAward {
  categoryName: string;
  awards: ResolvedIndividualAwardEntry[];
}

export interface ResolvedSeriesAwards {
  teamAwards: ResolvedTeamAward[];
  overallAwards: ResolvedIndividualAward[];
  maleAwards: ResolvedIndividualAward[];
  femaleAwards: ResolvedIndividualAward[];
}
```

### `src/components/RaceList.astro`

Add optional `awards?: ResolvedSeriesAwards` prop. When present, render `<SeriesAwards awards={awards} />` between the standings-links row and the race cards.

---

## Component: `src/components/SeriesAwards.astro`

Renders the full awards section given `ResolvedSeriesAwards`. No config or data loading — display only.

### Layout

```
┌─────────────────────────────────────────────┐
│  🏆 Series Winners                          │
│                                             │
│  TEAM                                       │
│  [🏆 Open: Wesham] [🏆 Ladies: Lytham] ...  │  ← pill badges, flex-wrap
│                                             │
│  INDIVIDUAL                                 │
│  ┌─────────────────────────────────────┐    │
│  │ Overall (full width)               │    │  ← only if overallAwards.length > 0
│  │  🥇 L. Minns   Blackpool WF&AC     │    │
│  └─────────────────────────────────────┘    │
│  ┌──────────────┐  ┌──────────────┐         │
│  │ MALE         │  │ FEMALE       │         │
│  │ Senior Men   │  │ Senior Women │         │
│  │  🥇 A. Jones  │  │  🥇 B. Smith │         │
│  │  🥈 P. Brown  │  │  🥈 C. Hall  │         │
│  │ V40 Men      │  │ V40 Women    │         │
│  │  🥇 D. Evans  │  │  🥇 E. Fox   │         │
│  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────┘
```

### Position display

| Position | Display |
|----------|---------|
| 1 | 🥇 (gold medal emoji) |
| 2 | 🥈 (silver medal emoji) |
| 3 | 🥉 (bronze medal emoji) |
| 4+ | plain ordinal text: "4th", "5th", etc. |

Skipped positions (gaps in the `awards` array) simply have no row — no placeholder shown.

### Conditional rendering

- The entire section is omitted if `awards` prop is not provided
- The Overall zone is omitted if `overallAwards` is empty
- The M/F grid is omitted if both `maleAwards` and `femaleAwards` are empty
- If only one of male/female has entries, it still renders in a two-column grid (the empty column is blank)

---

## File checklist

| File | Change |
|------|--------|
| `src/lib/types.ts` | Add `TeamAward`, `IndividualAwardEntry`, `IndividualAward`, `SeriesAwards`; add `sex?` to `IndividualCategory`; add `ResolvedTeamAward`, `ResolvedIndividualAwardEntry`, `ResolvedIndividualAward`, `ResolvedSeriesAwards` |
| `src/lib/results.ts` | Add `hasAwards`, `getAwards` |
| `src/pages/fell/[year]/index.astro` | Load awards, resolve names, pass to RaceList |
| `src/pages/road-gp/[year]/index.astro` | Same |
| `src/components/RaceList.astro` | Accept `awards?` prop, render `SeriesAwards` above race cards |
| `src/components/SeriesAwards.astro` | New component — display only |
| `src/data/{year}/{series}/awards.json` | New data file per year/series as needed |
