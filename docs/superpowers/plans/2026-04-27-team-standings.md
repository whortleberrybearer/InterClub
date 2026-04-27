# Team Standings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a season team standings page to each series showing cumulative points per club per category, with per-race breakdown on desktop and tap-to-expand on mobile.

**Architecture:** Standings data is externally computed and placed as `team-standings.json` in the series data directory — same model as per-race team results. A `getTeamStandingsStaticPaths` helper generates one page per year that has a standings file. The page shows a full table on desktop (≥640 px) and stacked expandable rows on mobile.

**Tech Stack:** Astro v6, Tailwind CSS v4 + DaisyUI v5, TypeScript strict, Vitest

---

## File Map

| File | Action |
|------|--------|
| `src/lib/types.ts` | Add `shortName?: string` to `Race`; add `TeamStandings`, `TeamStandingsCategory`, `TeamStandingsClub` |
| `src/lib/results.ts` | Add glob, `parseTeamStandingsPath`, `getTeamStandings`, `hasTeamStandings`, `getTeamStandingsStaticPaths` |
| `src/data/2026/road-gp/races.json` | Add `shortName` to each race |
| `src/data/2026/fell/races.json` | Add `shortName` to each race |
| `src/components/RaceList.astro` | Add optional `standingsUrl` prop + conditional link |
| `src/pages/road-gp/index.astro` | Pass `standingsUrl` |
| `src/pages/road-gp/[year]/index.astro` | Pass `standingsUrl` |
| `src/pages/fell/index.astro` | Pass `standingsUrl` |
| `src/pages/fell/[year]/index.astro` | Pass `standingsUrl` |
| `src/pages/road-gp/[year]/team-standings.astro` | Create: Road GP standings page |
| `src/pages/fell/[year]/team-standings.astro` | Create: Fell standings page |
| `src/data/2026/road-gp/team-standings.json` | Create: Blackpool race standings data |
| `tests/lib/results.test.ts` | Add `parseTeamStandingsPath` tests |

---

### Task 1: Add types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add `shortName` to `Race` and add standings types**

  Open `src/lib/types.ts` and apply these changes — add `shortName` to the `Race` interface and append three new interfaces at the end of the file:

  ```typescript
  export interface Race {
    id: string;
    name: string;
    date: string;
    time?: string;
    location?: string;
    distance?: string;
    detailsUrl?: string;
    image?: string;
    shortName?: string;     // ← add this line
  }
  ```

  Append at the end of the file:

  ```typescript
  export interface TeamStandingsClub {
    position: number;
    club: string;
    points: (number | null)[];
    total: number;
    tiebreaker: string | null;
  }

  export interface TeamStandingsCategory {
    category: string;
    clubs: TeamStandingsClub[];
  }

  export interface TeamStandings {
    provisional: boolean;
    races: string[];
    categories: TeamStandingsCategory[];
  }
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: build completes with no TypeScript errors.

- [ ] **Step 3: Commit**

  ```bash
  git add src/lib/types.ts
  git commit -m "feat: add shortName to Race and TeamStandings types"
  ```

---

### Task 2: Add `shortName` to races.json files

**Files:**
- Modify: `src/data/2026/road-gp/races.json`
- Modify: `src/data/2026/fell/races.json`

- [ ] **Step 1: Add `shortName` to road-gp races**

  Replace the contents of `src/data/2026/road-gp/races.json` with:

  ```json
  [
    {
      "id": "bwf-5",
      "name": "Blackpool Wyre & Fylde 5",
      "shortName": "BPL",
      "date": "2026-06-07",
      "time": "10:30",
      "location": "Stanley Park, Blackpool",
      "distance": "5 miles"
    },
    {
      "id": "chorley-4",
      "name": "Chorley 4",
      "shortName": "CHO",
      "date": "2026-06-21",
      "time": "10:00",
      "location": "Astley Park, Chorley",
      "distance": "4 miles"
    },
    {
      "id": "lytham-5",
      "name": "Lytham St Annes 5",
      "shortName": "LYT",
      "date": "2026-07-05",
      "time": "10:00",
      "location": "Lytham Green",
      "distance": "5 miles"
    },
    {
      "id": "preston-5",
      "name": "Preston Harriers 5",
      "shortName": "PRE",
      "date": "2026-07-19",
      "time": "10:00",
      "location": "Moor Park, Preston",
      "distance": "5 miles"
    },
    {
      "id": "red-rose-4",
      "name": "Red Rose 4",
      "shortName": "RRR",
      "date": "2026-08-02",
      "time": "10:00",
      "location": "Worden Park, Leyland",
      "distance": "4 miles"
    },
    {
      "id": "thornton-5",
      "name": "Thornton Cleveleys 5",
      "shortName": "THO",
      "date": "2026-08-16",
      "time": "10:00",
      "location": "Anchorsholme Park",
      "distance": "5 miles"
    },
    {
      "id": "wesham-5",
      "name": "Wesham 5",
      "shortName": "WES",
      "date": "2026-08-30",
      "time": "10:00",
      "location": "Wesham",
      "distance": "5 miles"
    }
  ]
  ```

- [ ] **Step 2: Add `shortName` to fell races**

  Replace the contents of `src/data/2026/fell/races.json` with:

  ```json
  [
    {
      "id": "fell-race-1",
      "name": "Fell Race 1",
      "shortName": "FR1",
      "date": "2026-06-14",
      "time": "11:00",
      "location": "TBC",
      "distance": "TBC"
    },
    {
      "id": "fell-race-2",
      "name": "Fell Race 2",
      "shortName": "FR2",
      "date": "2026-07-12",
      "time": "11:00",
      "location": "TBC",
      "distance": "TBC"
    },
    {
      "id": "fell-race-3",
      "name": "Fell Race 3",
      "shortName": "FR3",
      "date": "2026-08-09",
      "time": "11:00",
      "location": "TBC",
      "distance": "TBC"
    },
    {
      "id": "fell-race-4",
      "name": "Fell Race 4",
      "shortName": "FR4",
      "date": "2026-09-06",
      "time": "11:00",
      "location": "TBC",
      "distance": "TBC"
    }
  ]
  ```

- [ ] **Step 3: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add src/data/2026/road-gp/races.json src/data/2026/fell/races.json
  git commit -m "feat: add shortName abbreviations to race data"
  ```

