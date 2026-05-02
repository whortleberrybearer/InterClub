# Runner Profiles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add runner profile pages at `/runners/{id}-{slug}/` aggregating all results and awards across years and both series, with runner name links from existing results, standings, and awards pages.

**Architecture:** Two-tier identity — a global registry (`src/data/runners.json`) holds stable numeric IDs mapped to canonical names; per-year/series runner files (`src/data/{year}/{series}/runners.json`) hold series-local IDs referenced from CSVs and awards. A new `src/lib/runners.ts` handles all runner data loading and URL resolution. Existing pages gain optional links wherever `series_runner_id` is populated; pages degrade gracefully when absent.

**Tech Stack:** Astro 6, TypeScript strict, Tailwind CSS v4 + DaisyUI v5, Vitest (tests in `tests/lib/*.test.ts`, pure functions only)

---

## File Map

| Action | File |
|--------|------|
| Modify | `src/lib/types.ts` |
| Modify | `src/lib/results.ts` |
| Create | `src/lib/runners.ts` |
| Create | `src/data/runners.json` |
| Create | `src/data/2026/road-gp/runners.json` |
| Create | `src/data/2026/fell/runners.json` |
| Modify | `src/data/2026/road-gp/results/bwf-5-provisional.csv` |
| Create | `src/pages/runners/[slug].astro` |
| Modify | `src/pages/road-gp/[year]/[raceId]/results.astro` |
| Modify | `src/pages/fell/[year]/[raceId]/results.astro` |
| Modify | `src/pages/road-gp/[year]/individual-standings.astro` |
| Modify | `src/pages/fell/[year]/individual-standings.astro` |
| Modify | `src/components/SeriesAwards.astro` |
| Modify | `src/pages/road-gp/[year]/index.astro` |
| Modify | `src/pages/fell/[year]/index.astro` |
| Create | `tests/lib/runners.test.ts` |
| Modify | `tests/lib/results.test.ts` (create if absent) |
| Modify | `CLAUDE.md` |

---

## Task 1: Add Types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Add new interfaces and update existing ones**

In `src/lib/types.ts`, add after the `Club` interface:

```ts
export interface GlobalRunner {
  id: number;
  firstName: string;
  lastName: string;
  club: string;       // club id matching clubs.json
  sex: string;        // 'M' or 'F'
  category: string;   // e.g. 'SEN', 'V40'
}

export interface SeriesRunner {
  id: number;         // series-local numeric ID; referenced from CSV series_runner_id
  runnerId: number;   // references GlobalRunner.id
  firstName: string;
  lastName: string;
  club: string;
  sex: string;
  category: string;
  number?: number;    // optional bib number
}

export interface RunnerProfileRace {
  date: string;       // ISO date e.g. "2026-04-01"
  raceName: string;
  raceId: string;
  time: string;
  hasResults: boolean;
}

export interface RunnerProfileAward {
  categoryName: string;
  position: number;
}

export interface RunnerYearSeries {
  races: RunnerProfileRace[];
  awards: RunnerProfileAward[];
}

export interface RunnerYearBlock {
  year: number;
  roadGp?: RunnerYearSeries;
  fell?: RunnerYearSeries;
}
```

Add `seriesRunnerId: number | null` to `RaceResult`:

```ts
export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;
  category: string;
  sex: string;
  time: string;
  seriesRunnerId: number | null;   // ← add this line
}
```

Add `seriesRunnerId?: number` to `IndividualAwardEntry`:

```ts
export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;
  seriesRunnerId?: number;   // ← add this line
}
```

Add `seriesRunnerId?: number` to `IndividualStandingsRunner`:

```ts
export interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex: string;
  ageCategory: string;
  total: number;
  results: Record<string, IndividualRaceResult>;
  seriesRunnerId?: number;   // ← add this line
}
```

Add `runnerUrl?: string` to `ResolvedIndividualAwardEntry`:

```ts
export interface ResolvedIndividualAwardEntry {
  position: number;
  name: string;
  clubName: string;
  runnerUrl?: string;   // ← add this line
}
```

- [ ] **Commit**

```bash
git add src/lib/types.ts
git commit -m "feat(types): add runner identity and profile types"
```

---

## Task 2: Update parseResultsCsv + Tests

**Files:**
- Modify: `src/lib/results.ts`
- Create: `tests/lib/results.test.ts`

- [ ] **Update parseResultsCsv to parse series_runner_id**

In `src/lib/results.ts`, change the return inside `parseResultsCsv`:

```ts
return {
  position: num('position'),
  icPosition: num('ic_position'),
  firstName: get('first_name'),
  lastName: get('last_name'),
  club: get('club'),
  category: get('category'),
  sex: get('sex'),
  time: get('time'),
  seriesRunnerId: num('series_runner_id'),   // ← add this line
};
```

- [ ] **Write tests**

