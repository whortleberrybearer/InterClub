# Individual Standings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add individual standings pages (fell + road-gp) showing per-runner race scores, with non-counting results visually marked, category tabs, and mobile-friendly filtering.

**Architecture:** Pre-computed `individual-standings.json` files are loaded at build time via `import.meta.glob` and rendered into static pages — identical pattern to existing `team-standings.json`. Pages are only generated when the JSON file is present. Filtering (by sex and age category) is client-side JS operating on data attributes already rendered into the HTML.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4, DaisyUI v5, Vitest

---

## File Map

| Action | File | Change |
|--------|------|--------|
| Modify | `src/lib/types.ts` | Rename `categories→ageCategories` in `SeriesConfig`; add 5 new interfaces |
| Modify | `src/data/2026/fell/config.json` | Rename key `categories → ageCategories` |
| Modify | `src/data/2026/road-gp/config.json` | Rename key `categories → ageCategories` |
| Modify | `src/lib/results.ts` | Fix fallback, add glob imports, add 4 new exports |
| Modify | `tests/lib/results.test.ts` | Add `parseIndividualStandingsPath` test suite |
| Modify | `src/pages/fell/[year]/[raceId]/results.astro` | `config.categories` → `config.ageCategories` |
| Modify | `src/pages/road-gp/[year]/[raceId]/results.astro` | `config.categories` → `config.ageCategories` |
| Modify | `src/components/RaceList.astro` | Add `individualStandingsUrl?` prop |
| Modify | `src/pages/fell/[year]/index.astro` | Pass `individualStandingsUrl` to `RaceList` |
| Modify | `src/pages/road-gp/[year]/index.astro` | Pass `individualStandingsUrl` to `RaceList` |
| Create | `src/pages/fell/[year]/individual-standings.astro` | New page |
| Create | `src/pages/road-gp/[year]/individual-standings.astro` | New page |

---

## Task 1: Update `types.ts`

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Replace the full contents of `src/lib/types.ts`**

```typescript
export type Series = 'road-gp' | 'fell';

export interface SiteConfig {
  currentYear: number;
}

export interface Race {
  id: string;
  name: string;
  date: string;       // ISO date string: "2026-06-07"
  time?: string;      // "HH:MM", e.g. "10:30"
  location?: string;
  distance?: string;
  detailsUrl?: string;
  image?: string;     // filename relative to /public/images/
  shortName?: string;
}

export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;        // club id (e.g. 'blackpool') or 'Guest'
  category: string;   // e.g. 'SEN', 'V35', 'U17'
  sex: string;        // 'M' or 'F'
  time: string;       // 'MM:SS', may be empty
}

export interface Club {
  id: string;
  name: string;
  shortName: string;
  logo: string;        // filename in /public/images/clubs/, may not exist yet
}

export interface IndividualCategory {
  id: string;
  name: string;
}

export interface SeriesConfig {
  ageCategories: string[];           // renamed from categories
  maxCountingRaces?: number;         // optional; when set, the page shows "Best N races count"
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
}

export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
}

export interface TeamScorer {
  name: string;
  position: number;   // rank within the sex/age group used for team scoring
}

export interface TeamClubResult {
  position: number;   // finishing position in this team category
  points: number;     // season points earned (stored explicitly)
  club: string;       // id → Club lookup via clubs.json
  total: number;      // sum of scorer positions
  scorers: TeamScorer[];
}

export interface TeamCategoryResult {
  category: string;   // id → TeamCategory lookup via config.teamCategories
  clubs: TeamClubResult[];
}

export interface TeamResults {
  categories: TeamCategoryResult[];
}

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

export interface IndividualRaceResult {
  points: number;
  counting: boolean;
}

export interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex: string;          // 'M' or 'F'
  ageCategory: string;  // e.g. 'SEN', 'V40'
  total: number;
  results: Record<string, IndividualRaceResult>;  // keyed by race id; only races the runner entered
}

export interface IndividualStandingsCategory {
  category: string;   // id → IndividualCategory lookup via config.individualCategories
  runners: IndividualStandingsRunner[];
}

export interface IndividualStandings {
  provisional: boolean;
  races: string[];    // ordered list of race ids; defines column order
  categories: IndividualStandingsCategory[];
}
```

- [ ] **Step 2: Run tests to confirm nothing broken yet**

```bash
npm test
```

Expected: all tests pass (no code has changed that tests exercise yet).

- [ ] **Step 3: Commit**

