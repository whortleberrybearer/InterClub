# History View Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the full race-card layout on past-year series pages with a condensed archive view showing date, name, and result links, followed by an awards section.

**Architecture:** A new `HistoryRaceList.astro` component handles the archive layout. The two past-year index pages (`road-gp/[year]/index.astro` and `fell/[year]/index.astro`) switch from `RaceList` to `HistoryRaceList`. Current-year pages and all other pages are untouched.

**Tech Stack:** Astro v6, Tailwind CSS v4 + DaisyUI v5, TypeScript strict

---

## File Map

| File | Action |
|------|--------|
| `src/components/HistoryRaceList.astro` | **Create** — condensed archive layout |
| `src/pages/road-gp/[year]/index.astro` | **Modify** — swap `RaceList` → `HistoryRaceList` |
| `src/pages/fell/[year]/index.astro` | **Modify** — swap `RaceList` → `HistoryRaceList` |

---

## Task 1: Create `HistoryRaceList.astro`

**Files:**
- Create: `src/components/HistoryRaceList.astro`

### Background

`formatRaceDate(date, time?)` in `src/lib/format.ts` returns `"Sun 14 Jun"` when called without a time argument — the day of week, day, and month. The year is already shown in the page `h1` so it need not repeat per row.

`hasResults(year, series, raceId)` and `hasTeamResults(year, series, raceId)` in `src/lib/results.ts` check whether the relevant data files exist at build time.

`SeriesAwards` in `src/components/SeriesAwards.astro` takes a single `awards: ResolvedSeriesAwards` prop and renders the full awards card.

`YearFilter` in `src/components/YearFilter.astro` takes `years`, `activeYear`, `seriesBasePath`, and `currentYear`.

- [ ] **Step 1: Create the component**

Create `src/components/HistoryRaceList.astro` with this content:

```astro
---
// src/components/HistoryRaceList.astro
import type { Race, ResolvedSeriesAwards, Series } from '../lib/types';
import SeriesAwards from './SeriesAwards.astro';
import YearFilter from './YearFilter.astro';
import { formatRaceDate } from '../lib/format';
import { hasResults, hasTeamResults } from '../lib/results';

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

const {
  races, year, series, availableYears, currentYear,
  seriesBasePath, seriesLabel, standingsUrl, individualStandingsUrl, awards,
} = Astro.props;
---

<div>
  <div class="flex items-center justify-between mb-6 flex-wrap gap-3">
    <h1 class="text-2xl font-bold">{seriesLabel} — {year}</h1>
    {availableYears.length > 1 && (
      <YearFilter
        years={availableYears}
        activeYear={year}
        seriesBasePath={seriesBasePath}
        currentYear={currentYear}
      />
    )}
  </div>

  {(standingsUrl || individualStandingsUrl) && (
    <div class="mb-4 flex gap-2 flex-wrap">
      {standingsUrl && (
        <a href={standingsUrl} class="btn btn-sm btn-outline gap-1">Team Standings →</a>
      )}
      {individualStandingsUrl && (
        <a href={individualStandingsUrl} class="btn btn-sm btn-outline gap-1">Individual Standings →</a>
      )}
    </div>
  )}

  {races.length === 0 ? (
    <p class="text-base-content/60">No races found for {year}.</p>
  ) : (
    <div class="divide-y divide-base-200">
      {races.map(race => {
        const resultsUrl = hasResults(year, series, race.id)
          ? `/${series}/${year}/${race.id}/results/`
          : null;
        const teamResultsUrl = hasTeamResults(year, series, race.id)
          ? `/${series}/${year}/${race.id}/team-results/`
          : null;
        return (
          <div class="flex items-baseline gap-4 py-3">
            <span class="text-sm text-base-content/50 w-28 shrink-0">
              {formatRaceDate(race.date)}
            </span>
            <span class="flex-1 font-medium">{race.name}</span>
            <div class="flex gap-3 text-sm shrink-0">
              {resultsUrl && (
                <a href={resultsUrl} class="link link-hover">Results</a>
              )}
              {teamResultsUrl && (
                <a href={teamResultsUrl} class="link link-hover">Team Results</a>
              )}
              {!resultsUrl && !teamResultsUrl && (
                <span class="text-base-content/30">—</span>
              )}
            </div>
          </div>
        );
      })}
    </div>
  )}

  {awards && (
    <div class="mt-8">
      <h2 class="text-xl font-bold mb-4">{year} Awards</h2>
      <SeriesAwards awards={awards} />
    </div>
  )}
</div>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/HistoryRaceList.astro
git commit -m "feat: add HistoryRaceList component for condensed archive view"
```