Create `tests/lib/results.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { parseResultsCsv } from '../../src/lib/results';

const BASE_CSV = `position,ic_position,first_name,last_name,club,category,sex,time
1,1,Luke,Minns,blackpool,V35,M,19:35
2,2,Rob,Danson,preston,V35,M,19:38`;

describe('parseResultsCsv', () => {
  it('parses basic fields', () => {
    const results = parseResultsCsv(BASE_CSV);
    expect(results).toHaveLength(2);
    expect(results[0]).toMatchObject({
      position: 1,
      icPosition: 1,
      firstName: 'Luke',
      lastName: 'Minns',
      club: 'blackpool',
      category: 'V35',
      sex: 'M',
      time: '19:35',
      seriesRunnerId: null,
    });
  });

  it('parses series_runner_id when present', () => {
    const csv = `position,ic_position,first_name,last_name,club,category,sex,time,series_runner_id
1,1,Luke,Minns,blackpool,V35,M,19:35,2
11,,T.,Guest,Guest,SEN,M,21:44,`;
    const results = parseResultsCsv(csv);
    expect(results[0].seriesRunnerId).toBe(2);
    expect(results[1].seriesRunnerId).toBeNull();
  });

  it('returns seriesRunnerId null when column absent', () => {
    const results = parseResultsCsv(BASE_CSV);
    results.forEach(r => expect(r.seriesRunnerId).toBeNull());
  });

  it('returns empty array for CSV with only a header', () => {
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,category,sex,time')).toEqual([]);
  });

  it('handles CRLF line endings', () => {
    const csv = BASE_CSV.replace(/\n/g, '\r\n');
    expect(parseResultsCsv(csv)).toHaveLength(2);
  });
});
```

- [ ] **Run tests to verify they pass**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Commit**

```bash
git add src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat(results): parse series_runner_id from CSV; add tests"
```

---

## Task 3: Seed Data Files

**Files:**
- Create: `src/data/runners.json`
- Create: `src/data/2026/road-gp/runners.json`
- Create: `src/data/2026/fell/runners.json`
- Modify: `src/data/2026/road-gp/results/bwf-5-provisional.csv`

- [ ] **Create global runner registry**

Create `src/data/runners.json`:

```json
[
  {
    "id": 1,
    "firstName": "Luke",
    "lastName": "Minns",
    "club": "blackpool",
    "sex": "M",
    "category": "V35"
  },
  {
    "id": 2,
    "firstName": "Rob",
    "lastName": "Danson",
    "club": "preston",
    "sex": "M",
    "category": "V35"
  }
]
```

- [ ] **Create 2026 Road GP series runner file**

Create `src/data/2026/road-gp/runners.json`:

```json
[
  {
    "id": 1,
    "runnerId": 1,
    "firstName": "Luke",
    "lastName": "Minns",
    "club": "blackpool",
    "sex": "M",
    "category": "V35"
  },
  {
    "id": 2,
    "runnerId": 2,
    "firstName": "Rob",
    "lastName": "Danson",
    "club": "preston",
    "sex": "M",
    "category": "V35"
  }
]
```

- [ ] **Create 2026 Fell series runner file**

Create `src/data/2026/fell/runners.json` (empty — no fell results yet):

```json
[]
```

- [ ] **Add series_runner_id to the existing CSV**

Edit `src/data/2026/road-gp/results/bwf-5-provisional.csv` — append `series_runner_id` column. Rows without an assigned runner leave it blank:

```
position,ic_position,first_name,last_name,club,category,sex,time,series_runner_id
1,1,Luke,Minns,blackpool,V35,M,19:35,1
2,2,Rob,Danson,preston,V35,M,19:38,2
3,3,Jude,Cowan,blackpool,SEN,M,20:33,
4,4,Mike,Toft,lytham,V35,M,20:45,
5,5,Max,Swarbrick,wesham,U23,M,21:09,
6,6,Jake,Rodwell,lytham,U23,M,21:10,
7,7,Simon,Croft,red-rose,V40,M,21:11,
8,8,John,Townsend,wesham,V40,M,21:14,
9,9,Adam,Wilding,wesham,SEN,M,21:19,
10,10,Archie,Bellfield,blackpool,U17,M,21:37,
11,,T.,Guest,Guest,SEN,M,21:44,
12,11,Noah,Cox,blackpool,U23,M,21:40,
13,12,Luke,Suffolk,preston,U23,M,21:42,
14,13,Andy,Cottam,preston,V45,M,21:55,
15,14,Emily,Simm,blackpool,V35,F,22:01,
```

- [ ] **Commit**

```bash
git add src/data/runners.json src/data/2026/road-gp/runners.json src/data/2026/fell/runners.json src/data/2026/road-gp/results/bwf-5-provisional.csv
git commit -m "feat(data): add runner registry seed data and series_runner_id to CSV"
```

---

## Task 4: runners.ts — Pure Functions + Tests

**Files:**
- Create: `src/lib/runners.ts` (pure functions only, no globs yet)
- Create: `tests/lib/runners.test.ts`

- [ ] **Write failing tests first**

