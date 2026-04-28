# History View Design

**Date:** 2026-04-28
**Series:** InterClub static site (Astro + Tailwind + DaisyUI)

## Problem

Past-year series pages (`/road-gp/{year}/` and `/fell/{year}/`) currently render full race cards identical to the current-year view. This is too detailed for historical seasons — race images, locations, distances, and external links add noise when users mainly want to reach results. Awards also need a home on past-year pages, as they are announced the following season and do not belong on the live current-year view.

## Goals

- Condense past-year pages to date, name, and result links only
- Place awards below the race list on past-year pages, with a clear heading
- Leave current-year pages (`/road-gp/` and `/fell/`) completely unchanged

## Out of Scope

- Combined Road GP + Fell history pages
- A new `/history/` index landing page
- Changes to results pages, standings pages, or the `SeriesAwards` component

## Architecture

### New component: `HistoryRaceList.astro`

Handles the archive layout. Both `src/pages/road-gp/[year]/index.astro` and `src/pages/fell/[year]/index.astro` switch from `RaceList` to `HistoryRaceList`.

**Props** (same surface as `RaceList` — simplifies the page templates):

```typescript
interface Props {
  races: Race[];
  year: number;
  series: Series;
  availableYears: number[];
  currentYear: number;
  seriesBasePath: string;
  seriesLabel: string;
  standingsUrl?: string;
  individualStandingsUrl?: string;
  awards?: ResolvedSeriesAwards;
}
```

### Pages unchanged

- `src/pages/road-gp/index.astro` — no changes
- `src/pages/fell/index.astro` — no changes
- All results, team-results, standings pages — no changes
- `RaceList`, `RaceCard`, `SeriesAwards` components — no changes

## Layout

### Header row

Same as current: series label + year as `h1`, year filter dropdown on the right.

### Standings buttons

Team Standings and Individual Standings links rendered as outline buttons immediately below the header, same as today. Only shown when the respective data files exist.

### Race list

A simple list of rows — no cards, no images. Each row:

```
14 Jun 2026   Fell Race 1        Results  ·  Team Results
12 Jul 2026   Fell Race 2        Results
09 Aug 2026   Fell Race 3        —
```

- **Date** — formatted as `DD Mon YYYY` (e.g. `14 Jun 2026`). Use `formatRaceDate(date, undefined)` to suppress the time — start time is not relevant for archived races
- **Name** — plain text, not a link
- **Results link** — shown as `Results` only when a CSV exists for that race (use `hasResults` helper)
- **Team Results link** — shown as `Team Results` only when a team results JSON exists (use `hasTeamResults` helper)
- If neither results file exists, show a muted dash or nothing in that column
- No location, distance, image, or external details link

### Awards section

Rendered below the race list when `awards` prop is present:

```
2025 Awards
[SeriesAwards component]
```

- Heading: `"{year} Awards"` as `h2`
- Body: existing `SeriesAwards` component, passed the resolved awards prop unchanged
- Only rendered when `awards` is defined (same conditional as today in `[year]/index.astro`)

## Data & helpers

`hasResults` and `hasTeamResults` already exist in `src/lib/results.ts` and are used by other pages. `HistoryRaceList` uses them to determine which links to show per race. No new data loading required.

The awards resolution logic currently lives in `[year]/index.astro` for both road-gp and fell. This logic stays in the page templates — `HistoryRaceList` just receives the already-resolved `ResolvedSeriesAwards` object.

## Files touched

| File | Change |
|------|--------|
| `src/components/HistoryRaceList.astro` | **New** — archive layout component |
| `src/pages/road-gp/[year]/index.astro` | Switch `RaceList` → `HistoryRaceList` |
| `src/pages/fell/[year]/index.astro` | Switch `RaceList` → `HistoryRaceList` |
