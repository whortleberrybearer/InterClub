# Sidebar Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the "All-time winners" card to the competitions overview page sidebar, extract it into a shared component, and make sidebar widths consistent with the archive pages.

**Architecture:** Extract the inline "All-time winners" card from `HistoryRaceList` into a new `AllTimeWinnersCard` component that derives its URLs from the `series` prop. Wire it into both `HistoryRaceList` and `SeriesDetailLayout`. Widen the `SeriesDetailLayout` sidebar column to match the archive pages.

**Tech Stack:** Astro v6, TypeScript, Tailwind CSS v4. No unit-testable pure functions — validation is `npm run build`.

---

## File Map

| File | Action |
|---|---|
| `src/components/AllTimeWinnersCard.astro` | Create |
| `src/components/HistoryRaceList.astro` | Modify — swap inline card for component; remove dead props |
| `src/components/SeriesDetailLayout.astro` | Modify — add card to sidebar; widen column |
| `src/pages/road-gp/[year]/index.astro` | Modify — remove dead prop assignments |
| `src/pages/fell/[year]/index.astro` | Modify — remove dead prop assignments |

---

### Task 1: Create `AllTimeWinnersCard` component

**Files:**
- Create: `src/components/AllTimeWinnersCard.astro`

- [ ] **Step 1: Create the component**

Create `src/components/AllTimeWinnersCard.astro` with this exact content:

```astro
---
import { siteUrl } from '../lib/url';
import type { Series } from '../lib/types';

interface Props {
  series: Series;
}

const { series } = Astro.props;
const accentText = series === 'fell' ? 'text-teal' : 'text-amber';

const historyTeamsUrl = siteUrl(`/${series}/history/teams`);
const historyIndividualsUrl = siteUrl(`/${series}/history/individuals`);
---

<div class="bg-surface rounded-xl border border-line p-4">
  <p class="font-head text-[15px] font-bold tracking-[0.04em] uppercase mb-3">All-time winners</p>
  <div class="flex flex-col divide-y divide-line">
    <a href={historyTeamsUrl} class="flex items-center justify-between py-3 group">
      <div class="min-w-0">
        <p class="font-head text-[13px] font-bold leading-tight">Team Winners</p>
      </div>
      <span class:list={['font-head text-[10px] font-bold tracking-[0.08em] uppercase whitespace-nowrap ml-3', accentText]}>→</span>
    </a>
    <a href={historyIndividualsUrl} class="flex items-center justify-between py-3 group">
      <div class="min-w-0">
        <p class="font-head text-[13px] font-bold leading-tight">Individual Winners</p>
      </div>
      <span class:list={['font-head text-[10px] font-bold tracking-[0.08em] uppercase whitespace-nowrap ml-3', accentText]}>→</span>
    </a>
  </div>
</div>
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: Build completes with no errors. The new file is syntactically valid but not yet wired in anywhere.

- [ ] **Step 3: Commit**

```bash
git add src/components/AllTimeWinnersCard.astro
git commit -m "feat: extract AllTimeWinnersCard component"
```

---

### Task 2: Update `HistoryRaceList` to use the component

**Files:**
- Modify: `src/components/HistoryRaceList.astro`

- [ ] **Step 1: Add import and remove dead props**

In `src/components/HistoryRaceList.astro`, make these changes to the frontmatter block (lines 1–32):

Replace:
```astro
---
// src/components/HistoryRaceList.astro
import type { Club, Race, ResolvedSeriesAwards, Series } from '../lib/types';
import { siteUrl } from '../lib/url';
import ArchiveYearNav from './ArchiveYearNav.astro';
import ScheduleTable from './ScheduleTable.astro';
import ClubTurnout from './ClubTurnout.astro';
import { CLUB_COLORS } from '../lib/clubColors';

interface Props {
  races: Race[];
  year: number;
  series: Series;
  standingsUrl?: string;
  individualStandingsUrl?: string;
  awards?: ResolvedSeriesAwards;
  note?: string;
  historyTeamsUrl?: string;
  historyIndividualsUrl?: string;
  clubs?: Club[];
  participantCounts?: Record<string, number>;
  availableYears?: number[];
  currentYear?: number;
}

const {
  races, year, series,
  standingsUrl, individualStandingsUrl,
  awards, note, historyTeamsUrl, historyIndividualsUrl,
  clubs = [], participantCounts = {},
  availableYears = [], currentYear,
} = Astro.props;
```

With:
```astro
---
// src/components/HistoryRaceList.astro
import type { Club, Race, ResolvedSeriesAwards, Series } from '../lib/types';
import { siteUrl } from '../lib/url';
import ArchiveYearNav from './ArchiveYearNav.astro';
import AllTimeWinnersCard from './AllTimeWinnersCard.astro';
import ScheduleTable from './ScheduleTable.astro';
import ClubTurnout from './ClubTurnout.astro';
import { CLUB_COLORS } from '../lib/clubColors';

interface Props {
  races: Race[];
  year: number;
  series: Series;
  standingsUrl?: string;
  individualStandingsUrl?: string;
  awards?: ResolvedSeriesAwards;
  note?: string;
  clubs?: Club[];
  participantCounts?: Record<string, number>;
  availableYears?: number[];
  currentYear?: number;
}

