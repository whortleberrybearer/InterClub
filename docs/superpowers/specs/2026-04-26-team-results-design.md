# Team Results Design

**Date:** 2026-04-26
**Scope:** Per-race team results display (season standings out of scope)

## Overview

Add a team results page for each race in both series. Team results are computed externally and stored as a JSON file alongside the individual results CSV. The page displays each team category (Open, Ladies, Vets, etc.) with ranked clubs, their points earned, and the scorers who contributed to the total.

## Data Format

### config.json — team categories

Each year/series `config.json` gains an optional `teamCategories` array. Optional so existing files without it don't break.

```json
{
  "categories": ["SEN", "V35", "V40", "..."],
  "teamCategories": [
    { "id": "open",   "name": "Open",    "scorerCount": 10 },
    { "id": "ladies", "name": "Ladies",  "scorerCount": 5  },
    { "id": "fv40",   "name": "FV40",    "scorerCount": 5  },
    { "id": "vets",   "name": "Vets",    "scorerCount": 6  },
    { "id": "vet50s", "name": "Vet 50s", "scorerCount": 4  },
    { "id": "vet60s", "name": "Vet 60s", "scorerCount": 3  }
  ]
}
```

Categories and their `scorerCount` change between series and year — this config is the single source of truth for that.

### Team results file

One JSON file per race, placed alongside the individual results CSV:

```
src/data/{year}/{series}/results/{race-id}-teams.json
```

File absence means no team results exist for that race — same convention as individual results CSVs.

```json
{
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "points": 7,
          "club": "wesham",
          "total": 175,
          "scorers": [
            { "name": "M. Swarbrick", "position": 5 },
            { "name": "J. Townsend",  "position": 8 }
          ]
        }
      ]
    }
  ]
}
```

- `category` — id matching `teamCategories[].id` in config
- `club` — id matching `clubs.json[].id`, same as individual results CSV
- `points` — stored explicitly; not derived from position, so a club that fails to field enough scorers can receive 0 points
- `total` — sum of scorer positions (lower is better)
- scorer `position` — the runner's IC finish position, which is their contribution to the team total
- scorer `name` — abbreviated (e.g. "M. Swarbrick"), as prepared by the external process

## TypeScript Types

Added to `src/lib/types.ts`:

```typescript
export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
}

export interface TeamScorer {
  name: string;
  position: number;
}

export interface TeamClubResult {
  position: number;
  points: number;
  club: string;      // id → Club lookup via clubs.json
  total: number;
  scorers: TeamScorer[];
}

export interface TeamCategoryResult {
  category: string;  // id → TeamCategory lookup via config.teamCategories
  clubs: TeamClubResult[];
}

export interface TeamResults {
  categories: TeamCategoryResult[];
}
```

`SeriesConfig` extended:

```typescript
export interface SeriesConfig {
  categories: string[];
  teamCategories?: TeamCategory[];
}
```

## Data Loading

Two functions added to `src/lib/results.ts`:

- **`getTeamResults(year, series, raceId): TeamResults | null`** — loads `{race-id}-teams.json` via `import.meta.glob` with eager loading. Returns `null` if the file does not exist.
- **`hasTeamResults(year, series, raceId): boolean`** — returns true if the team results file exists. Used on the individual results page to conditionally enable the navigation button.

Both follow the same glob/eager patterns already used for individual results and club data.

## Pages

Two new Astro pages, one per series:

```
src/pages/road-gp/[year]/[raceId]/team-results.astro
src/pages/fell/[year]/[raceId]/team-results.astro
```

Each page receives `year`, `raceId`, `race` (Race), `teamResults` (TeamResults), `clubs` (Club[]), and `config` (SeriesConfig) via `getStaticPaths`.

Only races with a `-teams.json` file generate a team results page.

## Display

### Layout

- **Category tabs** — horizontal scrolling tab bar to switch between categories (Open, Ladies, etc.). Tab labels come from `config.teamCategories` matched by id; if a category appears in results but not in config the id is shown as fallback.
- **Per category** — ordered list of all clubs, ranked 1–7.
- **Mobile** — single column; each club row is collapsible. Club header shows position, name, and points. Scorers expand/collapse on tap.
- **Desktop** — same vertical list; club info on the left half of each row, scorer list on the right half. All clubs expanded by default.

### Club row

```
[pos]  Club Name          [N pts]
       Runner Name           55
       Runner Name           12
       ...
       Total                175
```

- Position and name are visually distinct (position muted, name bold)
- Points shown as `N pts` (or `1 pt` singular)
- Scorer IC finish positions right-aligned with tabular numbers
- Total line separated by a rule, bold

### Navigation

The existing disabled "View Team Results" button on each individual results page (`road-gp` and `fell`) is conditionally enabled: if `hasTeamResults()` returns true, it renders as a link to `./team-results`; otherwise it remains a disabled button. This matches the existing pattern used for the "View Results" link on race detail pages.

### Provisional badge

Not applicable — team results are always final when published. No provisional variant needed.