---

### Task 3: Write failing tests for `parseTeamStandingsPath`

**Files:**
- Modify: `tests/lib/results.test.ts`

- [ ] **Step 1: Add failing tests**

  Append to `tests/lib/results.test.ts`:

  ```typescript
  describe('parseTeamStandingsPath', () => {
    it('parses a road-gp standings path', () => {
      expect(parseTeamStandingsPath('../data/2026/road-gp/team-standings.json'))
        .toEqual({ year: 2026 });
    });

    it('parses a fell standings path', () => {
      expect(parseTeamStandingsPath('../data/2026/fell/team-standings.json'))
        .toEqual({ year: 2026 });
    });

    it('returns null for a team results path', () => {
      expect(parseTeamStandingsPath('../data/2026/road-gp/results/bwf-5-teams.json'))
        .toBeNull();
    });

    it('returns null for a config path', () => {
      expect(parseTeamStandingsPath('../data/2026/road-gp/config.json'))
        .toBeNull();
    });
  });
  ```

  Also update the import at the top of the file to include `parseTeamStandingsPath`:

  ```typescript
  import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath } from '../../src/lib/results';
  ```

- [ ] **Step 2: Run tests to confirm they fail**

  ```bash
  npm test
  ```

  Expected: 4 new failures — `parseTeamStandingsPath is not a function` (or similar).

---

### Task 4: Implement standings loading in `results.ts`

**Files:**
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Add the import and globs**

  Add the `TeamStandings` import and two new glob constants to `src/lib/results.ts`. Place the import alongside the existing type imports at the top, and the globs after the existing `fellTeamFiles` glob:

  ```typescript
  import type { Club, RaceResult, Series, SeriesConfig, TeamResults, TeamStandings } from './types';
  ```

  After the `fellTeamFiles` glob, add:

  ```typescript
  const roadStandingsFiles = import.meta.glob<{ default: TeamStandings }>(
    '../data/*/road-gp/team-standings.json', { eager: true }
  );
  const fellStandingsFiles = import.meta.glob<{ default: TeamStandings }>(
    '../data/*/fell/team-standings.json', { eager: true }
  );

  function standingsFilesForSeries(series: Series) {
    return series === 'road-gp' ? roadStandingsFiles : fellStandingsFiles;
  }
  ```

- [ ] **Step 2: Add `parseTeamStandingsPath`**

  Add after the existing `parseTeamResultsPath` function:

  ```typescript
  export function parseTeamStandingsPath(path: string): { year: number } | null {
    const match = path.match(/\/data\/(\d+)\/[^/]+\/team-standings\.json$/);
    if (!match) return null;
    return { year: parseInt(match[1], 10) };
  }
  ```