```bash
git add src/lib/types.ts
git commit -m "refactor: rename SeriesConfig.categories to ageCategories; add individual standings types"
```

---

## Task 2: Update config JSON files

**Files:**
- Modify: `src/data/2026/fell/config.json`
- Modify: `src/data/2026/road-gp/config.json`

- [ ] **Step 1: Update `src/data/2026/fell/config.json`**

```json
{
  "ageCategories": ["SEN", "V40", "V50", "V60", "V70"],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6 },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4 }
  ]
}
```

- [ ] **Step 2: Update `src/data/2026/road-gp/config.json`**

```json
{
  "ageCategories": ["U17", "U20", "U23", "SEN", "V35", "V40", "V45", "V50", "V55", "V60", "V65", "V70", "V75", "V80"],
  "teamCategories": [
    { "id": "open",   "name": "Open",    "scorerCount": 10 },
    { "id": "ladies", "name": "Ladies",  "scorerCount": 5  },
    { "id": "fv40",   "name": "FV40",    "scorerCount": 5  },
    { "id": "vets",   "name": "Vets",    "scorerCount": 6  },
    { "id": "vet50s", "name": "Vet 50s", "scorerCount": 4  },
    { "id": "vet60s", "name": "Vet 60s", "scorerCount": 3  }
  ]
}
```

- [ ] **Step 3: Commit**

```bash
git add src/data/2026/fell/config.json src/data/2026/road-gp/config.json
git commit -m "chore: rename categories key to ageCategories in series configs"
```

---

## Task 3: Fix `results.ts` — fallback + individual standings helpers

**Files:**
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Update the import line at the top of `src/lib/results.ts`**

Replace:
```typescript
import type { Club, RaceResult, Series, SeriesConfig, TeamResults, TeamStandings } from './types';
```
With:
```typescript
import type { Club, IndividualStandings, RaceResult, Series, SeriesConfig, TeamResults, TeamStandings } from './types';
```

- [ ] **Step 2: Add individual standings glob imports**

After line 57 (after the `fellStandingsFiles` declaration), add:

```typescript
const roadIndividualStandingsFiles = import.meta.glob<{ default: IndividualStandings }>(
  '../data/*/road-gp/individual-standings.json', { eager: true }
);
const fellIndividualStandingsFiles = import.meta.glob<{ default: IndividualStandings }>(
  '../data/*/fell/individual-standings.json', { eager: true }
);

function individualStandingsFilesForSeries(series: Series) {
  return series === 'road-gp' ? roadIndividualStandingsFiles : fellIndividualStandingsFiles;
}
```

- [ ] **Step 3: Fix the `getSeriesConfig` fallback on the last line of the file**

Replace:
```typescript
  return files[`../data/${year}/${series}/config.json`]?.default ?? { categories: [] };
```
With:
```typescript
  return files[`../data/${year}/${series}/config.json`]?.default ?? { ageCategories: [] };
```

- [ ] **Step 4: Add the four new exports at the end of `src/lib/results.ts`**

```typescript
export function parseIndividualStandingsPath(path: string): { year: number } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/individual-standings\.json$/);
  if (!match) return null;
  return { year: parseInt(match[1], 10) };
}

export function hasIndividualStandings(year: number, series: Series): boolean {
  const files = individualStandingsFilesForSeries(series);
  return `../data/${year}/${series}/individual-standings.json` in files;
}

export function getIndividualStandingsStaticPaths(series: Series) {
  const files = individualStandingsFilesForSeries(series);
  return Object.keys(files).flatMap(path => {
    const parsed = parseIndividualStandingsPath(path);
    if (!parsed) return [];
    const { year } = parsed;
    const standings = files[path].default;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    const linkedRaceIds = standings.races.filter(raceId =>
      hasResults(year, series, raceId)
    );
    return [{
      params: { year: String(year) },
      props: { year, standings, clubs, config, linkedRaceIds },
    }];
  });
}
```

- [ ] **Step 5: Run tests**

```bash
npm test
```

