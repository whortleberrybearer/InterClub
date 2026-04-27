# Team Results Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add per-race team results pages to both series, backed by a new JSON data format, with collapsible scorers on mobile and a two-column layout on desktop.

**Architecture:** Team results are stored in `{race-id}-teams[-provisional].json` files alongside individual results CSVs. New loading functions in `results.ts` mirror the existing CSV patterns. Two new Astro pages (one per series) render category tabs and club scorer rows. Existing individual results pages conditionally enable their "View Team Results" button.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4 + DaisyUI v5, Vitest

---

## File Structure

| File | Action |
|------|--------|
| `src/lib/types.ts` | Add `TeamCategory`, `TeamScorer`, `TeamClubResult`, `TeamCategoryResult`, `TeamResults`; extend `SeriesConfig` |
| `src/data/2026/road-gp/config.json` | Add `teamCategories` array |
| `src/data/2026/fell/config.json` | Add `teamCategories` array |
| `src/lib/results.ts` | Add glob maps, `parseTeamResultsPath`, `getTeamResults`, `hasTeamResults`, `getTeamResultsStaticPaths` |
| `tests/lib/results.test.ts` | Add tests for `parseTeamResultsPath` |
| `src/data/2026/road-gp/results/bwf-5-teams-provisional.json` | Create sample data (Open + Ladies) |
| `src/pages/road-gp/[year]/[raceId]/team-results.astro` | Create new page |
| `src/pages/road-gp/[year]/[raceId]/results.astro` | Enable "View Team Results" button |
| `src/pages/fell/[year]/[raceId]/team-results.astro` | Create new page |
| `src/pages/fell/[year]/[raceId]/results.astro` | Enable "View Team Results" button |

---

## Task 1: TypeScript types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add new types and extend SeriesConfig**

Replace the contents of `src/lib/types.ts` with:

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

export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
}

export interface SeriesConfig {
  categories: string[];
  teamCategories?: TeamCategory[];
}

export interface TeamScorer {
  name: string;
  position: number;   // category-specific IC position (e.g. 1st female, not 1st overall)
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
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
npm run build 2>&1 | head -20
```

Expected: no type errors (build may fail on other things — that's fine for now).

- [ ] **Step 3: Commit**

```bash
git add src/lib/types.ts
git commit -m "feat: add team results TypeScript types"
```

---

## Task 2: Add teamCategories to 2026 config files

**Files:**
- Modify: `src/data/2026/road-gp/config.json`
- Modify: `src/data/2026/fell/config.json`

- [ ] **Step 1: Update road-gp config**

Replace `src/data/2026/road-gp/config.json` with:

```json
{
  "categories": ["U17", "U20", "U23", "SEN", "V35", "V40", "V45", "V50", "V55", "V60", "V65", "V70", "V75", "V80"],
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

- [ ] **Step 2: Update fell config**

Replace `src/data/2026/fell/config.json` with:

```json
{
  "categories": ["SEN", "V40", "V50", "V60", "V70"],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6 },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4 }
  ]
}
```

> Note: fell team categories and scorer counts should be confirmed against the actual competition rules and updated before fell results are published.

- [ ] **Step 3: Commit**

```bash
git add src/data/2026/road-gp/config.json src/data/2026/fell/config.json
git commit -m "feat: add teamCategories to 2026 series configs"
```

---

## Task 3: Data loading functions and tests

**Files:**
- Modify: `src/lib/results.ts`
- Modify: `tests/lib/results.test.ts`

- [ ] **Step 1: Write the failing tests**

Add to the bottom of `tests/lib/results.test.ts`:

```typescript
import { parseTeamResultsPath } from '../../src/lib/results';

describe('parseTeamResultsPath', () => {
  it('parses a final road-gp team results path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5-teams.json'))
      .toEqual({ year: 2026, raceId: 'bwf-5', provisional: false });
  });

  it('parses a provisional team results path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5-teams-provisional.json'))
      .toEqual({ year: 2026, raceId: 'bwf-5', provisional: true });
  });

  it('parses a fell path', () => {
    expect(parseTeamResultsPath('../data/2026/fell/results/race-1-teams.json'))
      .toEqual({ year: 2026, raceId: 'race-1', provisional: false });
  });

  it('parses a race id containing hyphens', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/long-race-id-teams.json'))
      .toEqual({ year: 2026, raceId: 'long-race-id', provisional: false });
  });

  it('returns null for a CSV path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5.csv')).toBeNull();
  });

  it('returns null for a non-teams JSON path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/config.json')).toBeNull();
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npm test -- --reporter=verbose 2>&1 | tail -20
```

Expected: tests fail with `parseTeamResultsPath is not exported` or similar.

- [ ] **Step 3: Add team results loading to results.ts**

Add the following to `src/lib/results.ts` — append after the existing glob declarations and before `csvFilesForSeries`:

First, add the import at the top of the file (add `TeamResults` to the existing import):

```typescript
import type { Club, RaceResult, Series, SeriesConfig, TeamResults } from './types';
```

Then add after the existing glob declarations (after line 35, before `function csvFilesForSeries`):

```typescript
const roadTeamFiles = import.meta.glob<{ default: TeamResults }>(
  '../data/*/road-gp/results/*-teams*.json', { eager: true }
);
const fellTeamFiles = import.meta.glob<{ default: TeamResults }>(
  '../data/*/fell/results/*-teams*.json', { eager: true }
);

function teamFilesForSeries(series: Series) {
  return series === 'road-gp' ? roadTeamFiles : fellTeamFiles;
}

export function parseTeamResultsPath(path: string): { year: number; raceId: string; provisional: boolean } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/results\/(.+)-teams(-provisional)?\.json$/);
  if (!match) return null;
  return {
    year: parseInt(match[1], 10),
    raceId: match[2],
    provisional: !!match[3],
  };
}

interface TeamResultsInfo {
  teamResults: TeamResults;
  provisional: boolean;
}

export function getTeamResults(year: number, series: Series, raceId: string): TeamResultsInfo | null {
  const files = teamFilesForSeries(series);
  const finalKey = Object.keys(files).find(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams.json`)
  );
  const provisionalKey = Object.keys(files).find(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams-provisional.json`)
  );
  const key = finalKey ?? provisionalKey;
  if (!key) return null;
  return {
    teamResults: files[key].default,
    provisional: !finalKey && !!provisionalKey,
  };
}

export function hasTeamResults(year: number, series: Series, raceId: string): boolean {
  const files = teamFilesForSeries(series);
  return Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams.json`) ||
    k.includes(`/${year}/${series}/results/${raceId}-teams-provisional.json`)
  );
}