- [ ] **Step 3: Add `getTeamStandings`, `hasTeamStandings`, `getTeamStandingsStaticPaths`**

  Add after `parseTeamStandingsPath`:

  ```typescript
  export function getTeamStandings(year: number, series: Series): TeamStandings | null {
    const files = standingsFilesForSeries(series);
    return files[`../data/${year}/${series}/team-standings.json`]?.default ?? null;
  }

  export function hasTeamStandings(year: number, series: Series): boolean {
    const files = standingsFilesForSeries(series);
    return `../data/${year}/${series}/team-standings.json` in files;
  }

  export function getTeamStandingsStaticPaths(series: Series) {
    const files = standingsFilesForSeries(series);
    return Object.keys(files).flatMap(path => {
      const parsed = parseTeamStandingsPath(path);
      if (!parsed) return [];
      const { year } = parsed;
      const standings = files[path].default;
      const clubs = getClubs(year);
      const config = getSeriesConfig(year, series);
      const linkedRaceIds = standings.races.filter(raceId =>
        hasTeamResults(year, series, raceId)
      );
      return [{
        params: { year: String(year) },
        props: { year, standings, clubs, config, linkedRaceIds },
      }];
    });
  }
  ```

- [ ] **Step 4: Run tests to confirm they pass**

  ```bash
  npm test
  ```

  Expected: all tests pass, including the 4 new `parseTeamStandingsPath` tests.

- [ ] **Step 5: Commit**

  ```bash
  git add src/lib/results.ts tests/lib/results.test.ts
  git commit -m "feat: add team standings loading and static paths helper"
  ```

---

### Task 5: Add Team Standings link to schedule pages

**Files:**
- Modify: `src/components/RaceList.astro`
- Modify: `src/pages/road-gp/index.astro`
- Modify: `src/pages/road-gp/[year]/index.astro`
- Modify: `src/pages/fell/index.astro`
- Modify: `src/pages/fell/[year]/index.astro`