Create `tests/lib/runners.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { runnerSlug, parseSeriesRunnerPath } from '../../src/lib/runners';
import type { GlobalRunner } from '../../src/lib/types';

const makeRunner = (overrides: Partial<GlobalRunner> = {}): GlobalRunner => ({
  id: 1,
  firstName: 'Luke',
  lastName: 'Minns',
  club: 'blackpool',
  sex: 'M',
  category: 'V35',
  ...overrides,
});

describe('runnerSlug', () => {
  it('produces id-firstname-lastname', () => {
    expect(runnerSlug(makeRunner())).toBe('1-luke-minns');
  });

  it('uses the global numeric id as prefix', () => {
    expect(runnerSlug(makeRunner({ id: 42 }))).toBe('42-luke-minns');
  });

  it('lowercases the name', () => {
    expect(runnerSlug(makeRunner({ firstName: 'JANE', lastName: 'DOE' }))).toBe('1-jane-doe');
  });

  it('replaces non-alphanumeric characters with hyphens', () => {
    expect(runnerSlug(makeRunner({ firstName: "O'Brien", lastName: 'Smith-Jones' }))).toBe('1-o-brien-smith-jones');
  });

  it('collapses consecutive hyphens', () => {
    expect(runnerSlug(makeRunner({ firstName: 'A  B', lastName: 'C' }))).toBe('1-a-b-c');
  });
});

describe('parseSeriesRunnerPath', () => {
  it('parses road-gp runner path', () => {
    expect(parseSeriesRunnerPath('../data/2026/road-gp/runners.json')).toEqual({ year: 2026, series: 'road-gp' });
  });

  it('parses fell runner path', () => {
    expect(parseSeriesRunnerPath('../data/2019/fell/runners.json')).toEqual({ year: 2019, series: 'fell' });
  });

  it('returns null for non-runner paths', () => {
    expect(parseSeriesRunnerPath('../data/2026/road-gp/races.json')).toBeNull();
    expect(parseSeriesRunnerPath('../data/2026/road-gp/results/bwf-5.csv')).toBeNull();
  });
});
```

- [ ] **Run tests to confirm they fail**

```bash
npm test
```

Expected: FAIL — `runnerSlug` and `parseSeriesRunnerPath` not found.

- [ ] **Create src/lib/runners.ts with pure functions**

```ts
import type { GlobalRunner, Series, SeriesRunner } from './types';

export function runnerSlug(runner: GlobalRunner): string {
  const name = `${runner.firstName} ${runner.lastName}`
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  return `${runner.id}-${name}`;
}

export function parseSeriesRunnerPath(path: string): { year: number; series: Series } | null {
  const match = path.match(/\/data\/(\d+)\/(road-gp|fell)\/runners\.json$/);
  if (!match) return null;
  return { year: parseInt(match[1], 10), series: match[2] as Series };
}
```

- [ ] **Run tests to confirm they pass**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Commit**

```bash
git add src/lib/runners.ts tests/lib/runners.test.ts
git commit -m "feat(runners): add runnerSlug and parseSeriesRunnerPath with tests"
```

---

## Task 5: runners.ts — Data Loading and Resolution

**Files:**
- Modify: `src/lib/runners.ts`

- [ ] **Add glob loading and resolution functions**

First, **replace** the single import line at the top of `src/lib/runners.ts` with this merged version:

```ts
import type {
  Club, GlobalRunner, RunnerProfileAward, RunnerProfileRace,
  RunnerYearBlock, RunnerYearSeries, Series, SeriesAwards, SeriesRunner,
} from './types';
import { parseResultsCsv, hasResults, getSeriesConfig } from './results';
import { getRaces } from './data';
```

Then **append** the following after the two existing exported functions (`runnerSlug`, `parseSeriesRunnerPath`):

