# Race Results Pages — Design Spec

Date: 2026-04-26

## Overview

Add individual race results pages to the InterClub static site. Results are stored as CSV files committed to the repository and parsed at build time. Each results page includes filterable individual results and a link to the (future) team results page.

## Data Format

### Results CSV

Results for each race are stored at:

```
src/data/{year}/{series}/results/{race-id}.csv
src/data/{year}/{series}/results/{race-id}-provisional.csv
```

The build checks for the provisional file first, then the final file. If neither exists, no results page is generated for that race.

**Schema:**

```
position,ic_position,first_name,last_name,club,category,sex,time
1,1,Luke,Minns,blackpool,V35,M,19:35
2,2,Rob,Danson,preston,V35,M,19:37
9,,T.,Guest,Guest,SEN,M,22:14
```

| Column | Type | Notes |
|---|---|---|
| `position` | integer | Overall race finish position |
| `ic_position` | integer or empty | Inter-club position; empty for guest runners |
| `first_name` | string | |
| `last_name` | string | |
| `club` | string | Club `id` from `clubs.json`, or `Guest` for non-club runners |
| `category` | string | Individual age group: `U17`, `U20`, `U23`, `SEN`, `V35`…`V80` |
| `sex` | `M` or `F` | |
| `time` | string | Finish time as `MM:SS` |

Empty values render as `–` in the UI. All fields are optional to support historical results with partial data.

### Club Configuration

Competing clubs are defined per year in:

```
src/data/{year}/clubs.json
```

```json
[
  { "id": "blackpool", "name": "Blackpool Wyre & Fylde AC", "shortName": "BWF", "logo": "blackpool.svg" },
  { "id": "chorley",   "name": "Chorley A&TC",              "shortName": "CAT", "logo": "chorley.svg"  },
  { "id": "lytham",    "name": "Lytham St Annes RR",        "shortName": "LSA", "logo": "lytham.svg"   },
  { "id": "preston",   "name": "Preston Harriers",           "shortName": "PH",  "logo": "preston.svg"  },
  { "id": "red-rose",  "name": "Red Rose RR",                "shortName": "RR",  "logo": "red-rose.svg" },
  { "id": "thornton",  "name": "Thornton Cleveleys RC",      "shortName": "TC",  "logo": "thornton.svg" },
  { "id": "wesham",    "name": "Wesham RR",                  "shortName": "WRR", "logo": "wesham.svg"   }
]
```

Club membership changes over the years (e.g. Thornton joined in 2015; North Fylde AC competed before Blackpool). Each year's `clubs.json` defines the clubs for that year. The club filter is always populated from this file — never derived from results — so all competing clubs appear even if a club had no finishers in a race.

### Age Category Configuration

Valid age categories are defined per series per year in:

```
src/data/{year}/road-gp/config.json
src/data/{year}/fell/config.json
```

```json
// road-gp/config.json
{
  "categories": ["U17", "U20", "U23", "SEN", "V35", "V40", "V45", "V50", "V55", "V60", "V65", "V70", "V75", "V80"]
}
```

```json
// fell/config.json
{
  "categories": ["SEN", "V40", "V50", "V60", "V70"]
}
```

Categories differ by series (Road GP has finer vet bands; Fell has coarser). The category filter is populated from config, not results, so all valid categories appear even if no runners finished in that category in a given race.

## Routing

| URL | Page |
|---|---|
| `/{series}/{year}/{race-id}/results` | Individual results |
| `/{series}/{year}/{race-id}/team-results` | Team results (future) |

Example: `/road-gp/2026/bwf-5/results`

Astro page files:
- `src/pages/road-gp/[year]/[id]/results.astro`
- `src/pages/fell/[year]/[id]/results.astro`

## Build-Time Data Loading

CSVs are loaded using `import.meta.glob` with `?raw`:

```ts
const csvFiles = import.meta.glob(
  '../../../../data/*/road-gp/results/*.csv',
  { query: '?raw', import: 'default', eager: true }
);
```

A utility at `src/lib/results.ts` handles:
- CSV parsing (splitting rows, mapping columns to typed fields)
- Converting `ic_position` to `number | null`
- Detecting provisional status from the filename suffix
- Returning a typed `RaceResult[]` array

The parsed results, `clubs.json`, and `config.json` are all available in the Astro frontmatter at build time. The full results array is serialised into a `<script type="application/json">` island in the page HTML — no client-side fetch required.

## Results Page

### Race Detail Page Integration

The existing race detail page gains a **"View Results"** link only when a results CSV (provisional or final) exists for that race. If no CSV exists, the link is not shown.

### Results Page Layout

**Page heading:** Race name + year. If results are provisional: `Results (Provisional)` with a visible "Provisional" badge.

**Filter bar** (always visible, above the table):
1. Name search input — filters on first or last name, case-insensitive, as-you-type
2. Club dropdown — all competing clubs from `clubs.json`; guests excluded from this filter
3. Age category dropdown — all valid categories from series `config.json`
4. Sex toggle — All / Men / Women

All filters are combinable.

**Results table:**

| Column | Mobile | Desktop |
|---|---|---|
| Pos (overall) | Hidden | Shown |
| IC (inter-club) | Shown | Shown |
| Name | Abbreviated (initial + surname) | Full name |
| Category | Shown | Shown |
| Club | Logo + short name | Logo + full name |
| Time | Shown | Shown |

Guest runners display their overall `Pos`, `–` for IC, and `Guest` as their club label (no logo).

**Footer links:**
- Back to race detail page
- "View Team Results" link to `/{series}/{year}/{race-id}/team-results` (shown but inactive until team results are implemented)

## Edge Cases

- **No results** — no results link shown on race detail page; no results page generated
- **Provisional results** — page heading shows "(Provisional)" badge; resolved automatically when CSV is renamed to remove the `-provisional` suffix
- **Missing fields** — empty CSV values render as `–`; name search and filters still function on available data
- **No finishers in a category or club** — filter options still appear because they are config-driven, not results-driven
- **Historical races** — older races may have partial data (times only, no positions); the schema accommodates this with all fields optional except `last_name`
