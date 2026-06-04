# Sidebar Consistency: Overview Page & Archive Pages

**Date:** 2026-06-04

## Problem

The competitions overview pages (`/road-gp/`, `/fell/`) and the archive year pages (`/road-gp/{year}/`, `/fell/{year}/`) share a two-column desktop layout but their sidebars are inconsistent:

| | Overview (`SeriesDetailLayout`) | Archive (`HistoryRaceList`) |
|---|---|---|
| Past seasons card | `ArchiveYearNav` ✓ | `ArchiveYearNav` ✓ |
| All-time winners card | — (missing) | inline HTML ✓ |
| Sidebar width | `220px` (lg) / `260px` (xl) | `280px` (fixed inline style) |

## Goal

- Both page types show the same sidebar cards: **Past seasons** + **All-time winners**
- Both use the same sidebar column width
- No duplicated HTML — cards are shared components

## Changes

### 1. New component: `src/components/AllTimeWinnersCard.astro`

Props: `series: Series`

Derives URLs internally:
- Team winners → `siteUrl(`/${series}/history/teams`)`
- Individual winners → `siteUrl(`/${series}/history/individuals`)`

Renders the existing "All-time winners" card design (title + two link rows with series-appropriate accent colour).

### 2. `src/components/HistoryRaceList.astro`

Replace the inline 15-line "All-time winners" card block with:
```astro
<AllTimeWinnersCard series={series} />
```

Remove `historyTeamsUrl` and `historyIndividualsUrl` props — they are no longer needed since the component derives them.

**Note:** The parent pages (`[year]/index.astro` for road-gp and fell) currently pass these props. After the component change, those prop assignments can be removed from the callers too.

### 3. `src/components/SeriesDetailLayout.astro`

- Import and render `<AllTimeWinnersCard series={series} />` in the desktop sidebar, below `<ArchiveYearNav>`.
- Update sidebar grid column from `lg:grid-cols-[1fr_220px] xl:grid-cols-[1fr_260px]` → `lg:grid-cols-[1fr_260px] xl:grid-cols-[1fr_280px]` to match archive pages.

## What stays archive-only

The `ClubTurnout` card (per-year participation counts) is specific to a viewed season and stays in `HistoryRaceList` only — it doesn't apply to the current-season overview.

## Files touched

| File | Change |
|---|---|
| `src/components/AllTimeWinnersCard.astro` | Create |
| `src/components/HistoryRaceList.astro` | Use new component; remove props |
| `src/components/SeriesDetailLayout.astro` | Add card to sidebar; widen column |
| `src/pages/road-gp/[year]/index.astro` | Remove now-unused prop assignments |
| `src/pages/fell/[year]/index.astro` | Remove now-unused prop assignments |