const {
  races, year, series,
  standingsUrl, individualStandingsUrl,
  awards, note,
  clubs = [], participantCounts = {},
  availableYears = [], currentYear,
} = Astro.props;
```

- [ ] **Step 2: Replace the inline card block with the component**

In the sidebar section (around line 313), replace the inline "All-time winners" block:

Replace:
```astro
      <!-- All-time winners links -->
      {(historyTeamsUrl || historyIndividualsUrl) && (
        <div class="bg-surface rounded-xl border border-line p-4">
          <p class="font-head text-[15px] font-bold tracking-[0.04em] uppercase mb-3">All-time winners</p>
          <div class="flex flex-col divide-y divide-line">
            {historyTeamsUrl && (
              <a href={historyTeamsUrl} class="flex items-center justify-between py-3 group">
                <div class="min-w-0">
                  <p class="font-head text-[13px] font-bold leading-tight">Team Winners</p>
                </div>
                <span class:list={['font-head text-[10px] font-bold tracking-[0.08em] uppercase whitespace-nowrap ml-3 ', accentText]}>→</span>
              </a>
            )}
            {historyIndividualsUrl && (
              <a href={historyIndividualsUrl} class="flex items-center justify-between py-3 group">
                <div class="min-w-0">
                  <p class="font-head text-[13px] font-bold leading-tight">Individual Winners</p>
                </div>
                <span class:list={['font-head text-[10px] font-bold tracking-[0.08em] uppercase whitespace-nowrap ml-3 ', accentText]}>→</span>
              </a>
            )}
          </div>
        </div>
      )}
```

With:
```astro
      <!-- All-time winners links -->
      <AllTimeWinnersCard series={series} />
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

Expected: Build errors on the two callers that still pass `historyTeamsUrl` / `historyIndividualsUrl` — TypeScript will warn about unknown props (or succeed silently depending on Astro's strictness). Either way, proceed to clean up callers in the next steps.

- [ ] **Step 4: Remove dead props from `road-gp/[year]/index.astro`**

In `src/pages/road-gp/[year]/index.astro`, remove the two prop lines from the `<HistoryRaceList>` call:

Remove:
```astro
    historyTeamsUrl={siteUrl('/road-gp/history/teams')}
    historyIndividualsUrl={siteUrl('/road-gp/history/individuals')}
```

The remaining `<HistoryRaceList>` call should look like:
```astro
  <HistoryRaceList
    races={races}
    year={year}
    series="road-gp"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
    note={config.note}
    clubs={clubs}
    participantCounts={participantCounts}
    availableYears={availableYears}
    currentYear={currentYear}
  />
```

- [ ] **Step 5: Remove dead props from `fell/[year]/index.astro`**

In `src/pages/fell/[year]/index.astro`, remove the same two prop lines:

Remove:
```astro
    historyTeamsUrl={siteUrl('/fell/history/teams')}
    historyIndividualsUrl={siteUrl('/fell/history/individuals')}
```

The remaining `<HistoryRaceList>` call should look like:
```astro
  <HistoryRaceList
    races={races}
    year={year}
    series="fell"
    standingsUrl={standingsUrl}
    individualStandingsUrl={individualStandingsUrl}
    awards={awards}
    note={config.note}
    clubs={clubs}
    participantCounts={participantCounts}
    availableYears={availableYears}
    currentYear={currentYear}
  />
```

- [ ] **Step 6: Verify build passes**

```bash
npm run build
```

Expected: Build completes with no errors.

- [ ] **Step 7: Commit**

```bash
git add src/components/HistoryRaceList.astro src/pages/road-gp/[year]/index.astro src/pages/fell/[year]/index.astro
git commit -m "refactor: use AllTimeWinnersCard in HistoryRaceList; remove dead props"
```

---

### Task 3: Add card and fix width in `SeriesDetailLayout`

**Files:**
- Modify: `src/components/SeriesDetailLayout.astro`

- [ ] **Step 1: Add import**

In `src/components/SeriesDetailLayout.astro`, add the import alongside the existing `ArchiveYearNav` import. The imports block (around line 1–8) currently reads:

```astro
---
import Layout from './Layout.astro';
import ArchiveYearNav from './ArchiveYearNav.astro';
import ScheduleTable from './ScheduleTable.astro';
import { hasResults } from '../lib/results';
import { siteUrl } from '../lib/url';
import type { Race, Series, SeriesConfig } from '../lib/types';
```

Add `AllTimeWinnersCard` after `ArchiveYearNav`:

```astro
---
import Layout from './Layout.astro';
import ArchiveYearNav from './ArchiveYearNav.astro';
import AllTimeWinnersCard from './AllTimeWinnersCard.astro';
import ScheduleTable from './ScheduleTable.astro';
import { hasResults } from '../lib/results';
import { siteUrl } from '../lib/url';
import type { Race, Series, SeriesConfig } from '../lib/types';
```

- [ ] **Step 2: Widen the sidebar column**

On line 138, change the grid column definition:

Replace:
```astro
  <div class="lg:grid lg:grid-cols-[1fr_220px] xl:grid-cols-[1fr_260px] lg:gap-8 lg:items-start">
```

With:
```astro
  <div class="lg:grid lg:grid-cols-[1fr_260px] xl:grid-cols-[1fr_280px] lg:gap-8 lg:items-start">
```

- [ ] **Step 3: Add the card to the sidebar**

The desktop sidebar (around lines 205–207) currently reads:

```astro
    <aside class="hidden lg:block sticky top-6 self-start">
      <ArchiveYearNav series={series} years={pastYears} />
    </aside>
```

Replace with:

```astro
    <aside class="hidden lg:block sticky top-6 self-start">
      <div class="flex flex-col gap-4">
        <ArchiveYearNav series={series} years={pastYears} />
        <AllTimeWinnersCard series={series} />
      </div>
    </aside>
```

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

Expected: Build completes with no errors.

- [ ] **Step 5: Commit**

```bash
git add src/components/SeriesDetailLayout.astro
git commit -m "feat: add AllTimeWinnersCard to overview sidebar; widen column to match archive"
```