```ts
const globalRunnerFile = import.meta.glob<{ default: GlobalRunner[] }>(
  '../data/runners.json', { eager: true }
);
const roadSeriesRunnerFiles = import.meta.glob<{ default: SeriesRunner[] }>(
  '../data/*/road-gp/runners.json', { eager: true }
);
const fellSeriesRunnerFiles = import.meta.glob<{ default: SeriesRunner[] }>(
  '../data/*/fell/runners.json', { eager: true }
);
const roadCsvFiles = import.meta.glob<string>(
  '../data/*/road-gp/results/*.csv', { query: '?raw', import: 'default', eager: true }
);
const fellCsvFiles = import.meta.glob<string>(
  '../data/*/fell/results/*.csv', { query: '?raw', import: 'default', eager: true }
);
const roadAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/road-gp/awards.json', { eager: true }
);
const fellAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/fell/awards.json', { eager: true }
);

export function getGlobalRunners(): GlobalRunner[] {
  return globalRunnerFile['../data/runners.json']?.default ?? [];
}

export function getSeriesRunners(year: number, series: Series): SeriesRunner[] {
  const files = series === 'road-gp' ? roadSeriesRunnerFiles : fellSeriesRunnerFiles;
  return files[`../data/${year}/${series}/runners.json`]?.default ?? [];
}

/** Maps series-local runner ID → profile URL for a given year/series. */
export function buildRunnerUrlMap(year: number, series: Series): Record<number, string> {
  const seriesRunners = getSeriesRunners(year, series);
  const globalById = Object.fromEntries(getGlobalRunners().map(r => [r.id, r]));
  const map: Record<number, string> = {};
  for (const sr of seriesRunners) {
    const global = globalById[sr.runnerId];
    if (global) map[sr.id] = `/runners/${runnerSlug(global)}/`;
  }
  return map;
}

// --- Profile page data aggregation ---

function parseCsvPath(path: string, series: Series, year: number): { raceId: string; provisional: boolean } | null {
  const seg = series === 'road-gp' ? 'road-gp' : 'fell';
  const re = new RegExp(`/data/${year}/${seg}/results/(.+?)(-provisional)?\\.csv$`);
  const match = path.match(re);
  if (!match) return null;
  return { raceId: match[1], provisional: !!match[2] };
}

function getRacesForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileRace[] {
  const csvFiles = series === 'road-gp' ? roadCsvFiles : fellCsvFiles;
  const raceList = getRaces(year, series);
  const raceById = Object.fromEntries(raceList.map(r => [r.id, r]));

  // Prefer final over provisional for each raceId
  const seen = new Map<string, { path: string; provisional: boolean }>();
  for (const path of Object.keys(csvFiles)) {
    const parsed = parseCsvPath(path, series, year);
    if (!parsed) continue;
    const existing = seen.get(parsed.raceId);
    if (!existing || (!parsed.provisional && existing.provisional)) {
      seen.set(parsed.raceId, { path, provisional: parsed.provisional });
    }
  }

  const results: RunnerProfileRace[] = [];
  for (const [raceId, { path }] of seen) {
    const raceResults = parseResultsCsv(csvFiles[path]);
    const match = raceResults.find(r => r.seriesRunnerId === seriesLocalId);
    if (!match) continue;
    const race = raceById[raceId];
    if (!race) continue;
    results.push({
      date: race.date,
      raceName: race.name,
      raceId,
      time: match.time,
      hasResults: hasResults(year, series, raceId),
    });
  }
  return results.sort((a, b) => a.date.localeCompare(b.date));
}

function getAwardsForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileAward[] {
  const awardsFiles = series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
  const raw = awardsFiles[`../data/${year}/${series}/awards.json`]?.default;
  if (!raw) return [];
  const config = getSeriesConfig(year, series);
  const found: RunnerProfileAward[] = [];
  for (const ia of raw.individualAwards) {
    const entry = ia.awards.find(a => a.seriesRunnerId === seriesLocalId);
    if (entry) {
      const categoryName = config.individualCategories?.find(c => c.id === ia.category)?.name ?? ia.category;
      found.push({ categoryName, position: entry.position });
    }
  }
  return found;
}

function resolveClubName(clubId: string): string {
  // Search all available clubs.json files for this club id
  const allClubFiles = import.meta.glob<{ default: Club[] }>('../data/*/clubs.json', { eager: true });
  for (const clubs of Object.values(allClubFiles)) {
    const club = clubs.default.find(c => c.id === clubId);
    if (club) return club.name;
  }
  return clubId;
}

export function getRunnerProfileStaticPaths() {
  const globalRunners = getGlobalRunners();
  const allSeriesFiles = { ...roadSeriesRunnerFiles, ...fellSeriesRunnerFiles };

  // Build: globalRunnerId → [{ year, series, seriesLocalId }]
  const globalToSeries = new Map<number, Array<{ year: number; series: Series; seriesLocalId: number }>>();
  for (const [path, fileData] of Object.entries(allSeriesFiles)) {
    const parsed = parseSeriesRunnerPath(path);
    if (!parsed) continue;
    for (const sr of fileData.default) {
      const list = globalToSeries.get(sr.runnerId) ?? [];
      list.push({ year: parsed.year, series: parsed.series, seriesLocalId: sr.id });
      globalToSeries.set(sr.runnerId, list);
    }
  }

  return globalRunners.map(runner => {
    const slug = runnerSlug(runner);
    const entries = globalToSeries.get(runner.id) ?? [];

    // Group into year blocks
    const byYear = new Map<number, RunnerYearBlock>();
    for (const { year, series, seriesLocalId } of entries) {
      const block = byYear.get(year) ?? { year };
      const yearSeries: RunnerYearSeries = {
        races: getRacesForRunner(year, series, seriesLocalId),
        awards: getAwardsForRunner(year, series, seriesLocalId),
      };
      if (series === 'road-gp') block.roadGp = yearSeries;
      else block.fell = yearSeries;
      byYear.set(year, block);
    }

    const yearBlocks = [...byYear.values()].sort((a, b) => b.year - a.year);
    const clubName = resolveClubName(runner.club);

    return {
      params: { slug },
      props: { runner, clubName, yearBlocks },
    };
  });
}
```

> **Note:** The inline `import.meta.glob` for clubs inside `resolveClubName` won't work at runtime — Vite requires globs to be at the top level of a module. Move the clubs glob to the top of the file alongside the others, and reference the module-level variable inside `resolveClubName`.

