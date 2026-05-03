# Series Note Field Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional `note` field to the series config so any year/series page can display a short explanatory message alongside (or instead of) the race list.

**Architecture:** Extend `SeriesConfig` with `note?: string` and make `ageCategories` optional. Create minimal data files for 2020 and 2021 so those years appear in the year filter. Update `HistoryRaceList` to render the note and drop the "No races found" fallback. Both year index pages pass the note through from config.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4 / DaisyUI v5, Vitest (no new unit tests — changes touch types, JSON, and Astro components, none of which are unit-testable; validation is via `npm run build`).

---

### Task 1: Extend `SeriesConfig` type and create 2020/2021 data files

**Files:**
- Modify: `src/lib/types.ts`
- Modify: `src/lib/results.ts` (update fallback return value)
- Create: `src/data/2020/road-gp/races.json`
- Create: `src/data/2020/road-gp/config.json`
- Create: `src/data/2020/fell/races.json`
- Create: `src/data/2020/fell/config.json`
- Create: `src/data/2021/road-gp/races.json`
- Create: `src/data/2021/road-gp/config.json`
- Create: `src/data/2021/fell/races.json`
- Create: `src/data/2021/fell/config.json`

- [ ] **Step 1: Update `SeriesConfig` in `src/lib/types.ts`**

In `src/lib/types.ts`, change the `SeriesConfig` interface from:

```typescript
export interface SeriesConfig {
  ageCategories: string[];
  maxCountingRaces?: number;
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
}
```

to:

```typescript
export interface SeriesConfig {
  ageCategories?: string[];
  maxCountingRaces?: number;
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
  note?: string;
}
```

- [ ] **Step 2: Update `getSeriesConfig` fallback in `src/lib/results.ts`**

`getSeriesConfig` currently returns `{ ageCategories: [] }` when no config file exists. With `ageCategories` now optional, the fallback should stay consistent so existing code that iterates over `config.ageCategories` doesn't break on years without a config file. The fallback remains as-is — no change needed here. Verify line 257 still reads:

```typescript
return files[`../data/${year}/${series}/config.json`]?.default ?? { ageCategories: [] };
```

No edit required — just confirm it's unchanged.

- [ ] **Step 3: Create 2020 Road GP data files**

Create `src/data/2020/road-gp/races.json`:
```json
[]
```

Create `src/data/2020/road-gp/config.json`:
```json
{
  "note": "Season suspended due to the COVID-19 pandemic."
}
```

- [ ] **Step 4: Create 2020 Fell data files**

Create `src/data/2020/fell/races.json`:
```json
[]
```

Create `src/data/2020/fell/config.json`:
```json
{
  "note": "Season suspended due to the COVID-19 pandemic."
}
```

- [ ] **Step 5: Create 2021 Road GP data files**

Create `src/data/2021/road-gp/races.json`:
```json
[]
```

Create `src/data/2021/road-gp/config.json`:
```json
{
  "note": "Season suspended due to the COVID-19 pandemic."
}
```

- [ ] **Step 6: Create 2021 Fell data files**

Create `src/data/2021/fell/races.json`:
```json
[]
```

Create `src/data/2021/fell/config.json`:
```json
{
  "note": "Season suspended due to the COVID-19 pandemic."
}
```

- [ ] **Step 7: Run tests to confirm no regressions**

```bash
npm test
```

Expected: all tests pass. (No new tests — these changes touch types, JSON, and Astro components.)

- [ ] **Step 8: Commit**

```bash
git add src/lib/types.ts src/data/2020 src/data/2021
git commit -m "feat: add note field to SeriesConfig; add 2020/2021 suspended-season data files"
```

---

### Task 2: Update `HistoryRaceList` component

**Files:**
- Modify: `src/components/HistoryRaceList.astro`

- [ ] **Step 1: Add `note` prop and update Props interface**

