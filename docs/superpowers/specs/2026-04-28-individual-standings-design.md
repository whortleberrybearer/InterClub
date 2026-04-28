# Individual Standings — Design Spec

**Date:** 2026-04-28  
**Series:** Fell Championship & Road GP (both series, same pattern)  
**Status:** Approved

---

## Overview

Add individual standings pages to the InterClub site. Standings are pre-computed externally and dropped as a JSON file alongside the existing `team-standings.json`. The page is only generated at build time when the file exists.

A key difference from team standings: not all races a runner completes count towards their total — only their best N do. The non-counting results must be visually indicated.

---

## 1. Config Changes (`src/data/{year}/{series}/config.json`)

### Rename

`categories` → `ageCategories` (the existing field was misnamed; it holds age category bands used for result filtering, not the full category concept).

This rename must be reflected everywhere the config is consumed:
- `src/lib/types.ts` (`SeriesConfig.categories` → `SeriesConfig.ageCategories`)
- `src/lib/results.ts` (any reference to `config.categories`)
- Any Astro pages that destructure `config.categories`

### New fields

```json
{
  "ageCategories": ["SEN", "V35", "V40", "V50", "V60", "V70"],
  "maxCountingRaces": 3,
  "individualCategories": [
    { "id": "sen-m", "name": "Senior Men"   },
    { "id": "sen-f", "name": "Senior Women" },
    { "id": "v40-m", "name": "V40 Men"      },
    { "id": "v40-f", "name": "V40 Women"    },
    { "id": "v35-f", "name": "V35 Women"    }
  ],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6 },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4 }
  ]
}
```

**`maxCountingRaces`** — optional integer. When present, the page displays the rule (e.g. *"Best 3 races count"*) and visually marks non-counting results. When absent, all results count and no indicator is shown.

**`individualCategories`** — optional array of `{ id, name }`. The `id` is referenced by the standings JSON. The categories defined here determine which tabs appear on the standings page. The external process that generates the standings decides which runners belong to which category — the site just displays what it receives.

---

## 2. Individual Standings JSON (`src/data/{year}/{series}/individual-standings.json`)

File absence means no individual standings page is generated for that year/series.

### Schema

```json
{
  "provisional": false,
  "races": ["fell-race-1", "fell-race-2", "fell-race-3", "fell-race-4"],
  "categories": [
    {
      "category": "sen-m",
      "runners": [
        {
          "position": 1,
          "name": "Luke Minns",
          "club": "blackpool",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 47,
          "results": {
            "fell-race-1": { "points": 25, "counting": true },
            "fell-race-3": { "points": 22, "counting": true }
          }
        },
        {
          "position": 2,
          "name": "J. Smith",
          "club": "wesham",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 38,
          "results": {
            "fell-race-1": { "points": 20, "counting": true },
            "fell-race-2": { "points": 18, "counting": true },
            "fell-race-3": { "points": 15, "counting": false }
          }
        }
      ]
    }
  ]
}
```

### Field notes

| Field | Notes |
|---|---|
| `provisional` | When `true`, a warning badge is shown on the page |
| `races` | Ordered list of race IDs — defines column order in the table |
| `categories[].category` | References an `id` in `config.individualCategories` |
| `runners[].sex` | `"M"` or `"F"` — stored separately for filtering |
| `runners[].ageCategory` | e.g. `"SEN"`, `"V40"` — stored separately for filtering |
| `runners[].results` | Sparse map — only races the runner actually ran are present; no `null` entries |
| `results[raceId].counting` | `false` when the runner ran more races than `maxCountingRaces` and this result didn't score |
| `runners[].total` | Pre-computed and stored explicitly |

---

## 3. TypeScript Types (`src/lib/types.ts`)

```typescript
// Rename in SeriesConfig:
export interface SeriesConfig {
  ageCategories: string[];           // renamed from categories
  maxCountingRaces?: number;
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
}

// New types:
export interface IndividualCategory {
  id: string;
  name: string;
}

export interface IndividualRaceResult {
  points: number;
  counting: boolean;
}

export interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex: string;          // 'M' or 'F'
  ageCategory: string;  // e.g. 'SEN', 'V40'
  total: number;
  results: Record<string, IndividualRaceResult>;  // keyed by race id
}

export interface IndividualStandingsCategory {
  category: string;   // id → IndividualCategory lookup via config
  runners: IndividualStandingsRunner[];
}

export interface IndividualStandings {
  provisional: boolean;
  races: string[];
  categories: IndividualStandingsCategory[];
}
```

---

## 4. Data Loading (`src/lib/results.ts`)

- Update `config.categories` references → `config.ageCategories` throughout
- Add `getIndividualStandingsStaticPaths(series: Series)` — mirrors `getTeamStandingsStaticPaths`:
  - Loads `individual-standings.json` files via `import.meta.glob`
  - Parses path to extract year
  - Loads the matching `clubs.json` and `config.json`
  - Returns an array of static path entries; empty array when no files found

---

## 5. New Page (`src/pages/{series}/[year]/individual-standings.astro`)

Generated only when `individual-standings.json` exists. Follows the same static paths pattern as `team-standings.astro`.

Linked from the series year index page (e.g. `/fell/2026`) when it exists — same treatment as the team standings link.

### Heading area

- Title: *"Individual Standings"*
- Subtitle: *"{year} Inter Club Fell Championship"*
- Provisional badge (when `provisional: true`)
- When `maxCountingRaces` is set: a note below the title — *"Best {n} races count"*

### Category tabs

One tab per entry in `standings.categories`, labelled using the matching `config.individualCategories[].name`. Tab pattern identical to team standings.

### Desktop table (≥ sm breakpoint)

Columns: `#` · `Name` · `Club` · `Category` · *one column per race in `standings.races`* · `Total`

**Category column** — displays `sex + ageCategory` as a combined label: `MSEN`, `FV40`, `FV35` etc.

**Race columns** — header links to the individual results page when results exist (same as team standings). For each runner/race cell:
- Runner ran this race, result counts → show points normally
- Runner ran this race, result does not count → show points dimmed with strikethrough
- Runner did not run this race → empty cell (no dash — keeps the table uncluttered)

**Filter controls** — above the table, per category tab:
- Sex toggle: `M` / `F` buttons (shows all when none selected)
- Age category filter: one toggle per distinct age category present in the tab's data
- Filters operate on the underlying `sex` and `ageCategory` fields independently
- Row position numbers are left as-is (not recalculated on filter — original standings positions are preserved)

### Mobile view (< sm breakpoint)

Expandable accordion rows per runner:
- Collapsed: `position` · `Name` · **Total** · chevron
- Expanded:
  - `Club` (labelled)
  - `Category` (combined label, e.g. `FV40`)
  - Race result chips — one per race the runner actually ran, labelled with `race.shortName` (falls back to race id)
    - Counting result: solid chip background, points value
    - Non-counting result: dimmed chip, points value with strikethrough
  - Chips link to the individual results page where available
- Filter controls appear above the list (same M/F + age category toggles, compact)

---

## 6. Navigation

The series year index page (`/fell/{year}`, `/road-gp/{year}`) gains an *"Individual Standings"* link alongside the existing *"Team Standings"* link. The link is only rendered when the individual standings page exists for that year.

---

## Out of Scope

- Computing standings from CSVs at build time — standings are always pre-computed externally
- Runner profiles or cross-race linking by runner identity
- Historical data migration — this spec covers the format only; data entry is a separate process