Expected: all existing tests pass (the fallback change and new functions don't break anything).

- [ ] **Step 6: Commit**

```bash
git add src/lib/results.ts
git commit -m "feat: add individual standings helpers to results.ts"
```

---

## Task 4: Add tests for `parseIndividualStandingsPath`

**Files:**
- Modify: `tests/lib/results.test.ts`

- [ ] **Step 1: Add the test suite**

Append to the end of `tests/lib/results.test.ts`:

```typescript
describe('parseIndividualStandingsPath', () => {
  it('parses a road-gp individual standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/road-gp/individual-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('parses a fell individual standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/individual-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('returns null for a team-standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/team-standings.json'))
      .toBeNull();
  });

  it('returns null for a config path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/config.json'))
      .toBeNull();
  });

  it('returns null for an individual results path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/results/race-1.csv'))
      .toBeNull();
  });
});
```

Also update the import line at the top of `tests/lib/results.test.ts`:

Replace:
```typescript
import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath } from '../../src/lib/results';
```
With:
```typescript
import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath, parseIndividualStandingsPath } from '../../src/lib/results';
```

- [ ] **Step 2: Run tests to verify they fail before the function existed (they should pass now since Task 3 already added the function)**

```bash
npm test
```

Expected: all tests pass, including the 5 new `parseIndividualStandingsPath` cases.

- [ ] **Step 3: Commit**

```bash
git add tests/lib/results.test.ts
git commit -m "test: add parseIndividualStandingsPath tests"
```

---

## Task 5: Fix `config.categories` references in results pages

**Files:**
- Modify: `src/pages/fell/[year]/[raceId]/results.astro` (line 57)
- Modify: `src/pages/road-gp/[year]/[raceId]/results.astro` (line 57)

- [ ] **Step 1: Update `src/pages/fell/[year]/[raceId]/results.astro`**

Replace (line 57):
```astro
      {config.categories.map(cat => <option value={cat}>{cat}</option>)}
```
With:
```astro
      {(config.ageCategories ?? []).map(cat => <option value={cat}>{cat}</option>)}
```

- [ ] **Step 2: Update `src/pages/road-gp/[year]/[raceId]/results.astro`**

Replace (line 57):
```astro
      {config.categories.map(cat => <option value={cat}>{cat}</option>)}
```
With:
```astro
      {(config.ageCategories ?? []).map(cat => <option value={cat}>{cat}</option>)}
```

- [ ] **Step 3: Run build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build completes with no errors.

- [ ] **Step 4: Commit**

```bash
git add src/pages/fell/[year]/[raceId]/results.astro src/pages/road-gp/[year]/[raceId]/results.astro
git commit -m "fix: update results pages to use config.ageCategories"
```

---

## Task 6: Update `RaceList` component and year index pages

**Files:**
- Modify: `src/components/RaceList.astro`
- Modify: `src/pages/fell/[year]/index.astro`
- Modify: `src/pages/road-gp/[year]/index.astro`

- [ ] **Step 1: Replace the full contents of `src/components/RaceList.astro`**

```astro
---
// src/components/RaceList.astro
import type { Race, Series } from '../lib/types';
import RaceCard from './RaceCard.astro';
import YearFilter from './YearFilter.astro';

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
}

const { races, year, series, availableYears, currentYear, seriesBasePath, seriesLabel, standingsUrl, individualStandingsUrl } = Astro.props;
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
        <a href={standingsUrl} class="btn btn-sm btn-outline gap-1">
          Team Standings →
        </a>
      )}
      {individualStandingsUrl && (
        <a href={individualStandingsUrl} class="btn btn-sm btn-outline gap-1">
          Individual Standings →
        </a>
      )}
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

- [ ] **Step 2: Replace the full contents of `src/pages/fell/[year]/index.astro`**

```astro
---
// src/pages/fell/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { hasTeamStandings, hasIndividualStandings } from '../../../lib/results';

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
const individualStandingsUrl = hasIndividualStandings(year, 'fell')
  ? `/fell/${year}/individual-standings`
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
    individualStandingsUrl={individualStandingsUrl}
  />
</Layout>
```

- [ ] **Step 3: Replace the full contents of `src/pages/road-gp/[year]/index.astro`**

```astro
---
// src/pages/road-gp/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { hasTeamStandings, hasIndividualStandings } from '../../../lib/results';

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
const individualStandingsUrl = hasIndividualStandings(year, 'road-gp')
  ? `/road-gp/${year}/individual-standings`
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
    individualStandingsUrl={individualStandingsUrl}
  />
</Layout>
```

- [ ] **Step 4: Run build**

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 5: Commit**

```bash
git add src/components/RaceList.astro src/pages/fell/[year]/index.astro src/pages/road-gp/[year]/index.astro
git commit -m "feat: add individual standings link to series year index pages"
```

---

## Task 7: Create `fell` individual standings page

**Files:**
- Create: `src/pages/fell/[year]/individual-standings.astro`

- [ ] **Step 1: Create the file with the full contents below**

```astro
---
// src/pages/fell/[year]/individual-standings.astro
import Layout from '../../../components/Layout.astro';
import { getRaces } from '../../../lib/data';
import { getIndividualStandingsStaticPaths } from '../../../lib/results';
import type { Club, SeriesConfig, IndividualStandings } from '../../../lib/types';

export async function getStaticPaths() {
  return getIndividualStandingsStaticPaths('fell');
}

interface Props {
  year: number;
  standings: IndividualStandings;
  clubs: Club[];
  config: SeriesConfig;
  linkedRaceIds: string[];
}

const { year, standings, clubs, config } = Astro.props;
const linkedRaceIds = new Set(Astro.props.linkedRaceIds);
const races = getRaces(year, 'fell');
const raceById = Object.fromEntries(races.map(r => [r.id, r]));
const categoryById = Object.fromEntries((config.individualCategories ?? []).map(c => [c.id, c]));
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
---

<Layout title={`Fell Championship ${year} — Individual Standings`}>
  <div class="mb-4">
    <a href={`/fell/${year}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Fell Championship {year}</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">Individual Standings</h1>
      {standings.provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    <p class="text-sm text-base-content/60 mt-1">{year} Inter Club Fell Championship</p>
    {config.maxCountingRaces && (
      <p class="text-sm text-base-content/60 mt-0.5">Best {config.maxCountingRaces} races count</p>
    )}
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
  {standings.categories.map((cat, i) => {
    const distinctAgeCats = [...new Set(cat.runners.map(r => r.ageCategory))].sort();
    return (
      <div id={`cat-panel-${i}`} data-panel class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">

        <!-- Filter controls -->
        <div class="flex flex-wrap gap-2 mb-3 items-center">
          <div class="flex gap-1">
            <button class="filter-sex btn btn-xs btn-active" data-value="">All</button>
            <button class="filter-sex btn btn-xs btn-ghost" data-value="M">M</button>
            <button class="filter-sex btn btn-xs btn-ghost" data-value="F">F</button>
          </div>
          {distinctAgeCats.length > 1 && (
            <div class="flex gap-1 flex-wrap">
              {distinctAgeCats.map(age => (
                <button class="filter-age btn btn-xs btn-ghost" data-value={age}>{age}</button>
              ))}
            </div>
          )}
        </div>

        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto">
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr class="border-b border-base-200">
                <th class="text-left py-2 pr-3 text-base-content/40 font-medium w-8">#</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Name</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Club</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Cat</th>
                {standings.races.map(raceId => {
                  const race = raceById[raceId];
                  const label = race?.shortName ?? raceId;
                  const href = linkedRaceIds.has(raceId) ? `/fell/${year}/${raceId}/results` : null;
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
              {cat.runners.map(runner => {
                const clubName = clubById[runner.club]?.name ?? runner.club;
                const catLabel = `${runner.sex}${runner.ageCategory}`;
                return (
                  <tr
                    class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30"
                    data-sex={runner.sex}
                    data-age-cat={runner.ageCategory}
                  >
                    <td class="py-2.5 pr-3 text-base-content/40 tabular-nums">{runner.position}</td>
                    <td class="py-2.5 pr-4 font-semibold">{runner.name}</td>
                    <td class="py-2.5 pr-4">{clubName}</td>
                    <td class="py-2.5 pr-4 text-base-content/60 text-xs tabular-nums">{catLabel}</td>
                    {standings.races.map(raceId => {
                      const result = runner.results[raceId];
                      if (!result) return <td class="py-2.5 px-2" />;
                      return (
                        <td class:list={[
                          'py-2.5 px-2 text-right tabular-nums',
                          !result.counting && 'text-base-content/30',
                        ]}>
                          <span class:list={[!result.counting && 'line-through']}>
                            {result.points}
                          </span>
                        </td>
                      );
                    })}
                    <td class="py-2.5 pl-4 text-right">
                      <strong class="text-base-content/80">{runner.total}</strong>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <!-- Mobile view -->
        <div class="sm:hidden">
          <!-- Race key -->
          <div class="flex flex-wrap gap-x-3 gap-y-1 py-3 border-b border-base-200 mb-1 text-xs text-base-content/40">
            {standings.races.map(raceId => {
              const race = raceById[raceId];
              const label = race?.shortName ?? raceId;
              const href = linkedRaceIds.has(raceId) ? `/fell/${year}/${raceId}/results` : null;
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

          {cat.runners.map(runner => {
            const clubName = clubById[runner.club]?.name ?? runner.club;
            const catLabel = `${runner.sex}${runner.ageCategory}`;
            const detailId = `detail-${i}-${runner.position}`;
            return (
              <div
                class="runner-card border-b border-base-200 last:border-0"
                data-sex={runner.sex}
                data-age-cat={runner.ageCategory}
              >
                <button
                  class="standings-toggle w-full flex items-center gap-2 py-2.5 text-left"
                  data-target={detailId}
                  aria-expanded="false"
                >
                  <span class="w-6 shrink-0 text-sm text-base-content/40 tabular-nums">{runner.position}</span>
                  <span class="flex-1 font-semibold">{runner.name}</span>
                  <strong class="text-base-content/80">{runner.total}</strong>
                  <span class="chevron text-base-content/30 text-xs ml-1 transition-transform">▾</span>
                </button>
                <div id={detailId} class="hidden pb-3 pl-8">
                  <p class="text-sm text-base-content/60 mb-1.5">
                    {clubName} · <span class="font-mono text-xs">{catLabel}</span>
                  </p>
                  <div class="flex flex-wrap gap-1.5">
                    {Object.entries(runner.results).map(([raceId, result]) => {
                      const race = raceById[raceId];
                      const label = race?.shortName ?? raceId;
                      const href = linkedRaceIds.has(raceId) ? `/fell/${year}/${raceId}/results` : null;
                      return (
                        <div class:list={[
                          'rounded px-2.5 py-1 text-center text-sm min-w-[44px]',
                          result.counting ? 'bg-base-200' : 'bg-base-200/40',
                        ]}>
                          {href
                            ? <a href={href} class:list={['block text-[10px] mb-0.5', result.counting ? 'text-primary' : 'text-base-content/30']}>{label}</a>
                            : <span class:list={['block text-[10px] mb-0.5', result.counting ? 'text-base-content/40' : 'text-base-content/20']}>{label}</span>
                          }
                          <span class:list={[
                            result.counting ? 'font-semibold' : 'text-base-content/30 line-through',
                          ]}>{result.points}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    );
  })}
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

  // Mobile accordion
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

  // Filtering
  function filterPanel(panel: HTMLElement) {
    const activeSex = panel.querySelector<HTMLElement>('.filter-sex.btn-active')?.dataset.value ?? '';
    const activeAges = [...panel.querySelectorAll<HTMLElement>('.filter-age.btn-active')]
      .map(b => b.dataset.value ?? '');

    panel.querySelectorAll<HTMLElement>('tr[data-sex]').forEach(row => {
      const sexMatch = !activeSex || row.dataset.sex === activeSex;
      const ageMatch = activeAges.length === 0 || activeAges.includes(row.dataset.ageCat ?? '');
      row.style.display = sexMatch && ageMatch ? '' : 'none';
    });

    panel.querySelectorAll<HTMLElement>('.runner-card').forEach(card => {
      const sexMatch = !activeSex || card.dataset.sex === activeSex;
      const ageMatch = activeAges.length === 0 || activeAges.includes(card.dataset.ageCat ?? '');
      card.style.display = sexMatch && ageMatch ? '' : 'none';
    });
  }

  document.querySelectorAll<HTMLButtonElement>('.filter-sex').forEach(btn => {
    btn.addEventListener('click', () => {
      const panel = btn.closest<HTMLElement>('[data-panel]')!;
      panel.querySelectorAll<HTMLElement>('.filter-sex').forEach(b => {
        const active = b === btn;
        b.classList.toggle('btn-active', active);
        b.classList.toggle('btn-ghost', !active);
      });
      filterPanel(panel);
    });
  });

  document.querySelectorAll<HTMLButtonElement>('.filter-age').forEach(btn => {
    btn.addEventListener('click', () => {
      const panel = btn.closest<HTMLElement>('[data-panel]')!;
      btn.classList.toggle('btn-active');
      btn.classList.toggle('btn-ghost');
      filterPanel(panel);
    });
  });
</script>
```

- [ ] **Step 2: Run build**

```bash
npm run build
```

Expected: build succeeds (the page generates no static paths since no `individual-standings.json` files exist yet, which is correct).

- [ ] **Step 3: Commit**

```bash
git add src/pages/fell/[year]/individual-standings.astro
git commit -m "feat: add fell individual standings page"
```

---

## Task 8: Create `road-gp` individual standings page

**Files:**
- Create: `src/pages/road-gp/[year]/individual-standings.astro`

- [ ] **Step 1: Create the file**

This is identical to the fell page except for the series label, back-link path, and series string passed to `getIndividualStandingsStaticPaths`. Create `src/pages/road-gp/[year]/individual-standings.astro` with the contents below:

```astro
---
// src/pages/road-gp/[year]/individual-standings.astro
import Layout from '../../../components/Layout.astro';
import { getRaces } from '../../../lib/data';
import { getIndividualStandingsStaticPaths } from '../../../lib/results';
import type { Club, SeriesConfig, IndividualStandings } from '../../../lib/types';

export async function getStaticPaths() {
  return getIndividualStandingsStaticPaths('road-gp');
}

interface Props {
  year: number;
  standings: IndividualStandings;
  clubs: Club[];
  config: SeriesConfig;
  linkedRaceIds: string[];
}

const { year, standings, clubs, config } = Astro.props;
const linkedRaceIds = new Set(Astro.props.linkedRaceIds);
const races = getRaces(year, 'road-gp');
const raceById = Object.fromEntries(races.map(r => [r.id, r]));
const categoryById = Object.fromEntries((config.individualCategories ?? []).map(c => [c.id, c]));
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
---

<Layout title={`Road Grand Prix ${year} — Individual Standings`}>
  <div class="mb-4">
    <a href={`/road-gp/${year}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Road Grand Prix {year}</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">Individual Standings</h1>
      {standings.provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    <p class="text-sm text-base-content/60 mt-1">{year} Inter Club Road Grand Prix</p>
    {config.maxCountingRaces && (
      <p class="text-sm text-base-content/60 mt-0.5">Best {config.maxCountingRaces} races count</p>
    )}
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
  {standings.categories.map((cat, i) => {
    const distinctAgeCats = [...new Set(cat.runners.map(r => r.ageCategory))].sort();
    return (
      <div id={`cat-panel-${i}`} data-panel class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">

        <!-- Filter controls -->
        <div class="flex flex-wrap gap-2 mb-3 items-center">
          <div class="flex gap-1">
            <button class="filter-sex btn btn-xs btn-active" data-value="">All</button>
            <button class="filter-sex btn btn-xs btn-ghost" data-value="M">M</button>
            <button class="filter-sex btn btn-xs btn-ghost" data-value="F">F</button>
          </div>
          {distinctAgeCats.length > 1 && (
            <div class="flex gap-1 flex-wrap">
              {distinctAgeCats.map(age => (
                <button class="filter-age btn btn-xs btn-ghost" data-value={age}>{age}</button>
              ))}
            </div>
          )}
        </div>

        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto">
          <table class="w-full border-collapse text-sm">
            <thead>
              <tr class="border-b border-base-200">
                <th class="text-left py-2 pr-3 text-base-content/40 font-medium w-8">#</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Name</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Club</th>
                <th class="text-left py-2 pr-4 text-base-content/40 font-medium">Cat</th>
                {standings.races.map(raceId => {
                  const race = raceById[raceId];
                  const label = race?.shortName ?? raceId;
                  const href = linkedRaceIds.has(raceId) ? `/road-gp/${year}/${raceId}/results` : null;
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
              {cat.runners.map(runner => {
                const clubName = clubById[runner.club]?.name ?? runner.club;
                const catLabel = `${runner.sex}${runner.ageCategory}`;
                return (
                  <tr
                    class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30"
                    data-sex={runner.sex}
                    data-age-cat={runner.ageCategory}
                  >
                    <td class="py-2.5 pr-3 text-base-content/40 tabular-nums">{runner.position}</td>
                    <td class="py-2.5 pr-4 font-semibold">{runner.name}</td>
                    <td class="py-2.5 pr-4">{clubName}</td>
                    <td class="py-2.5 pr-4 text-base-content/60 text-xs tabular-nums">{catLabel}</td>
                    {standings.races.map(raceId => {
                      const result = runner.results[raceId];
                      if (!result) return <td class="py-2.5 px-2" />;
                      return (
                        <td class:list={[
                          'py-2.5 px-2 text-right tabular-nums',
                          !result.counting && 'text-base-content/30',
                        ]}>
                          <span class:list={[!result.counting && 'line-through']}>
                            {result.points}
                          </span>
                        </td>
                      );
                    })}
                    <td class="py-2.5 pl-4 text-right">
                      <strong class="text-base-content/80">{runner.total}</strong>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <!-- Mobile view -->
        <div class="sm:hidden">
          <!-- Race key -->
          <div class="flex flex-wrap gap-x-3 gap-y-1 py-3 border-b border-base-200 mb-1 text-xs text-base-content/40">
            {standings.races.map(raceId => {
              const race = raceById[raceId];
              const label = race?.shortName ?? raceId;
              const href = linkedRaceIds.has(raceId) ? `/road-gp/${year}/${raceId}/results` : null;
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

          {cat.runners.map(runner => {
            const clubName = clubById[runner.club]?.name ?? runner.club;
            const catLabel = `${runner.sex}${runner.ageCategory}`;
            const detailId = `detail-${i}-${runner.position}`;
            return (
              <div
                class="runner-card border-b border-base-200 last:border-0"
                data-sex={runner.sex}
                data-age-cat={runner.ageCategory}
              >
                <button
                  class="standings-toggle w-full flex items-center gap-2 py-2.5 text-left"
                  data-target={detailId}
                  aria-expanded="false"
                >
                  <span class="w-6 shrink-0 text-sm text-base-content/40 tabular-nums">{runner.position}</span>
                  <span class="flex-1 font-semibold">{runner.name}</span>
                  <strong class="text-base-content/80">{runner.total}</strong>
                  <span class="chevron text-base-content/30 text-xs ml-1 transition-transform">▾</span>
                </button>
                <div id={detailId} class="hidden pb-3 pl-8">
                  <p class="text-sm text-base-content/60 mb-1.5">
                    {clubName} · <span class="font-mono text-xs">{catLabel}</span>
                  </p>
                  <div class="flex flex-wrap gap-1.5">
                    {Object.entries(runner.results).map(([raceId, result]) => {
                      const race = raceById[raceId];
                      const label = race?.shortName ?? raceId;
                      const href = linkedRaceIds.has(raceId) ? `/road-gp/${year}/${raceId}/results` : null;
                      return (
                        <div class:list={[
                          'rounded px-2.5 py-1 text-center text-sm min-w-[44px]',
                          result.counting ? 'bg-base-200' : 'bg-base-200/40',
                        ]}>
                          {href
                            ? <a href={href} class:list={['block text-[10px] mb-0.5', result.counting ? 'text-primary' : 'text-base-content/30']}>{label}</a>
                            : <span class:list={['block text-[10px] mb-0.5', result.counting ? 'text-base-content/40' : 'text-base-content/20']}>{label}</span>
                          }
                          <span class:list={[
                            result.counting ? 'font-semibold' : 'text-base-content/30 line-through',
                          ]}>{result.points}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    );
  })}
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

  // Mobile accordion
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

  // Filtering
  function filterPanel(panel: HTMLElement) {
    const activeSex = panel.querySelector<HTMLElement>('.filter-sex.btn-active')?.dataset.value ?? '';
    const activeAges = [...panel.querySelectorAll<HTMLElement>('.filter-age.btn-active')]
      .map(b => b.dataset.value ?? '');

    panel.querySelectorAll<HTMLElement>('tr[data-sex]').forEach(row => {
      const sexMatch = !activeSex || row.dataset.sex === activeSex;
      const ageMatch = activeAges.length === 0 || activeAges.includes(row.dataset.ageCat ?? '');
      row.style.display = sexMatch && ageMatch ? '' : 'none';
    });

    panel.querySelectorAll<HTMLElement>('.runner-card').forEach(card => {
      const sexMatch = !activeSex || card.dataset.sex === activeSex;
      const ageMatch = activeAges.length === 0 || activeAges.includes(card.dataset.ageCat ?? '');
      card.style.display = sexMatch && ageMatch ? '' : 'none';
    });
  }

  document.querySelectorAll<HTMLButtonElement>('.filter-sex').forEach(btn => {
    btn.addEventListener('click', () => {
      const panel = btn.closest<HTMLElement>('[data-panel]')!;
      panel.querySelectorAll<HTMLElement>('.filter-sex').forEach(b => {
        const active = b === btn;
        b.classList.toggle('btn-active', active);
        b.classList.toggle('btn-ghost', !active);
      });
      filterPanel(panel);
    });
  });

  document.querySelectorAll<HTMLButtonElement>('.filter-age').forEach(btn => {
    btn.addEventListener('click', () => {
      const panel = btn.closest<HTMLElement>('[data-panel]')!;
      btn.classList.toggle('btn-active');
      btn.classList.toggle('btn-ghost');
      filterPanel(panel);
    });
  });
</script>
```

- [ ] **Step 2: Run tests and build**

```bash
npm test && npm run build
```

Expected: all tests pass; build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/[year]/individual-standings.astro
git commit -m "feat: add road-gp individual standings page"
```

---

## Task 9: Smoke test with sample data

**Files:**
- Create: `src/data/2026/fell/individual-standings.json` (temporary, for smoke testing)
- Modify: `src/data/2026/fell/config.json` (add `individualCategories` and `maxCountingRaces`)

- [ ] **Step 1: Add `individualCategories` and `maxCountingRaces` to `src/data/2026/fell/config.json`**

```json
{
  "ageCategories": ["SEN", "V40", "V50", "V60", "V70"],
  "maxCountingRaces": 3,
  "individualCategories": [
    { "id": "sen-m", "name": "Senior Men"   },
    { "id": "sen-f", "name": "Senior Women" },
    { "id": "v40-m", "name": "V40 Men"      },
    { "id": "v40-f", "name": "V40 Women"    }
  ],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6 },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4 }
  ]
}
```

- [ ] **Step 2: Create `src/data/2026/fell/individual-standings.json`**

```json
{
  "provisional": true,
  "races": ["fell-race-1", "fell-race-2", "fell-race-3", "fell-race-4"],
  "categories": [
    {
      "category": "sen-m",
      "runners": [
        {
          "position": 1,
          "name": "Luke Minns",
          "club": "blackpool",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 47,
          "results": {
            "fell-race-1": { "points": 25, "counting": true },
            "fell-race-3": { "points": 22, "counting": true }
          }
        },
        {
          "position": 2,
          "name": "J. Smith",
          "club": "wesham",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 38,
          "results": {
            "fell-race-1": { "points": 20, "counting": true },
            "fell-race-2": { "points": 18, "counting": true },
            "fell-race-3": { "points": 15, "counting": false }
          }
        }
      ]
    },
    {
      "category": "sen-f",
      "runners": [
        {
          "position": 1,
          "name": "A. Jones",
          "club": "chorley",
          "sex": "F",
          "ageCategory": "SEN",
          "total": 30,
          "results": {
            "fell-race-2": { "points": 30, "counting": true }
          }
        }
      ]
    }
  ]
}
```

- [ ] **Step 3: Build and preview**

```bash
npm run build && npm run preview
```

Expected: build succeeds; navigate to `http://localhost:4321/fell/2026/individual-standings` (adjust port if different) and verify:
- Provisional badge is shown
- "Best 3 races count" note appears
- Two category tabs: "Senior Men" and "Senior Women"
- Senior Men tab shows two runners; J. Smith's fell-race-3 score (15) is dimmed with strikethrough
- Senior Women tab shows one runner with one chip
- M/F filter buttons work
- On narrow viewport (< 640px width), accordion rows appear instead of the table

- [ ] **Step 4: Commit the smoke-test data (it can be removed later when real data is added)**

```bash
git add src/data/2026/fell/config.json src/data/2026/fell/individual-standings.json
git commit -m "chore: add sample individual standings data for 2026 fell (smoke test)"
```

---

## Spec Coverage Check

| Spec requirement | Covered by |
|---|---|
| `categories` renamed to `ageCategories` in config | Tasks 1, 2, 3, 5 |
| `maxCountingRaces` in config | Task 1 (types), Task 9 (data) |
| `individualCategories` in config | Task 1 (types), Task 9 (data) |
| `individual-standings.json` schema | Tasks 1 (types), 3 (loading), 9 (sample) |
| Page only generated when file exists | Task 3 (`getIndividualStandingsStaticPaths`) |
| Provisional badge | Tasks 7, 8 |
| Category tabs | Tasks 7, 8 |
| Desktop table with race columns | Tasks 7, 8 |
| Non-counting results dimmed + strikethrough | Tasks 7, 8 |
| Empty cell for races not run | Tasks 7, 8 |
| Category column = `sex + ageCategory` (e.g. `MSEN`) | Tasks 7, 8 |
| Sex filter (M/F/All) | Tasks 7, 8 |
| Age category filter (multiselect) | Tasks 7, 8 |
| Mobile accordion | Tasks 7, 8 |
| Mobile race chips (counting vs non-counting) | Tasks 7, 8 |
| Navigation link from year index | Tasks 6 |
| `linkedRaceIds` links race columns to results pages | Tasks 7, 8 |
| Tests for `parseIndividualStandingsPath` | Task 4 |