---

## Task 2: Wire `HistoryRaceList` into the Road GP past-year page

**Files:**
- Modify: `src/pages/road-gp/[year]/index.astro`

### Background

The current file imports `RaceList` and passes it `races`, `year`, `series`, `availableYears`, `currentYear`, `seriesBasePath`, `seriesLabel`, `standingsUrl`, `individualStandingsUrl`, and `awards`. `HistoryRaceList` accepts the same props, so this is a straight swap of the import and component name.

- [ ] **Step 1: Swap the import and component name**

In `src/pages/road-gp/[year]/index.astro`, change:

```astro
import RaceList from '../../../components/RaceList.astro';
```

to:

```astro
import HistoryRaceList from '../../../components/HistoryRaceList.astro';
```

And in the template section change:

```astro
<Layout title={`Road Grand Prix ${year}`}>
  <RaceList
    races={races}
    year={year}
    series="road-gp"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/road-gp"
    seriesLabel="Road Grand Prix"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
  />
</Layout>
```

to:

```astro
<Layout title={`Road Grand Prix ${year}`}>
  <HistoryRaceList
    races={races}
    year={year}
    series="road-gp"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/road-gp"
    seriesLabel="Road Grand Prix"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
  />
</Layout>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/road-gp/[year]/index.astro
git commit -m "feat: use HistoryRaceList on Road GP past-year pages"
```

---

## Task 3: Wire `HistoryRaceList` into the Fell past-year page

**Files:**
- Modify: `src/pages/fell/[year]/index.astro`

### Background

The fell past-year page is structured identically to the road-gp one. Same swap applies.

- [ ] **Step 1: Swap the import and component name**

In `src/pages/fell/[year]/index.astro`, change:

```astro
import RaceList from '../../../components/RaceList.astro';
```

to:

```astro
import HistoryRaceList from '../../../components/HistoryRaceList.astro';
```

And in the template section change:

```astro
<Layout title={`Fell Championship ${year}`}>
  <RaceList
    races={races}
    year={year}
    series="fell"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/fell"
    seriesLabel="Fell Championship"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
  />
</Layout>
```

to:

```astro
<Layout title={`Fell Championship ${year}`}>
  <HistoryRaceList
    races={races}
    year={year}
    series="fell"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/fell"
    seriesLabel="Fell Championship"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
  />
</Layout>
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/fell/[year]/index.astro
git commit -m "feat: use HistoryRaceList on Fell past-year pages"
```

---

## Task 4: Build verification

**Files:** none (read-only check)

- [ ] **Step 1: Run the build**

```bash
npm run build
```

Expected: build completes with no TypeScript errors and no Astro build failures. The output will list generated pages including `/road-gp/{year}/` and `/fell/{year}/` for each past year.

- [ ] **Step 2: Spot-check the output**

```bash
npm run preview
```

Navigate to a past-year page (e.g. if 2025 data exists, go to `http://localhost:4321/road-gp/2025/`). Verify:
- Page shows a condensed list with date, name, and result links per race
- Races with no results show a muted dash
- Team Results link appears only where team JSON exists
- Awards section appears below the race list with a `{year} Awards` heading
- Year filter dropdown is present and navigates correctly
- Standings buttons appear when team/individual standings data exists
- Current-year pages (`/road-gp/` and `/fell/`) are unchanged

- [ ] **Step 3: Run unit tests to confirm nothing regressed**

```bash
npm test
```

Expected: all tests pass (unit tests cover pure functions in `results.ts` and `format.ts`, which were not modified).