- [ ] **Step 1: Add `standingsUrl` prop to `RaceList.astro`**

  Replace the `Props` interface and destructuring in `src/components/RaceList.astro`:

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
  }

  const { races, year, series, availableYears, currentYear, seriesBasePath, seriesLabel, standingsUrl } = Astro.props;
  ```

  In the template, add the standings link after the `<h1>` and year filter row, before the race cards:

  ```astro
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

    {standingsUrl && (
      <div class="mb-4">
        <a href={standingsUrl} class="btn btn-sm btn-outline gap-1">
          Team Standings →
        </a>
      </div>
    )}

    {races.length === 0 ? (
      <p class="text-base-content/60">No races found for {year}.</p>
    ) : (
      <div class="flex flex-col gap-4">
        {races.map(race => (
          <RaceCard race={race} year={year} series={series} />
        ))}
      </div>
    )}
  </div>
  ```

- [ ] **Step 2: Update `src/pages/road-gp/index.astro`**

  ```astro
  ---
  // src/pages/road-gp/index.astro
  import Layout from '../../components/Layout.astro';
  import RaceList from '../../components/RaceList.astro';
  import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
  import { hasTeamStandings } from '../../lib/results';

  const currentYear = getCurrentYear();
  const availableYears = getAvailableYears('road-gp');
  const races = getRaces(currentYear, 'road-gp');
  const standingsUrl = hasTeamStandings(currentYear, 'road-gp')
    ? `/road-gp/${currentYear}/team-standings`
    : undefined;
  ---

  <Layout title="Road Grand Prix">
    <RaceList
      races={races}
      year={currentYear}
      series="road-gp"
      availableYears={availableYears}
      currentYear={currentYear}
      seriesBasePath="/road-gp"
      seriesLabel="Road Grand Prix"
      standingsUrl={standingsUrl}
    />
  </Layout>
  ```

- [ ] **Step 3: Update `src/pages/road-gp/[year]/index.astro`**

  ```astro
  ---
  // src/pages/road-gp/[year]/index.astro
  import Layout from '../../../components/Layout.astro';
  import RaceList from '../../../components/RaceList.astro';
  import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
  import { hasTeamStandings } from '../../../lib/results';

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
  const standingsUrl = hasTeamStandings(year, 'road-gp')
    ? `/road-gp/${year}/team-standings`
    : undefined;
  ---

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
    />
  </Layout>
  ```

- [ ] **Step 4: Update `src/pages/fell/index.astro`**

  ```astro
  ---
  // src/pages/fell/index.astro
  import Layout from '../../components/Layout.astro';
  import RaceList from '../../components/RaceList.astro';
  import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
  import { hasTeamStandings } from '../../lib/results';

  const currentYear = getCurrentYear();
  const availableYears = getAvailableYears('fell');
  const races = getRaces(currentYear, 'fell');
  const standingsUrl = hasTeamStandings(currentYear, 'fell')
    ? `/fell/${currentYear}/team-standings`
    : undefined;
  ---

  <Layout title="Fell Championship">
    <RaceList
      races={races}
      year={currentYear}
      series="fell"
      availableYears={availableYears}
      currentYear={currentYear}
      seriesBasePath="/fell"
      seriesLabel="Fell Championship"
      standingsUrl={standingsUrl}
    />
  </Layout>
  ```

- [ ] **Step 5: Update `src/pages/fell/[year]/index.astro`**

  Read the existing file first, then replace its full content with:

  ```astro
  ---
  // src/pages/fell/[year]/index.astro
  import Layout from '../../../components/Layout.astro';
  import RaceList from '../../../components/RaceList.astro';
  import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
  import { hasTeamStandings } from '../../../lib/results';

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
  const standingsUrl = hasTeamStandings(year, 'fell')
    ? `/fell/${year}/team-standings`
    : undefined;
  ---

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
    />
  </Layout>
  ```

- [ ] **Step 6: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: no errors. (No standings link appears yet — no data file exists.)

- [ ] **Step 7: Commit**

  ```bash
  git add src/components/RaceList.astro src/pages/road-gp/index.astro src/pages/road-gp/\[year\]/index.astro src/pages/fell/index.astro src/pages/fell/\[year\]/index.astro
  git commit -m "feat: add Team Standings link to series schedule pages"
  ```

---

### Task 6: Create Road GP standings page

**Files:**
- Create: `src/pages/road-gp/[year]/team-standings.astro`

- [ ] **Step 1: Create the page**

  Create `src/pages/road-gp/[year]/team-standings.astro` with the full content below:

  ```astro
  ---
  // src/pages/road-gp/[year]/team-standings.astro
  import Layout from '../../../../components/Layout.astro';
  import { getRaces } from '../../../../lib/data';
  import { getTeamStandingsStaticPaths } from '../../../../lib/results';
  import type { Club, SeriesConfig, TeamStandings } from '../../../../lib/types';

  export async function getStaticPaths() {
    return getTeamStandingsStaticPaths('road-gp');
  }

  interface Props {
    year: number;
    standings: TeamStandings;
    clubs: Club[];
    config: SeriesConfig;
    linkedRaceIds: string[];
  }

  const { year, standings, clubs, config } = Astro.props;
  const linkedRaceIds = new Set(Astro.props.linkedRaceIds);
  const races = getRaces(year, 'road-gp');
  const raceById = Object.fromEntries(races.map(r => [r.id, r]));
  const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
  const categoryById = Object.fromEntries((config.teamCategories ?? []).map(c => [c.id, c]));
  ---

  <Layout title={`Road GP ${year} — Team Standings`}>
    <div class="mb-4">
      <a href={`/road-gp/${year}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Road GP {year}</a>
    </div>

    <div class="mb-6">
      <div class="flex items-center gap-3 flex-wrap">
        <h1 class="text-2xl font-bold">Team Standings</h1>
        {standings.provisional && (
          <span class="badge badge-warning badge-lg">Provisional</span>
        )}
      </div>
      <p class="text-sm text-base-content/60 mt-1">{year} Inter Club Road Grand Prix</p>
    </div>

    <!-- Category tabs -->
    <div class="overflow-x-auto -mx-4 px-4 mb-1">
      <div class="flex border-b border-base-200 min-w-max" role="tablist">
        {standings.categories.map((cat, i) => {
          const label = categoryById[cat.category]?.name ?? cat.category;
          return (
            <button
              class:list={[
                'tab-btn px-4 py-2 text-sm border-b-2 -mb-px whitespace-nowrap transition-colors',
                i === 0
                  ? 'border-primary font-medium'
                  : 'border-transparent text-base-content/50 hover:text-base-content',
              ]}
              data-target={`cat-panel-${i}`}
              role="tab"
              aria-selected={i === 0 ? 'true' : 'false'}
            >
              {label}
            </button>
          );
        })}
      </div>
    </div>

    <!-- Category panels -->
    {standings.categories.map((cat, i) => (
      <div id={`cat-panel-${i}`} class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">

        <!-- Desktop table (sm and up) -->
        <div class="hidden sm:block overflow-x-auto">
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr class="border-b border-base-200">
                <th class="text-left py-2 pr-3 text-base-content/40 font-medium w-8">#</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Club</th>
                {standings.races.map(raceId => {
                  const race = raceById[raceId];
                  const label = race?.shortName ?? raceId;
                  const href = linkedRaceIds.has(raceId)
                    ? `/road-gp/${year}/${raceId}/team-results`
                    : null;
                  return (
                    <th class="text-right py-2 px-2 font-medium whitespace-nowrap">
                      {href
                        ? <a href={href} class="text-primary hover:underline">{label}</a>
                        : <span class="text-base-content/20">{label}</span>
                      }
                    </th>
                  );
                })}
                <th class="text-right py-2 pl-4 text-base-content/40 font-medium">Total</th>
              </tr>
            </thead>
            <tbody>
              {cat.clubs.map(clubResult => {
                const clubName = clubById[clubResult.club]?.name ?? clubResult.club;
                return (
                  <tr class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30">
                    <td class="py-2.5 pr-3 text-base-content/40 tabular-nums">{clubResult.position}</td>
                    <td class="py-2.5 pr-4 font-semibold">{clubName}</td>
                    {clubResult.points.map(pts => (
                      <td class:list={['py-2.5 px-2 text-right tabular-nums', pts === null && 'text-base-content/20']}>
                        {pts ?? '—'}
                      </td>
                    ))}
                    <td class="py-2.5 pl-4 text-right">
                      <strong class="text-base-content/80">{clubResult.total}</strong>
                      {clubResult.tiebreaker && (
                        <span class="block text-xs text-base-content/40 mt-0.5">{clubResult.tiebreaker}</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <!-- Mobile view (below sm) -->
        <div class="sm:hidden">
          <!-- Race legend -->
          <div class="flex flex-wrap gap-x-3 gap-y-1 py-3 border-b border-base-200 mb-1 text-xs text-base-content/40">
            {standings.races.map(raceId => {
              const race = raceById[raceId];
              const label = race?.shortName ?? raceId;
              const href = linkedRaceIds.has(raceId)
                ? `/road-gp/${year}/${raceId}/team-results`
                : null;
              return (
                <span>
                  {href
                    ? <a href={href} class="text-primary">{label}</a>
                    : label
                  }
                  {' = '}{race?.name ?? raceId}
                </span>
              );
            })}
          </div>

          <!-- Club rows -->
          {cat.clubs.map(clubResult => {
            const clubName = clubById[clubResult.club]?.name ?? clubResult.club;
            const detailId = `detail-${i}-${clubResult.club}`;
            return (
              <div class="border-b border-base-200 last:border-0">
                <button
                  class="standings-toggle w-full flex items-center gap-2 py-2.5 text-left"
                  data-target={detailId}
                  aria-expanded="false"
                >
                  <span class="w-6 shrink-0 text-sm text-base-content/40 tabular-nums">{clubResult.position}</span>
                  <span class="flex-1 font-semibold">{clubName}</span>
                  <strong class="text-base-content/80">{clubResult.total}</strong>
                  <span class="chevron text-base-content/30 text-xs ml-1 transition-transform">▾</span>
                </button>
                <div id={detailId} class="hidden pb-3">
                  <div class="flex flex-wrap gap-1.5 pl-8">
                    {clubResult.points.map((pts, raceIdx) => {
                      const raceId = standings.races[raceIdx];
                      const race = raceById[raceId];
                      const label = race?.shortName ?? raceId;
                      const href = linkedRaceIds.has(raceId)
                        ? `/road-gp/${year}/${raceId}/team-results`
                        : null;
                      const isEmpty = pts === null;
                      return (
                        <div class:list={[
                          'rounded px-2.5 py-1 text-center text-sm min-w-[44px]',
                          isEmpty ? 'bg-base-200/40' : 'bg-base-200',
                        ]}>
                          {href
                            ? <a href={href} class="block text-[10px] text-primary mb-0.5">{label}</a>
                            : <span class:list={['block text-[10px] mb-0.5', isEmpty ? 'text-base-content/20' : 'text-base-content/40']}>{label}</span>
                          }
                          <span class:list={[isEmpty ? 'text-base-content/20' : 'font-semibold']}>{pts ?? '—'}</span>
                        </div>
                      );
                    })}
                  </div>
                  {clubResult.tiebreaker && (
                    <p class="pl-8 mt-1.5 text-xs text-base-content/40">{clubResult.tiebreaker}</p>
                  )}
                </div>
              </div>
            );
          })}
        </div>

      </div>
    ))}
  </Layout>

  <script>
    // Tab switching
    const tabs = document.querySelectorAll<HTMLButtonElement>('.tab-btn');
    tabs.forEach(btn => {
      btn.addEventListener('click', () => {
        const targetId = btn.dataset.target!;
        tabs.forEach(t => {
          const active = t === btn;
          t.classList.toggle('border-primary', active);
          t.classList.toggle('font-medium', active);
          t.classList.toggle('border-transparent', !active);
          t.classList.toggle('text-base-content/50', !active);
          t.setAttribute('aria-selected', active ? 'true' : 'false');
        });
        document.querySelectorAll<HTMLElement>('[id^="cat-panel-"]').forEach(panel => {
          panel.classList.toggle('hidden', panel.id !== targetId);
        });
      });
    });

    // Expand / collapse club rows on mobile
    document.querySelectorAll<HTMLButtonElement>('.standings-toggle').forEach(btn => {
      btn.addEventListener('click', () => {
        const targetId = btn.dataset.target!;
        const detail = document.getElementById(targetId)!;
        const isOpen = !detail.classList.contains('hidden');
        detail.classList.toggle('hidden', isOpen);
        btn.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
        btn.querySelector('.chevron')?.classList.toggle('rotate-180', !isOpen);
      });
    });
  </script>
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: no errors. (No page generated yet — no data file exists.)

- [ ] **Step 3: Commit**

  ```bash
  git add src/pages/road-gp/\[year\]/team-standings.astro
  git commit -m "feat: add Road GP team standings page"
  ```

---

### Task 7: Create Fell standings page

**Files:**
- Create: `src/pages/fell/[year]/team-standings.astro`

- [ ] **Step 1: Create the page**

  Create `src/pages/fell/[year]/team-standings.astro`. It is identical to the Road GP page except for three things: the series is `'fell'`, import paths use `'../../../../lib/...'` → same depth so no change, and the back link and race URLs use `/fell/`:

  ```astro
  ---
  // src/pages/fell/[year]/team-standings.astro
  import Layout from '../../../../components/Layout.astro';
  import { getRaces } from '../../../../lib/data';
  import { getTeamStandingsStaticPaths } from '../../../../lib/results';
  import type { Club, SeriesConfig, TeamStandings } from '../../../../lib/types';

  export async function getStaticPaths() {
    return getTeamStandingsStaticPaths('fell');
  }

  interface Props {
    year: number;
    standings: TeamStandings;
    clubs: Club[];
    config: SeriesConfig;
    linkedRaceIds: string[];
  }

  const { year, standings, clubs, config } = Astro.props;
  const linkedRaceIds = new Set(Astro.props.linkedRaceIds);
  const races = getRaces(year, 'fell');
  const raceById = Object.fromEntries(races.map(r => [r.id, r]));
  const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
  const categoryById = Object.fromEntries((config.teamCategories ?? []).map(c => [c.id, c]));
  ---

  <Layout title={`Fell Championship ${year} — Team Standings`}>
    <div class="mb-4">
      <a href={`/fell/${year}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Fell Championship {year}</a>
    </div>

    <div class="mb-6">
      <div class="flex items-center gap-3 flex-wrap">
        <h1 class="text-2xl font-bold">Team Standings</h1>
        {standings.provisional && (
          <span class="badge badge-warning badge-lg">Provisional</span>
        )}
      </div>
      <p class="text-sm text-base-content/60 mt-1">{year} Inter Club Fell Championship</p>
    </div>

    <!-- Category tabs -->
    <div class="overflow-x-auto -mx-4 px-4 mb-1">
      <div class="flex border-b border-base-200 min-w-max" role="tablist">
        {standings.categories.map((cat, i) => {
          const label = categoryById[cat.category]?.name ?? cat.category;
          return (
            <button
              class:list={[
                'tab-btn px-4 py-2 text-sm border-b-2 -mb-px whitespace-nowrap transition-colors',
                i === 0
                  ? 'border-primary font-medium'
                  : 'border-transparent text-base-content/50 hover:text-base-content',
              ]}
              data-target={`cat-panel-${i}`}
              role="tab"
              aria-selected={i === 0 ? 'true' : 'false'}
            >
              {label}
            </button>
          );
        })}
      </div>
    </div>

    <!-- Category panels -->
    {standings.categories.map((cat, i) => (
      <div id={`cat-panel-${i}`} class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">

        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto">
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr class="border-b border-base-200">
                <th class="text-left py-2 pr-3 text-base-content/40 font-medium w-8">#</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Club</th>
                {standings.races.map(raceId => {
                  const race = raceById[raceId];
                  const label = race?.shortName ?? raceId;
                  const href = linkedRaceIds.has(raceId)
                    ? `/fell/${year}/${raceId}/team-results`
                    : null;
                  return (
                    <th class="text-right py-2 px-2 font-medium whitespace-nowrap">
                      {href
                        ? <a href={href} class="text-primary hover:underline">{label}</a>
                        : <span class="text-base-content/20">{label}</span>
                      }
                    </th>
                  );
                })}
                <th class="text-right py-2 pl-4 text-base-content/40 font-medium">Total</th>
              </tr>
            </thead>
            <tbody>
              {cat.clubs.map(clubResult => {
                const clubName = clubById[clubResult.club]?.name ?? clubResult.club;
                return (
                  <tr class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30">
                    <td class="py-2.5 pr-3 text-base-content/40 tabular-nums">{clubResult.position}</td>
                    <td class="py-2.5 pr-4 font-semibold">{clubName}</td>
                    {clubResult.points.map(pts => (
                      <td class:list={['py-2.5 px-2 text-right tabular-nums', pts === null && 'text-base-content/20']}>
                        {pts ?? '—'}
                      </td>
                    ))}
                    <td class="py-2.5 pl-4 text-right">
                      <strong class="text-base-content/80">{clubResult.total}</strong>
                      {clubResult.tiebreaker && (
                        <span class="block text-xs text-base-content/40 mt-0.5">{clubResult.tiebreaker}</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <!-- Mobile view -->
        <div class="sm:hidden">
          <div class="flex flex-wrap gap-x-3 gap-y-1 py-3 border-b border-base-200 mb-1 text-xs text-base-content/40">
            {standings.races.map(raceId => {
              const race = raceById[raceId];
              const label = race?.shortName ?? raceId;
              const href = linkedRaceIds.has(raceId)
                ? `/fell/${year}/${raceId}/team-results`
                : null;
              return (
                <span>
                  {href
                    ? <a href={href} class="text-primary">{label}</a>
                    : label
                  }
                  {' = '}{race?.name ?? raceId}
                </span>
              );
            })}
          </div>

          {cat.clubs.map(clubResult => {
            const clubName = clubById[clubResult.club]?.name ?? clubResult.club;
            const detailId = `detail-${i}-${clubResult.club}`;
            return (
              <div class="border-b border-base-200 last:border-0">
                <button
                  class="standings-toggle w-full flex items-center gap-2 py-2.5 text-left"
                  data-target={detailId}
                  aria-expanded="false"
                >
                  <span class="w-6 shrink-0 text-sm text-base-content/40 tabular-nums">{clubResult.position}</span>
                  <span class="flex-1 font-semibold">{clubName}</span>
                  <strong class="text-base-content/80">{clubResult.total}</strong>
                  <span class="chevron text-base-content/30 text-xs ml-1 transition-transform">▾</span>
                </button>
                <div id={detailId} class="hidden pb-3">
                  <div class="flex flex-wrap gap-1.5 pl-8">
                    {clubResult.points.map((pts, raceIdx) => {
                      const raceId = standings.races[raceIdx];
                      const race = raceById[raceId];
                      const label = race?.shortName ?? raceId;
                      const href = linkedRaceIds.has(raceId)
                        ? `/fell/${year}/${raceId}/team-results`
                        : null;
                      const isEmpty = pts === null;
                      return (
                        <div class:list={[
                          'rounded px-2.5 py-1 text-center text-sm min-w-[44px]',
                          isEmpty ? 'bg-base-200/40' : 'bg-base-200',
                        ]}>
                          {href
                            ? <a href={href} class="block text-[10px] text-primary mb-0.5">{label}</a>
                            : <span class:list={['block text-[10px] mb-0.5', isEmpty ? 'text-base-content/20' : 'text-base-content/40']}>{label}</span>
                          }
                          <span class:list={[isEmpty ? 'text-base-content/20' : 'font-semibold']}>{pts ?? '—'}</span>
                        </div>
                      );
                    })}
                  </div>
                  {clubResult.tiebreaker && (
                    <p class="pl-8 mt-1.5 text-xs text-base-content/40">{clubResult.tiebreaker}</p>
                  )}
                </div>
              </div>
            );
          })}
        </div>

      </div>
    ))}
  </Layout>

  <script>
    const tabs = document.querySelectorAll<HTMLButtonElement>('.tab-btn');
    tabs.forEach(btn => {
      btn.addEventListener('click', () => {
        const targetId = btn.dataset.target!;
        tabs.forEach(t => {
          const active = t === btn;
          t.classList.toggle('border-primary', active);
          t.classList.toggle('font-medium', active);
          t.classList.toggle('border-transparent', !active);
          t.classList.toggle('text-base-content/50', !active);
          t.setAttribute('aria-selected', active ? 'true' : 'false');
        });
        document.querySelectorAll<HTMLElement>('[id^="cat-panel-"]').forEach(panel => {
          panel.classList.toggle('hidden', panel.id !== targetId);
        });
      });
    });

    document.querySelectorAll<HTMLButtonElement>('.standings-toggle').forEach(btn => {
      btn.addEventListener('click', () => {
        const targetId = btn.dataset.target!;
        const detail = document.getElementById(targetId)!;
        const isOpen = !detail.classList.contains('hidden');
        detail.classList.toggle('hidden', isOpen);
        btn.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
        btn.querySelector('.chevron')?.classList.toggle('rotate-180', !isOpen);
      });
    });
  </script>
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: no errors.

- [ ] **Step 3: Commit**

  ```bash
  git add src/pages/fell/\[year\]/team-standings.astro
  git commit -m "feat: add Fell Championship team standings page"
  ```

---

### Task 8: Add sample standings data and verify end-to-end

**Files:**
- Create: `src/data/2026/road-gp/team-standings.json`

- [ ] **Step 1: Create the standings data file**

  Create `src/data/2026/road-gp/team-standings.json` with Blackpool race results:

  ```json
  {
    "provisional": true,
    "races": ["bwf-5", "chorley-4", "lytham-5", "preston-5", "red-rose-4", "thornton-5", "wesham-5"],
    "categories": [
      {
        "category": "open",
        "clubs": [
          { "position": 1, "club": "wesham",   "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "preston",  "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "blackpool","points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "red-rose", "points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "lytham",   "points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "chorley",  "points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "thornton", "points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      },
      {
        "category": "ladies",
        "clubs": [
          { "position": 1, "club": "preston",  "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "lytham",   "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "wesham",   "points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "red-rose", "points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "blackpool","points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "thornton", "points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "chorley",  "points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      },
      {
        "category": "fv40",
        "clubs": [
          { "position": 1, "club": "lytham",   "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "preston",  "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "wesham",   "points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "red-rose", "points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "thornton", "points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "blackpool","points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "chorley",  "points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      },
      {
        "category": "vets",
        "clubs": [
          { "position": 1, "club": "wesham",   "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "preston",  "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "blackpool","points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "red-rose", "points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "lytham",   "points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "thornton", "points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "chorley",  "points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      },
      {
        "category": "vet50s",
        "clubs": [
          { "position": 1, "club": "wesham",   "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "red-rose", "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "preston",  "points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "blackpool","points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "lytham",   "points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "chorley",  "points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "thornton", "points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      },
      {
        "category": "vet60s",
        "clubs": [
          { "position": 1, "club": "wesham",   "points": [7, null, null, null, null, null, null], "total": 7, "tiebreaker": null },
          { "position": 2, "club": "red-rose", "points": [6, null, null, null, null, null, null], "total": 6, "tiebreaker": null },
          { "position": 3, "club": "thornton", "points": [5, null, null, null, null, null, null], "total": 5, "tiebreaker": null },
          { "position": 4, "club": "lytham",   "points": [4, null, null, null, null, null, null], "total": 4, "tiebreaker": null },
          { "position": 5, "club": "chorley",  "points": [3, null, null, null, null, null, null], "total": 3, "tiebreaker": null },
          { "position": 6, "club": "preston",  "points": [2, null, null, null, null, null, null], "total": 2, "tiebreaker": null },
          { "position": 7, "club": "blackpool","points": [1, null, null, null, null, null, null], "total": 1, "tiebreaker": null }
        ]
      }
    ]
  }
  ```

- [ ] **Step 2: Build and verify page generates**

  ```bash
  npm run build
  ```

  Expected: build succeeds and `dist/road-gp/2026/team-standings/index.html` is created.

- [ ] **Step 3: Preview and check the page**

  ```bash
  npm run preview
  ```

  Open `http://localhost:4321/road-gp/2026/` — confirm the **Team Standings →** button appears.
  Click through to `http://localhost:4321/road-gp/2026/team-standings/` — confirm:
  - Provisional badge is visible
  - All 6 category tabs are present and switch correctly
  - Desktop: table shows 7 race columns (BPL linked, others in muted text), Total column
  - Mobile (resize to <640 px): race legend appears, club rows expand on tap, BPL pill label links to team results
  - Tiebreaker row: not shown (all null)

- [ ] **Step 4: Run tests**

  ```bash
  npm test
  ```

  Expected: all tests pass.

- [ ] **Step 5: Commit**

  ```bash
  git add src/data/2026/road-gp/team-standings.json
  git commit -m "feat: add provisional team standings data after Blackpool race"
  ```