export function getTeamResultsStaticPaths(series: Series) {
  const files = teamFilesForSeries(series);
  const seen = new Map<string, { year: number; raceId: string; provisional: boolean }>();

  for (const path of Object.keys(files)) {
    const parsed = parseTeamResultsPath(path);
    if (!parsed) continue;
    const { year, raceId, provisional } = parsed;
    const key = `${year}/${raceId}`;
    const existing = seen.get(key);
    if (!existing || (!provisional && existing.provisional)) {
      seen.set(key, { year, raceId, provisional });
    }
  }

  return [...seen.values()].map(({ year, raceId, provisional }) => {
    const info = getTeamResults(year, series, raceId)!;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    return {
      params: { year: String(year), raceId },
      props: { year, raceId, teamResults: info.teamResults, provisional, clubs, config },
    };
  });
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
npm test -- --reporter=verbose 2>&1 | tail -20
```

Expected: all `parseTeamResultsPath` tests pass.

- [ ] **Step 5: Commit**

```bash
git add src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat: add team results data loading functions"
```

---

## Task 4: Sample data file

**Files:**
- Create: `src/data/2026/road-gp/results/bwf-5-teams-provisional.json`

- [ ] **Step 1: Create the sample data file**

Create `src/data/2026/road-gp/results/bwf-5-teams-provisional.json`:

```json
{
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1, "points": 7, "club": "wesham", "total": 175,
          "scorers": [
            { "name": "M. Swarbrick", "position": 5 },
            { "name": "J. Townsend",  "position": 8 },
            { "name": "A. Wilding",   "position": 9 },
            { "name": "D. Hounslea",  "position": 16 },
            { "name": "J. Greenaway", "position": 18 },
            { "name": "C. Banks",     "position": 19 },
            { "name": "M. Belfield",  "position": 20 },
            { "name": "D. Taylor",    "position": 22 },
            { "name": "T. Crabtree",  "position": 28 },
            { "name": "J. Rutland",   "position": 30 }
          ]
        },
        {
          "position": 2, "points": 6, "club": "preston", "total": 214,
          "scorers": [
            { "name": "R. Danson",   "position": 2 },
            { "name": "L. Suffolk",  "position": 12 },
            { "name": "A. Cottam",   "position": 13 },
            { "name": "S. Sharples", "position": 15 },
            { "name": "R. Mullen",   "position": 21 },
            { "name": "H. Jacobsen", "position": 24 },
            { "name": "N. Sutton",   "position": 29 },
            { "name": "P. Ratan",    "position": 31 },
            { "name": "D. Carter",   "position": 33 },
            { "name": "S. Hallas",   "position": 34 }
          ]
        },
        {
          "position": 3, "points": 5, "club": "blackpool", "total": 214,
          "scorers": [
            { "name": "L. Minns",        "position": 1 },
            { "name": "J. Cowan",        "position": 3 },
            { "name": "A. Bellfield",    "position": 10 },
            { "name": "N. Cox",          "position": 11 },
            { "name": "E. Simm",         "position": 14 },
            { "name": "M. Osinski-Gray", "position": 17 },
            { "name": "P. Leybourne",    "position": 27 },
            { "name": "D. Lavelle",      "position": 39 },
            { "name": "O. Clegg",        "position": 42 },
            { "name": "M. Warner",       "position": 50 }
          ]
        },
        {
          "position": 4, "points": 4, "club": "red-rose", "total": 530,
          "scorers": [
            { "name": "S. Croft",     "position": 7 },
            { "name": "J. Parker",    "position": 25 },
            { "name": "M. Holmes",    "position": 26 },
            { "name": "A. Christie",  "position": 36 },
            { "name": "M. Ramsden",   "position": 43 },
            { "name": "L. Hooton",    "position": 61 },
            { "name": "M. Oddie",     "position": 68 },
            { "name": "K. Lesse",     "position": 71 },
            { "name": "L. Webb",      "position": 95 },
            { "name": "A. Doublett",  "position": 98 }
          ]
        },
        {
          "position": 5, "points": 3, "club": "lytham", "total": 612,
          "scorers": [
            { "name": "M. Toft",          "position": 4 },
            { "name": "J. Rodwell",       "position": 6 },
            { "name": "J. Whittle",       "position": 23 },
            { "name": "D. Read-Garrett",  "position": 52 },
            { "name": "J. Atkin",         "position": 74 },
            { "name": "N. Alcock",        "position": 83 },
            { "name": "C. Taylor",        "position": 87 },
            { "name": "S. Pepper",        "position": 90 },
            { "name": "M. Edwards",       "position": 96 },
            { "name": "C. Coley-Maud",    "position": 97 }
          ]
        },
        {
          "position": 6, "points": 2, "club": "chorley", "total": 1107,
          "scorers": [
            { "name": "T. Holmes",      "position": 60 },
            { "name": "D. Grindley",    "position": 75 },
            { "name": "M. Preston",     "position": 80 },
            { "name": "J. Hardman",     "position": 88 },
            { "name": "S. Gouldthorpe", "position": 91 },
            { "name": "A. Grindley",    "position": 103 },
            { "name": "P. Wareing",     "position": 119 },
            { "name": "M. Quinn",       "position": 155 },
            { "name": "D. Ashcroft",    "position": 156 },
            { "name": "P. Bass",        "position": 180 }
          ]
        },
        {
          "position": 7, "points": 1, "club": "thornton", "total": 1214,
          "scorers": [
            { "name": "B. McWilliams", "position": 37 },
            { "name": "A. Bailey",     "position": 40 },
            { "name": "S. Hall",       "position": 49 },
            { "name": "B. Cumpsty",    "position": 112 },
            { "name": "R. Jones",      "position": 129 },
            { "name": "D. Brown",      "position": 150 },
            { "name": "R. Sysum",      "position": 162 },
            { "name": "M. Harper",     "position": 175 },
            { "name": "C. Caunce",     "position": 176 },
            { "name": "J. Almond",     "position": 184 }
          ]
        }
      ]
    },
    {
      "category": "ladies",
      "clubs": [
        {
          "position": 1, "points": 7, "club": "preston", "total": 28,
          "scorers": [
            { "name": "H. Jacobsen", "position": 2 },
            { "name": "N. Sutton",   "position": 3 },
            { "name": "J. Robinson", "position": 4 },
            { "name": "K. Hurt",     "position": 5 },
            { "name": "E. Horne",    "position": 14 }
          ]
        },
        {
          "position": 2, "points": 6, "club": "lytham", "total": 69,
          "scorers": [
            { "name": "C. Coley-Maud", "position": 8 },
            { "name": "L. Nield",      "position": 10 },
            { "name": "C. Carrdus",    "position": 13 },
            { "name": "C. Chisholm",   "position": 18 },
            { "name": "G. Draper",     "position": 20 }
          ]
        },
        {
          "position": 3, "points": 5, "club": "wesham", "total": 74,
          "scorers": [
            { "name": "B. Houghton-Spark", "position": 6 },
            { "name": "E. Wilson",         "position": 9 },
            { "name": "C. Helme",          "position": 12 },
            { "name": "E. Lund",           "position": 22 },
            { "name": "C. Sullivan",       "position": 25 }
          ]
        },
        {
          "position": 4, "points": 4, "club": "red-rose", "total": 118,
          "scorers": [
            { "name": "S. Parkinson", "position": 16 },
            { "name": "M. Scott",     "position": 17 },
            { "name": "S. Edwards",   "position": 19 },
            { "name": "J. Rayton",    "position": 26 },
            { "name": "K. Dewhirst",  "position": 40 }
          ]
        },
        {
          "position": 5, "points": 3, "club": "blackpool", "total": 126,
          "scorers": [
            { "name": "E. Simm",      "position": 1 },
            { "name": "K. Gurley",    "position": 23 },
            { "name": "B. Pawelczak", "position": 24 },
            { "name": "J. Bradburn",  "position": 32 },
            { "name": "H. Hall",      "position": 46 }
          ]
        },
        {
          "position": 6, "points": 2, "club": "thornton", "total": 256,
          "scorers": [
            { "name": "A. Bowden",     "position": 35 },
            { "name": "D. Jackson",    "position": 49 },
            { "name": "R. McAllister", "position": 53 },
            { "name": "N. Harper",     "position": 55 },
            { "name": "H. Birtwistle", "position": 64 }
          ]
        },
        {
          "position": 7, "points": 1, "club": "chorley", "total": 508,
          "scorers": [
            { "name": "M. Preston",  "position": 7 },
            { "name": "A. Grindley", "position": 11 },
            { "name": "S. Bates",    "position": 68 },
            { "name": "K. Townsend", "position": 110 },
            { "name": "",            "position": 312 }
          ]
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Run the build to confirm it picks up the new file**

```bash
npm run build 2>&1 | tail -10
```

Expected: build succeeds. If it fails, check the error — most likely a type mismatch in the JSON.

- [ ] **Step 3: Commit**

```bash
git add src/data/2026/road-gp/results/bwf-5-teams-provisional.json
git commit -m "feat: add provisional team results data for BWF race 5"
```

---

## Task 5: Road-GP team results page and navigation

**Files:**
- Create: `src/pages/road-gp/[year]/[raceId]/team-results.astro`
- Modify: `src/pages/road-gp/[year]/[raceId]/results.astro`

- [ ] **Step 1: Create the team results page**

Create `src/pages/road-gp/[year]/[raceId]/team-results.astro`:

```astro
---
// src/pages/road-gp/[year]/[raceId]/team-results.astro
import Layout from '../../../../components/Layout.astro';
import { getRace } from '../../../../lib/data';
import { getTeamResultsStaticPaths } from '../../../../lib/results';
import type { Club, SeriesConfig, TeamResults } from '../../../../lib/types';

export async function getStaticPaths() {
  return getTeamResultsStaticPaths('road-gp');
}

interface Props {
  year: number;
  raceId: string;
  teamResults: TeamResults;
  provisional: boolean;
  clubs: Club[];
  config: SeriesConfig;
}

const { year, raceId, teamResults, provisional, clubs, config } = Astro.props;
const race = getRace(year, 'road-gp', raceId);
const title = race?.name ?? raceId;
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
const categoryById = Object.fromEntries((config.teamCategories ?? []).map(c => [c.id, c]));
---

<Layout title={`${title} — Team Results`}>
  <div class="mb-4">
    <a href={`/road-gp/${year}/${raceId}/results`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Individual Results</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">{title} Team Results</h1>
      {provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    {race && <p class="text-sm text-base-content/60 mt-1">{year}</p>}
  </div>

  <!-- Category tabs -->
  <div class="overflow-x-auto -mx-4 px-4 mb-1">
    <div class="flex border-b border-base-200 min-w-max" role="tablist">
      {teamResults.categories.map((cat, i) => {
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
  {teamResults.categories.map((cat, i) => {
    const catConfig = categoryById[cat.category];
    return (
      <div id={`cat-panel-${i}`} class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">
        {catConfig && (
          <p class="text-xs text-base-content/40 mb-3">
            {catConfig.scorerCount} scorers · lower score wins
          </p>
        )}
        {cat.clubs.map(clubResult => {
          const club = clubById[clubResult.club];
          const clubName = club?.name ?? clubResult.club;
          return (
            <div class="border-b border-base-200 py-3 sm:grid sm:grid-cols-2 sm:gap-x-8 sm:items-start last:border-0">
              <!-- Club info: position | name | points -->
              <div class="flex items-baseline gap-2">
                <span class="w-5 shrink-0 text-sm text-base-content/40 tabular-nums">
                  {clubResult.position}
                </span>
                <span class="font-semibold">{clubName}</span>
                <span class="ml-auto text-sm">
                  <strong class="text-base-content/70">{clubResult.points}</strong>
                  <span class="text-base-content/40"> {clubResult.points === 1 ? 'pt' : 'pts'}</span>
                </span>
              </div>
              <!-- Scorers: collapsible on mobile, always open on desktop -->
              <details class="scorer-details mt-1 sm:mt-0">
                <summary class="sm:hidden list-none cursor-pointer select-none text-xs text-base-content/40 py-1">
                  Show scorers
                </summary>
                <ul class="mt-1">
                  {clubResult.scorers.map(scorer => (
                    <li class="flex justify-between py-0.5 text-sm">
                      <span class="text-base-content/70">{scorer.name || '–'}</span>
                      <span class="tabular-nums text-base-content/50">{scorer.position}</span>
                    </li>
                  ))}
                  <li class="flex justify-between pt-1.5 mt-1 border-t border-base-200 text-sm font-semibold">
                    <span>Total</span>
                    <span class="tabular-nums">{clubResult.total}</span>
                  </li>
                </ul>
              </details>
            </div>
          );
        })}
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

  // Expand all scorer details on desktop
  if (window.matchMedia('(min-width: 640px)').matches) {
    document.querySelectorAll<HTMLDetailsElement>('.scorer-details').forEach(d => {
      d.open = true;
    });
  }
</script>
```

- [ ] **Step 2: Enable the "View Team Results" button in road-gp results page**

In `src/pages/road-gp/[year]/[raceId]/results.astro`, add `hasTeamResults` to the import:

```typescript
import { getResultsStaticPaths, hasTeamResults } from '../../../../lib/results';
```

Then add to the frontmatter (after `const clubById = ...`):

```typescript
const showTeamResults = hasTeamResults(year, 'road-gp', raceId);
```

Replace the footer links section (around line 100–104):

```astro
  <!-- Footer links -->
  <div class="mt-6 flex gap-3 flex-wrap">
    {showTeamResults
      ? <a href="team-results" class="btn btn-outline btn-sm">View Team Results</a>
      : <button class="btn btn-outline btn-sm" disabled>View Team Results</button>
    }
  </div>
```

- [ ] **Step 3: Build and verify the page generates**

```bash
npm run build 2>&1 | tail -20
```

Expected: build succeeds and output includes `road-gp/2026/bwf-5/team-results/index.html`.

```bash
ls dist/road-gp/2026/bwf-5/
```

Expected: directory contains both `results/` and `team-results/`.

- [ ] **Step 4: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/team-results.astro src/pages/road-gp/[year]/[raceId]/results.astro
git commit -m "feat: add road-gp team results page and enable navigation button"
```

---

## Task 6: Fell team results page and navigation

**Files:**
- Create: `src/pages/fell/[year]/[raceId]/team-results.astro`
- Modify: `src/pages/fell/[year]/[raceId]/results.astro`

- [ ] **Step 1: Create the fell team results page**

Create `src/pages/fell/[year]/[raceId]/team-results.astro` — identical to the road-gp page except for three differences: the series string, the back link, and the import comment.

```astro
---
// src/pages/fell/[year]/[raceId]/team-results.astro
import Layout from '../../../../components/Layout.astro';
import { getRace } from '../../../../lib/data';
import { getTeamResultsStaticPaths } from '../../../../lib/results';
import type { Club, SeriesConfig, TeamResults } from '../../../../lib/types';

export async function getStaticPaths() {
  return getTeamResultsStaticPaths('fell');
}

interface Props {
  year: number;
  raceId: string;
  teamResults: TeamResults;
  provisional: boolean;
  clubs: Club[];
  config: SeriesConfig;
}

const { year, raceId, teamResults, provisional, clubs, config } = Astro.props;
const race = getRace(year, 'fell', raceId);
const title = race?.name ?? raceId;
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
const categoryById = Object.fromEntries((config.teamCategories ?? []).map(c => [c.id, c]));
---

<Layout title={`${title} — Team Results`}>
  <div class="mb-4">
    <a href={`/fell/${year}/${raceId}/results`} class="btn btn-ghost btn-sm gap-1 -ml-3">← Individual Results</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">{title} Team Results</h1>
      {provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    {race && <p class="text-sm text-base-content/60 mt-1">{year}</p>}
  </div>

  <!-- Category tabs -->
  <div class="overflow-x-auto -mx-4 px-4 mb-1">
    <div class="flex border-b border-base-200 min-w-max" role="tablist">
      {teamResults.categories.map((cat, i) => {
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
  {teamResults.categories.map((cat, i) => {
    const catConfig = categoryById[cat.category];
    return (
      <div id={`cat-panel-${i}`} class:list={['pt-3', i > 0 && 'hidden']} role="tabpanel">
        {catConfig && (
          <p class="text-xs text-base-content/40 mb-3">
            {catConfig.scorerCount} scorers · lower score wins
          </p>
        )}
        {cat.clubs.map(clubResult => {
          const club = clubById[clubResult.club];
          const clubName = club?.name ?? clubResult.club;
          return (
            <div class="border-b border-base-200 py-3 sm:grid sm:grid-cols-2 sm:gap-x-8 sm:items-start last:border-0">
              <div class="flex items-baseline gap-2">
                <span class="w-5 shrink-0 text-sm text-base-content/40 tabular-nums">
                  {clubResult.position}
                </span>
                <span class="font-semibold">{clubName}</span>
                <span class="ml-auto text-sm">
                  <strong class="text-base-content/70">{clubResult.points}</strong>
                  <span class="text-base-content/40"> {clubResult.points === 1 ? 'pt' : 'pts'}</span>
                </span>
              </div>
              <details class="scorer-details mt-1 sm:mt-0">
                <summary class="sm:hidden list-none cursor-pointer select-none text-xs text-base-content/40 py-1">
                  Show scorers
                </summary>
                <ul class="mt-1">
                  {clubResult.scorers.map(scorer => (
                    <li class="flex justify-between py-0.5 text-sm">
                      <span class="text-base-content/70">{scorer.name || '–'}</span>
                      <span class="tabular-nums text-base-content/50">{scorer.position}</span>
                    </li>
                  ))}
                  <li class="flex justify-between pt-1.5 mt-1 border-t border-base-200 text-sm font-semibold">
                    <span>Total</span>
                    <span class="tabular-nums">{clubResult.total}</span>
                  </li>
                </ul>
              </details>
            </div>
          );
        })}
      </div>
    );
  })}
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

  if (window.matchMedia('(min-width: 640px)').matches) {
    document.querySelectorAll<HTMLDetailsElement>('.scorer-details').forEach(d => {
      d.open = true;
    });
  }
</script>
```

- [ ] **Step 2: Enable the "View Team Results" button in fell results page**

In `src/pages/fell/[year]/[raceId]/results.astro`, add `hasTeamResults` to the import:

```typescript
import { getResultsStaticPaths, hasTeamResults } from '../../../../lib/results';
```

Add to the frontmatter (after `const clubById = ...`):

```typescript
const showTeamResults = hasTeamResults(year, 'fell', raceId);
```

Replace the footer links section:

```astro
  <!-- Footer links -->
  <div class="mt-6 flex gap-3 flex-wrap">
    {showTeamResults
      ? <a href="team-results" class="btn btn-outline btn-sm">View Team Results</a>
      : <button class="btn btn-outline btn-sm" disabled>View Team Results</button>
    }
  </div>
```

- [ ] **Step 3: Run full test suite and build**

```bash
npm test
```

Expected: all tests pass.

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 4: Commit**

```bash
git add src/pages/fell/[year]/[raceId]/team-results.astro src/pages/fell/[year]/[raceId]/results.astro
git commit -m "feat: add fell team results page and enable navigation button"
```