Correct version — move to module level:

```ts
const allClubFiles = import.meta.glob<{ default: Club[] }>('../data/*/clubs.json', { eager: true });

function resolveClubName(clubId: string): string {
  for (const clubs of Object.values(allClubFiles)) {
    const club = clubs.default.find(c => c.id === clubId);
    if (club) return club.name;
  }
  return clubId;
}
```

Also fix the import at the top of the file — the two import lines should be merged into one:

```ts
import type {
  Club, GlobalRunner, RunnerProfileAward, RunnerProfileRace,
  RunnerYearBlock, RunnerYearSeries, Series, SeriesAwards, SeriesRunner,
} from './types';
import { parseResultsCsv, hasResults, getSeriesConfig } from './results';
import { getRaces } from './data';
```

- [ ] **Verify build compiles without errors**

```bash
npm run build
```

Expected: build succeeds (no TypeScript errors). If the profile page doesn't exist yet the build may error — create a placeholder first if needed (a file with just `---\n---` is enough to unblock).

- [ ] **Commit**

```bash
git add src/lib/runners.ts
git commit -m "feat(runners): add glob loading, buildRunnerUrlMap, getRunnerProfileStaticPaths"
```

---

## Task 6: Runner Profile Page

**Files:**
- Create: `src/pages/runners/[slug].astro`

- [ ] **Create the profile page**

Create `src/pages/runners/[slug].astro`:

