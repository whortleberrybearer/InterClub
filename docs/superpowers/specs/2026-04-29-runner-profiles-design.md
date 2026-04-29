# Runner Profiles — Design Spec

**Date:** 2026-04-29  
**Status:** Approved

## Overview

Add individual runner profile pages to the InterClub site. Runners can be navigated to from results tables, individual standings, and awards sections. Profiles aggregate all results and awards for a runner across all years and both series (Road GP and Fell).

Key challenges addressed:
- Runners may compete for different clubs across years
- Runners may change name (e.g. on marriage) — the same person must resolve to one profile
- The site is fully static (Astro build-time only) — no server-side search or lookup

---

## Data Model

### Two-tier identity

Runner identity uses two tiers: a **series-local** ID (scoped to a year + series) referenced from results and awards, and a **global** ID that ties everything together across years, series, and name changes.

### Global runner registry

**`src/data/runners.json`**

```json
[
  {
    "id": 1,
    "firstName": "Jane",
    "lastName": "Doe",
    "club": "wesham",
    "sex": "F",
    "category": "V40"
  },
  {
    "id": 2,
    "firstName": "Luke",
    "lastName": "Minns",
    "club": "blackpool",
    "sex": "M",
    "category": "V35"
  }
]
```

- `id` — unique numeric ID; stable and collision-proof
- `firstName` / `lastName` — canonical (current) display name
- `club` — current club id (references `clubs.json`)
- `sex` — `"M"` or `"F"`
- `category` — current age category (e.g. `"SEN"`, `"V40"`)

### Series runner registry

**`src/data/{year}/{series}/runners.json`**

One file per year per series. Captures the runner's details as they were in that series, and links to the global registry.

```json
[
  {
    "id": 1,
    "runnerId": 1,
    "firstName": "Jane",
    "lastName": "Smith",
    "club": "chorley",
    "sex": "F",
    "category": "SEN",
    "number": 42
  }
]
```

- `id` — series-local numeric ID; referenced from results CSVs and awards JSON
- `runnerId` — links to `runners.json` global `id`
- `firstName` / `lastName` — name as it appeared in this series/year (may differ from canonical name due to name change)
- `club` — club id for this series/year (may differ from current club)
- `sex` — `"M"` or `"F"`
- `category` — age category for this series/year
- `number` — optional bib number for this series/year (can change between series or be absent)

### Results CSV

Gains one optional column appended at the end:

```
position,ic_position,first_name,last_name,club,category,sex,time,series_runner_id
1,1,Luke,Minns,blackpool,V35,M,19:35,2
2,2,Rob,Danson,preston,V35,M,19:38,5
11,,T.,Guest,Guest,SEN,M,21:44,
```

- `series_runner_id` — optional; references `id` in the series runners file for this year/series
- Blank means the runner has no linked profile (e.g. guests, or runners not yet assigned an ID)
- Existing rows without the column are valid (treated as blank)

### Awards JSON

Award entries gain one optional field:

```json
{
  "individualAwards": [
    {
      "category": "v35-m",
      "awards": [
        { "position": 1, "name": "L. Minns", "club": "blackpool", "series_runner_id": 2 },
        { "position": 2, "name": "R. Danson", "club": "preston" }
      ]
    }
  ]
}
```

- `series_runner_id` — optional; references the same series-local runner ID as the CSV column
- Consistent with the CSV: one lookup chain via the series runners file to the global runner

---

## Pages

### Runner profile page

**URL pattern:** `/runners/{id}-{first-name}-{last-name}/`

- `id` is the global numeric runner ID
- Name portion is the canonical name slugified (lowercase, spaces → hyphens)
- Example: `/runners/2-luke-minns/`
- The ID prefix guarantees uniqueness even if two runners share a name
- URL is stable: built from the canonical name in the global registry at build time

**Generated for:** every entry in `src/data/runners.json` via `getStaticPaths()`

**No search page** — deferred to a future iteration. Discovery happens through links on existing pages.

---

## Profile Page Layout

### Header

```
Luke Minns
Blackpool Wyre & Fylde AC · Men · V35
```

Canonical name, current club (resolved from `clubs.json`), sex, and current category. No display of previous names or previous clubs.

### Filters

Pill toggle: **All | Road GP | Fell**  
Dropdowns: **All Years** | **All Races**

Filters are client-side. The race dropdown is populated from races present in the filtered result set (i.e. respects the active series and year filters).

### Results grouped by year

Results are grouped by year, descending (most recent first). Within each year, Road GP appears before Fell. A series section is only rendered if the runner has results in that series for that year.

Within each series section:

1. **Award** (if the runner won one in this series/year) — e.g. `🏆 1st V35 Men` — links to the series year index page (e.g. `/road-gp/2026/`)
2. **Race list** — one row per race entered, columns: date (short UK format, e.g. `1/4`), race name (links to results page), time

```
Road GP
  🏆 1st V35 Men                          → /road-gp/2026/
  1/4   BWF 5-Mile     19:35              → /road-gp/2026/bwf-5/results
  15/6  Chorley 4-Mile 22:41              → /road-gp/2026/chorley-4/results

Fell
  12/5  Longridge Fell 48:12              → /fell/2026/longridge/results
```

Race name links are only rendered when the target results page exists. Award links point to the year index page where the awards section is rendered.

---

## Navigation — Linking to Runner Profiles

Runner names become links on the following existing pages, wherever `series_runner_id` is present and resolves to a global runner:

| Page | Where the link appears |
|------|----------------------|
| Results page (`/road-gp/{year}/{raceId}/results`) | Runner name in the results table |
| Fell results page | Runner name in the results table |
| Individual standings (`/road-gp/{year}/individual-standings`) | Runner name in the standings table |
| Fell individual standings | Runner name in the standings table |
| Awards section (series year index pages) | Runner name in individual award entries |

Links degrade gracefully: rows without a `series_runner_id`, or with an ID that doesn't resolve to a global runner, remain as plain text. No visible change to the page when runner data is absent.

---

## Build-time Data Flow

1. Load `src/data/runners.json` → build map: `globalId → RunnerProfile`
2. Load all `src/data/{year}/{series}/runners.json` → build map: `{year}/{series}/{seriesLocalId} → globalId`
3. At results/standings/awards page generation: for each row with a `series_runner_id`, resolve to global runner → emit link to `/runners/{id}-{slug}/`
4. At runner profile page generation (`getStaticPaths`): for each global runner, collect all matching series-local IDs across all year/series runner files, then collect all result rows and awards entries with those IDs → pass as props

---

## Out of Scope (Future)

- Runner search / browse page (`/runners/`)
- Club history timeline on runner profile
- Personal bests or statistics derived from results
