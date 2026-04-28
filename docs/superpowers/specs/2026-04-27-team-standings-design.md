# Team Standings Design

**Date:** 2026-04-27
**Series:** Road GP and Fell Championship

## Overview

Add a season team standings page for each series and year, showing cumulative points per club per category across all races in the season. Data is computed externally and dropped into the data directory as a JSON file — the same model used for individual race team results.

## Data Format

### New file: `src/data/{year}/{series}/team-standings.json`

```json
{
  "provisional": true,
  "races": ["bwf-5", "chorley-4", "lytham-5", "preston-5", "red-rose-4", "thornton-5", "wesham-5"],
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "club": "wesham",
          "points": [7, null, null, null, null, null, null],
          "total": 7,
          "tiebreaker": null
        }
      ]
    }
  ]
}
```

**Fields:**
- `provisional` — boolean; shows a warning badge on the page when true
- `races` — ordered list of race IDs from `races.json`; index maps to the `points` array
- `categories[].category` — matches `teamCategories[].id` in the series `config.json`
- `clubs[].position` — numeric rank within the category; the page automatically appends `=` when multiple clubs share the same position value
- `clubs[].club` — club id from `clubs.json`
- `clubs[].points` — one entry per race in `races`; `null` for races not yet run (rendered as `—`)
- `clubs[].total` — cumulative season points
- `clubs[].tiebreaker` — nullable string; only shown when non-null, no header or column

### Changes to existing files

**`src/data/{year}/{series}/races.json`** — each race gets a new optional `shortName` field used as the column/pill label:

```json
{ "id": "bwf-5", "name": "Blackpool Wyre & Fylde 5", "shortName": "BPL", ... }
```

**`src/lib/types.ts`** — `Race` interface gets `shortName?: string`.

## Page Structure

### URLs
- `/road-gp/{year}/team-standings`
- `/fell/{year}/team-standings`

### Files
- `src/pages/road-gp/[year]/team-standings.astro`
- `src/pages/fell/[year]/team-standings.astro`

### Static path generation
`getStaticPaths` only generates the page when `team-standings.json` exists for that year — identical pattern to `team-results.astro`. A helper `getTeamStandingsStaticPaths(series)` in `src/lib/results.ts` handles this.

### Navigation in
A "Team Standings" button on the series schedule page (`/road-gp/{year}` and `/fell/{year}`) links to this page. The button is only rendered when the standings file exists — same disabled-button pattern used for races with no results.

### Category tabs
Same tab pattern as `team-results.astro` — one tab per category in `teamCategories`, switching panels on click.

## Layout

### Desktop (≥ 640 px) — table

| # | Club | BPL | CHO | … | Total |
|---|------|-----|-----|---|-------|
| 1 | Wesham | 7 | 6 | — | **13** |

- Race column headers use `shortName` (falls back to race id if missing)
- Race headers link to `/road-gp/{year}/{raceId}/team-results` when that race's team results file exists; plain text otherwise
- `null` points render as `—` in a muted colour
- Total is bold and highlighted
- **Tiebreaker:** when non-null, shown as a small line of text beneath the total in that row's Total cell — no column, no header

### Mobile (< 640 px) — stacked rows with tap-to-expand

**Race legend** above the rows maps abbreviations to full race names, with links to team results where available.

**Each club row:**
- Always visible: position, club name, season total
- Tap to expand: per-race pills (one per race in the season)
  - Pill label is the `shortName`; links to team results when available
  - Pills with `null` points show `—` in a muted colour
- **Tiebreaker:** when non-null, shown as a small line below the pills in the expanded section

## Build-time Logic

At build time, the standings page needs to know which races have team results (to enable links). It does this by checking for `{raceId}-teams.json` or `{raceId}-teams-provisional.json` alongside the existing individual results files — the same file-existence logic already used in `getTeamResultsStaticPaths`. A `Set<string>` of linkable race IDs is passed as a prop to the page.

## Out of Scope

- Computing standings from raw CSV/team-results files automatically — standings are externally computed and provided as JSON
- Individual runner standings
- Historical years (data files simply don't exist for them; no pages will be generated)