```astro
---
import Layout from '../../components/Layout.astro';
import { getRunnerProfileStaticPaths } from '../../lib/runners';
import type { GlobalRunner, RunnerYearBlock, RunnerProfileAward } from '../../lib/types';

export async function getStaticPaths() {
  return getRunnerProfileStaticPaths();
}

interface Props {
  runner: GlobalRunner;
  clubName: string;
  yearBlocks: RunnerYearBlock[];
}

const { runner, clubName, yearBlocks } = Astro.props;
const title = `${runner.firstName} ${runner.lastName}`;
const allYears = yearBlocks.map(b => b.year);

function formatDateShort(isoDate: string): string {
  const d = new Date(isoDate);
  return `${d.getUTCDate()}/${d.getUTCMonth() + 1}`;
}

function positionLabel(pos: number): string {
  const mod10 = pos % 10, mod100 = pos % 100;
  const suffix =
    mod10 === 1 && mod100 !== 11 ? 'st' :
    mod10 === 2 && mod100 !== 12 ? 'nd' :
    mod10 === 3 && mod100 !== 13 ? 'rd' : 'th';
  return `${pos}${suffix}`;
}
---

<Layout title={title}>
  <h1 class="text-2xl font-bold mb-1">{title}</h1>
  <p class="text-sm text-base-content/60 mb-6">
    {clubName} &middot; {runner.sex === 'M' ? 'Men' : 'Women'} &middot; {runner.category}
  </p>

  <!-- Filter bar -->
  <div class="bg-base-100 border border-base-200 rounded-lg p-3 mb-6 flex flex-wrap gap-2 items-center">
    <div class="flex gap-1">
      <button class="btn btn-sm btn-active" data-series-filter="all">All</button>
      <button class="btn btn-sm btn-ghost" data-series-filter="road-gp">Road GP</button>
      <button class="btn btn-sm btn-ghost" data-series-filter="fell">Fell</button>
    </div>
    <select id="filter-year" class="select select-bordered select-sm">
      <option value="">All Years</option>
      {allYears.map(y => <option value={String(y)}>{y}</option>)}
    </select>
    <select id="filter-race" class="select select-bordered select-sm">
      <option value="">All Races</option>
    </select>
  </div>

  <!-- Year blocks -->
  <div id="profile-content">
    {yearBlocks.map(block => (
      <div data-year={String(block.year)} class="mb-8">
        <h2 class="text-lg font-bold text-primary border-b border-base-200 pb-1 mb-4">{block.year}</h2>

        {block.roadGp && (
          <div data-series="road-gp" class="mb-5">
            <h3 class="text-xs font-bold uppercase tracking-wider text-base-content/50 mb-2">Road GP</h3>
            {block.roadGp.awards.map(award => (
              <a href={`/road-gp/${block.year}/`} class="inline-flex items-center gap-1 text-sm text-success hover:underline mb-2">
                🏆 {award.categoryName} — {positionLabel(award.position)}
              </a>
            ))}
            <table class="table table-sm w-full">
              <tbody>
                {block.roadGp.races.map(race => (
                  <tr data-race-id={race.raceId} data-race-name={race.raceName}>
                    <td class="text-base-content/50 text-xs w-12 tabular-nums">{formatDateShort(race.date)}</td>
                    <td>
                      {race.hasResults
                        ? <a href={`/road-gp/${block.year}/${race.raceId}/results`} class="link link-hover">{race.raceName}</a>
                        : race.raceName}
                    </td>
                    <td class="text-right tabular-nums font-mono text-sm">{race.time || '–'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {block.fell && (
          <div data-series="fell" class="mb-5">
            <h3 class="text-xs font-bold uppercase tracking-wider text-base-content/50 mb-2">Fell</h3>
            {block.fell.awards.map(award => (
              <a href={`/fell/${block.year}/`} class="inline-flex items-center gap-1 text-sm text-success hover:underline mb-2">
                🏆 {award.categoryName} — {positionLabel(award.position)}
              </a>
            ))}
            <table class="table table-sm w-full">
              <tbody>
                {block.fell.races.map(race => (
                  <tr data-race-id={race.raceId} data-race-name={race.raceName}>
                    <td class="text-base-content/50 text-xs w-12 tabular-nums">{formatDateShort(race.date)}</td>
                    <td>
                      {race.hasResults
                        ? <a href={`/fell/${block.year}/${race.raceId}/results`} class="link link-hover">{race.raceName}</a>
                        : race.raceName}
                    </td>
                    <td class="text-right tabular-nums font-mono text-sm">{race.time || '–'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    ))}
  </div>
</Layout>

<script>
  const yearSelect = document.getElementById('filter-year') as HTMLSelectElement;
  const raceSelect = document.getElementById('filter-race') as HTMLSelectElement;
  let activeSeries = 'all';

  function applyFilters() {
    const activeYear = yearSelect.value;
    const activeRace = raceSelect.value;

    // Show/hide series sections
    document.querySelectorAll<HTMLElement>('[data-series]').forEach(div => {
      div.classList.toggle('hidden', activeSeries !== 'all' && div.dataset.series !== activeSeries);
    });

    // Show/hide race rows
    document.querySelectorAll<HTMLElement>('tr[data-race-id]').forEach(row => {
      row.classList.toggle('hidden', activeRace !== '' && row.dataset.raceId !== activeRace);
    });

    // Hide series sections whose race rows are all hidden (only when race filter active)
    if (activeRace !== '') {
      document.querySelectorAll<HTMLElement>('[data-series]:not(.hidden)').forEach(div => {
        const visibleRows = div.querySelectorAll('tr[data-race-id]:not(.hidden)');
        if (visibleRows.length === 0) div.classList.add('hidden');
      });
    }

    // Show/hide year blocks
    document.querySelectorAll<HTMLElement>('[data-year]').forEach(block => {
      const yearMatch = activeYear === '' || block.dataset.year === activeYear;
      const hasVisibleSeries = block.querySelector('[data-series]:not(.hidden)') !== null;
      block.classList.toggle('hidden', !yearMatch || !hasVisibleSeries);
    });
  }

  function updateRaceDropdown() {
    const activeYear = yearSelect.value;
    const seen = new Set<string>();
    const options: Array<{ id: string; name: string }> = [];

    document.querySelectorAll<HTMLElement>('tr[data-race-id]').forEach(row => {
      const yearBlock = row.closest<HTMLElement>('[data-year]');
      const seriesDiv = row.closest<HTMLElement>('[data-series]');
      const yearMatch = activeYear === '' || yearBlock?.dataset.year === activeYear;
      const seriesMatch = activeSeries === 'all' || seriesDiv?.dataset.series === activeSeries;
      if (yearMatch && seriesMatch) {
        const id = row.dataset.raceId!;
        if (!seen.has(id)) {
          seen.add(id);
          options.push({ id, name: row.dataset.raceName! });
        }
      }
    });

    const current = raceSelect.value;
    raceSelect.innerHTML = '<option value="">All Races</option>' +
      options.map(o => `<option value="${o.id}"${o.id === current ? ' selected' : ''}>${o.name}</option>`).join('');
    if (current && !options.find(o => o.id === current)) raceSelect.value = '';
  }

  document.querySelectorAll<HTMLButtonElement>('[data-series-filter]').forEach(btn => {
    btn.addEventListener('click', () => {
      activeSeries = btn.dataset.seriesFilter!;
      document.querySelectorAll('[data-series-filter]').forEach(b => {
        const active = b === btn;
        b.classList.toggle('btn-active', active);
        b.classList.toggle('btn-ghost', !active);
      });
      applyFilters();
      updateRaceDropdown();
    });
  });

  yearSelect.addEventListener('change', () => { applyFilters(); updateRaceDropdown(); });
  raceSelect.addEventListener('change', applyFilters);
</script>
```

- [ ] **Build and verify the profile page generates**

```bash
npm run build
```

Expected: build succeeds; `dist/runners/1-luke-minns/index.html` and `dist/runners/2-rob-danson/index.html` exist.

- [ ] **Commit**

```bash
git add src/pages/runners/
git commit -m "feat: add runner profile page at /runners/[slug]/"
```

---