In `src/components/HistoryRaceList.astro`, update the Props interface (currently ends at `awards?`) to add `note`:

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
  note?: string;
}
```

- [ ] **Step 2: Destructure `note` from props**

Update the destructuring line (currently on line 22) to include `note`:

```typescript
const {
  races, year, series, availableYears, currentYear,
  seriesBasePath, seriesLabel, standingsUrl, individualStandingsUrl, awards, note,
} = Astro.props;
```

- [ ] **Step 3: Replace empty-state fallback with note rendering**

Find the current empty-state block in the template:

```astro
{races.length === 0 ? (
  <p class="text-base-content/60">No races found for {year}.</p>
) : (
  <div class="divide-y divide-base-200">
    {races.map(race => {
      ...
    })}
  </div>
)}
```

Replace it with a structure that always renders the race list when races exist, and always renders the note when present — independently:

```astro
{races.length > 0 && (
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

{note && <p class="text-base-content/60 italic text-sm mt-2">{note}</p>}
```

- [ ] **Step 4: Commit**

```bash
git add src/components/HistoryRaceList.astro
git commit -m "feat: render series note in HistoryRaceList; remove 'no races found' fallback"
```

---

### Task 3: Pass note from year index pages

**Files:**
- Modify: `src/pages/road-gp/[year]/index.astro`
- Modify: `src/pages/fell/[year]/index.astro`

- [ ] **Step 1: Update Road GP year index page**

In `src/pages/road-gp/[year]/index.astro`, `getSeriesConfig` is already called on line 21 (as part of the awards block — inside the `if (hasAwards(...))` guard). For the note, config must be read unconditionally. Add a top-level config read after the existing `getRaces` call:

After line `const races = getRaces(year, 'road-gp');`, add:

```typescript
const config = getSeriesConfig(year, 'road-gp');
```

Then in the existing awards block, replace the inner `const config = getSeriesConfig(year, 'road-gp');` line (which is inside the `if (hasAwards(...))` block) with a reference to the already-loaded `config` — remove the duplicate declaration.

Finally, pass the note to `HistoryRaceList`:

```astro
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
  note={config.note}
/>
```

The full updated frontmatter for `src/pages/road-gp/[year]/index.astro`:

```typescript
---
// src/pages/road-gp/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import HistoryRaceList from '../../../components/HistoryRaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings } from '../../../lib/results';
import type { ResolvedSeriesAwards } from '../../../lib/types';
import { buildRunnerUrlMap } from '../../../lib/runners';

export async function getStaticPaths() {
  const current = getCurrentYear();
  const years = getAvailableYears('road-gp').filter(y => y !== current);
  return years.map(year => ({ params: { year: String(year) } }));
}

const { year: yearParam } = Astro.params;
const year = parseInt(yearParam);
const currentYear = getCurrentYear();
const availableYears = getAvailableYears('road-gp');
const races = getRaces(year, 'road-gp');
const config = getSeriesConfig(year, 'road-gp');
const standingsUrl = hasTeamStandings(year, 'road-gp')
  ? `/road-gp/${year}/team-standings`
  : undefined;
const individualStandingsUrl = hasIndividualStandings(year, 'road-gp')
  ? `/road-gp/${year}/individual-standings`
  : undefined;

let awards: ResolvedSeriesAwards | undefined;
if (hasAwards(year, 'road-gp')) {
  const raw = getAwards(year, 'road-gp')!;
  const clubs = getClubs(year);

  const resolveClub = (id: string) => clubs.find(c => c.id === id)?.name ?? id;
  const resolveTeamCategoryName = (id: string) =>
    config.teamCategories?.find(c => c.id === id)?.name ?? id;
  const resolveIndividualCategory = (id: string) =>
    config.individualCategories?.find(c => c.id === id);

  const runnerUrlMap = buildRunnerUrlMap(year, 'road-gp');

  const partitioned = raw.individualAwards.map(ia => {
    const cat = resolveIndividualCategory(ia.category);
    return {
      sex: cat?.sex,
      resolved: {
        categoryName: cat?.name ?? ia.category,
        awards: ia.awards.map(a => ({
          position: a.position,
          name: a.name,
          clubName: resolveClub(a.club),
          runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
        })),
      },
    };
  });

  awards = {
    teamAwards: raw.teamAwards.map(ta => ({
      categoryName: resolveTeamCategoryName(ta.category),
      clubName: resolveClub(ta.club),
    })),
    overallAwards: partitioned.filter(x => !x.sex).map(x => x.resolved),
    maleAwards:    partitioned.filter(x => x.sex === 'M').map(x => x.resolved),
    femaleAwards:  partitioned.filter(x => x.sex === 'F').map(x => x.resolved),
  };
}
---
```

- [ ] **Step 2: Update Fell year index page**

Apply the identical change to `src/pages/fell/[year]/index.astro`. The full updated frontmatter:

```typescript
---
// src/pages/fell/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import HistoryRaceList from '../../../components/HistoryRaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings } from '../../../lib/results';
import type { ResolvedSeriesAwards } from '../../../lib/types';
import { buildRunnerUrlMap } from '../../../lib/runners';

export async function getStaticPaths() {
  const current = getCurrentYear();
  const years = getAvailableYears('fell').filter(y => y !== current);
  return years.map(year => ({ params: { year: String(year) } }));
}

const { year: yearParam } = Astro.params;
const year = parseInt(yearParam);
const currentYear = getCurrentYear();
const availableYears = getAvailableYears('fell');
const races = getRaces(year, 'fell');
const config = getSeriesConfig(year, 'fell');
const standingsUrl = hasTeamStandings(year, 'fell')
  ? `/fell/${year}/team-standings`
  : undefined;
const individualStandingsUrl = hasIndividualStandings(year, 'fell')
  ? `/fell/${year}/individual-standings`
  : undefined;

let awards: ResolvedSeriesAwards | undefined;
if (hasAwards(year, 'fell')) {
  const raw = getAwards(year, 'fell')!;
  const clubs = getClubs(year);

  const resolveClub = (id: string) => clubs.find(c => c.id === id)?.name ?? id;
  const resolveTeamCategoryName = (id: string) =>
    config.teamCategories?.find(c => c.id === id)?.name ?? id;
  const resolveIndividualCategory = (id: string) =>
    config.individualCategories?.find(c => c.id === id);

  const runnerUrlMap = buildRunnerUrlMap(year, 'fell');

  const partitioned = raw.individualAwards.map(ia => {
    const cat = resolveIndividualCategory(ia.category);
    return {
      sex: cat?.sex,
      resolved: {
        categoryName: cat?.name ?? ia.category,
        awards: ia.awards.map(a => ({
          position: a.position,
          name: a.name,
          clubName: resolveClub(a.club),
          runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
        })),
      },
    };
  });

  awards = {
    teamAwards: raw.teamAwards.map(ta => ({
      categoryName: resolveTeamCategoryName(ta.category),
      clubName: resolveClub(ta.club),
    })),
    overallAwards: partitioned.filter(x => !x.sex).map(x => x.resolved),
    maleAwards:    partitioned.filter(x => x.sex === 'M').map(x => x.resolved),
    femaleAwards:  partitioned.filter(x => x.sex === 'F').map(x => x.resolved),
  };
}
---
```

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/[year]/index.astro src/pages/fell/[year]/index.astro
git commit -m "feat: pass series config note to HistoryRaceList on year index pages"
```

---

### Task 4: Build verification

**Files:** none

- [ ] **Step 1: Run the build**

```bash
npm run build
```

Expected: build completes with no TypeScript errors and no Vite errors. The output should include pages for `/road-gp/2020/`, `/road-gp/2021/`, `/fell/2020/`, `/fell/2021/`.

- [ ] **Step 2: Spot-check generated output**

```bash
grep -l "2020\|2021" dist/road-gp/*/index.html dist/fell/*/index.html 2>/dev/null
```

Expected: four files returned — one per series/year.

```bash
grep "COVID" dist/road-gp/2020/index.html dist/fell/2020/index.html
```

Expected: the note text appears in both files.

- [ ] **Step 3: Run tests one final time**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 4: Commit if any build-driven fixes were needed**

If the build required any minor corrections, commit them:

```bash
git add -p
git commit -m "fix: <description of build-driven correction>"
```

If no corrections were needed, skip this step.