## Task 7: Link Runner Names in Results Pages

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId]/results.astro`
- Modify: `src/pages/fell/[year]/[raceId]/results.astro`

The results pages re-render the table client-side on filter changes. Both the server-rendered initial state and the client `row()` function must emit links.

- [ ] **Update road-gp results page**

In `src/pages/road-gp/[year]/[raceId]/results.astro`:

1. Add import at top of frontmatter:
```ts
import { buildRunnerUrlMap } from '../../../../lib/runners';
```

2. Add to `getStaticPaths`:
```ts
export async function getStaticPaths() {
  return getResultsStaticPaths('road-gp').map(p => ({
    ...p,
    props: { ...p.props, runnerUrlMap: buildRunnerUrlMap(p.props.year, 'road-gp') },
  }));
}
```

3. Add `runnerUrlMap: Record<number, string>` to the `Props` interface and destructure it:
```ts
interface Props {
  year: number;
  raceId: string;
  results: RaceResult[];
  provisional: boolean;
  clubs: Club[];
  config: SeriesConfig;
  runnerUrlMap: Record<number, string>;
}
const { year, raceId, results, provisional, clubs, config, runnerUrlMap } = Astro.props;
```

4. Replace the server-rendered name cell in the `<tbody>`:
```astro
<td>
  {(() => {
    const url = r.seriesRunnerId ? runnerUrlMap[r.seriesRunnerId] : null;
    const short = `${r.firstName[0] ?? ''}.${r.firstName[0] ? ' ' : ''}${r.lastName}`;
    const full = `${r.firstName} ${r.lastName}`;
    return url
      ? <><span class="sm:hidden"><a href={url} class="link link-hover">{short}</a></span><span class="hidden sm:inline"><a href={url} class="link link-hover">{full}</a></span></>
      : <><span class="sm:hidden">{short}</span><span class="hidden sm:inline">{full}</span></>;
  })()}
</td>
```

5. Add a `runner-url-map` data island after the existing data islands:
```astro
<script type="application/json" id="runner-url-map" set:html={JSON.stringify(runnerUrlMap).replace(/<\/script>/gi, '<\\/script>')}></script>
```

6. In the `<script>` block, add after the existing data island reads:
```ts
const runnerUrlMap: Record<number, string> = JSON.parse(
  document.getElementById('runner-url-map')!.textContent!
);
```

And update the `allResults` type and update the `row()` function to include the link:
```ts
const allResults: Array<{
  position: number | null; icPosition: number | null;
  firstName: string; lastName: string;
  club: string; category: string; sex: string; time: string;
  seriesRunnerId: number | null;
}> = JSON.parse(document.getElementById('results-data')!.textContent!);
```

```ts
function row(r: typeof allResults[0]): string {
  const url = r.seriesRunnerId ? runnerUrlMap[r.seriesRunnerId] : null;
  const shortText = `${r.firstName[0] ? esc(r.firstName[0]) + '. ' : ''}${esc(r.lastName)}`;
  const fullText = `${esc(r.firstName)} ${esc(r.lastName)}`;
  const shortName = url ? `<a href="${url}" class="link link-hover">${shortText}</a>` : shortText;
  const fullName = url ? `<a href="${url}" class="link link-hover">${fullText}</a>` : fullText;
  const clubShort = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.shortName ?? r.club);
  const clubFull = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.name ?? r.club);
  return `<tr>
    <td class="hidden sm:table-cell">${r.position ?? '–'}</td>
    <td>${r.club === 'Guest' ? '–' : (r.icPosition ?? '–')}</td>
    <td>
      <span class="sm:hidden">${shortName}</span>
      <span class="hidden sm:inline">${fullName}</span>
    </td>
    <td>${esc(r.category)}</td>
    <td>
      <span class="sm:hidden">${clubShort}</span>
      <span class="hidden sm:inline">${clubFull}</span>
    </td>
    <td class="text-right tabular-nums">${esc(r.time || '–')}</td>
  </tr>`;
}
```

- [ ] **Apply identical changes to fell results page**

`src/pages/fell/[year]/[raceId]/results.astro` is structurally identical. Apply the same six changes, replacing `'road-gp'` with `'fell'` and fixing the import depth (`'../../../../lib/runners'` is the same depth).

- [ ] **Build and verify**

```bash
npm run build
```

Expected: build succeeds. In the built `dist/road-gp/2026/bwf-5/results/index.html`, Luke Minns and Rob Danson's names should contain `<a href="/runners/1-luke-minns/">` and `<a href="/runners/2-rob-danson/">` respectively.

- [ ] **Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/results.astro src/pages/fell/[year]/[raceId]/results.astro
git commit -m "feat: link runner names in results pages to profiles"
```

---

## Task 8: Link Runner Names in Individual Standings Pages

**Files:**
- Modify: `src/pages/road-gp/[year]/individual-standings.astro`
- Modify: `src/pages/fell/[year]/individual-standings.astro`

Standings pages render names server-side only (filtering is show/hide via CSS, not re-render). A `runnerUrlMap` built at static-path time is sufficient.

- [ ] **Update road-gp individual standings page**

In `src/pages/road-gp/[year]/individual-standings.astro`:

1. Add import:
```ts
import { buildRunnerUrlMap } from '../../../lib/runners';
```

2. Update `getStaticPaths`:
```ts
export async function getStaticPaths() {
  return getIndividualStandingsStaticPaths('road-gp').map(p => ({
    ...p,
    props: { ...p.props, runnerUrlMap: buildRunnerUrlMap(p.props.year, 'road-gp') },
  }));
}
```

3. Add `runnerUrlMap` to `Props` and destructure:
```ts
interface Props {
  year: number;
  standings: IndividualStandings;
  clubs: Club[];
  config: SeriesConfig;
  linkedRaceIds: string[];
  runnerUrlMap: Record<number, string>;
}
const { year, standings, clubs, config, runnerUrlMap } = Astro.props;
```

4. In the desktop table, replace the name cell:
```astro
<td class="py-2.5 pr-4 font-semibold">
  {runner.seriesRunnerId && runnerUrlMap[runner.seriesRunnerId]
    ? <a href={runnerUrlMap[runner.seriesRunnerId]} class="link link-hover">{runner.name}</a>
    : runner.name}
</td>
```

5. In the mobile card, replace the name span in the toggle button:
```astro
<span class="flex-1 font-semibold">
  {runner.seriesRunnerId && runnerUrlMap[runner.seriesRunnerId]
    ? <a href={runnerUrlMap[runner.seriesRunnerId]} class="link link-hover">{runner.name}</a>
    : runner.name}
</span>
```

- [ ] **Apply identical changes to fell individual standings page**

`src/pages/fell/[year]/individual-standings.astro` is structurally identical. Apply the same changes replacing `'road-gp'` with `'fell'`.

- [ ] **Build and verify**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Commit**

```bash
git add src/pages/road-gp/[year]/individual-standings.astro src/pages/fell/[year]/individual-standings.astro
git commit -m "feat: link runner names in individual standings pages to profiles"
```

---

## Task 9: Link Runner Names in Awards

**Files:**
- Modify: `src/pages/road-gp/[year]/index.astro`
- Modify: `src/pages/fell/[year]/index.astro`
- Modify: `src/components/SeriesAwards.astro`

`ResolvedIndividualAwardEntry` already has `runnerUrl?: string` from Task 1. The year index pages build the resolved awards object — they need to add `runnerUrl` when `series_runner_id` is present.

- [ ] **Update road-gp year index page**

In `src/pages/road-gp/[year]/index.astro`:

1. Add import:
```ts
import { buildRunnerUrlMap } from '../../../lib/runners';
```

2. Inside the `if (hasAwards(...))` block, after building `partitioned`, add runner URL lookup. Change the `awards` mapping inside `partitioned`:
```ts
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
        runnerUrl: a.seriesRunnerId ? runnerUrlMap[a.seriesRunnerId] : undefined,
      })),
    },
  };
});
```

- [ ] **Apply identical change to fell year index page**

`src/pages/fell/[year]/index.astro` is structurally identical. Apply the same change replacing `'road-gp'` with `'fell'`.

- [ ] **Update SeriesAwards component to render links**

In `src/components/SeriesAwards.astro`, find every location that renders `a.name` inside individual award entries and wrap it:

```astro
{a.runnerUrl
  ? <a href={a.runnerUrl} class="font-medium link link-hover">{a.name}</a>
  : <span class="font-medium">{a.name}</span>}
```

There are three locations: in `overallAwards`, in `maleAwards`, and in `femaleAwards`. Apply the change to all three.

- [ ] **Build and verify**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Commit**

```bash
git add src/pages/road-gp/[year]/index.astro src/pages/fell/[year]/index.astro src/components/SeriesAwards.astro
git commit -m "feat: link runner names in awards sections to profiles"
```

---

## Task 10: Update CLAUDE.md and Final Build Verify

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Update CLAUDE.md project structure section**

Add `HistoryRaceList.astro` entry is already in CLAUDE.md. Add these to the relevant sections:

Under **Project Structure**, add to pages:
```
    runners/
      [slug].astro       # runner profile page (aggregates all results and awards for one runner)
```

Add to the data section after the existing CSV schema block:

```
### Global runner registry schema

`src/data/runners.json` — one entry per canonical runner identity:
```json
{ "id": 1, "firstName": "Luke", "lastName": "Minns", "club": "blackpool", "sex": "M", "category": "V35" }
```

### Series runner file schema

`src/data/{year}/{series}/runners.json` — links series-local IDs to the global registry:
```json
{ "id": 1, "runnerId": 1, "firstName": "Luke", "lastName": "Minns", "club": "blackpool", "sex": "M", "category": "V35", "number": 42 }
```
- `id` — series-local numeric ID; referenced by `series_runner_id` in results CSVs and awards JSON
- `runnerId` — references the global `runners.json` `id`
- `number` — optional bib number for this series/year

The results CSV `series_runner_id` column (last, optional) references `id` in the series runner file.
The awards JSON `seriesRunnerId` field (optional on individual award entries) references the same.
```

Under **Project Structure** pages, add:
```
    runners/
      [slug].astro       # individual runner profile (generated from src/data/runners.json)
```

- [ ] **Run full build one final time**

```bash
npm run build
```

Expected: build succeeds with no TypeScript errors.

- [ ] **Run tests**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with runner profiles data schema and page structure"
```
