# Series Awards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Series Winners" section above the race list on series year index pages, driven by a manually-authored `awards.json` file per year/series.

**Architecture:** New `awards.json` data files are loaded via `import.meta.glob` in `results.ts`. Index pages resolve category and club display names from config/clubs data, then pass a fully-resolved `ResolvedSeriesAwards` object to `RaceList`, which delegates rendering to a new `SeriesAwards.astro` component. The component renders team winners as compact pills and individual winners in an Overall (full-width) + Male/Female two-column grid.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4, DaisyUI v5. Build validation via `npm run build`. No new unit tests — all new functions depend on `import.meta.glob` and are validated by the build per the project's established pattern.

---

### Task 1: Add types to `src/lib/types.ts`

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add `sex` to `IndividualCategory` and add all new interfaces**

Replace the existing `IndividualCategory` interface and append the new types at the end of `src/lib/types.ts`:

```typescript
// Replace lines 37-40 (IndividualCategory interface):
export interface IndividualCategory {
  id: string;
  name: string;
  sex?: 'M' | 'F';
}
```

Append to the end of `src/lib/types.ts`:

```typescript
// Raw awards data (from awards.json)
export interface TeamAward {
  category: string;  // references teamCategories[].id in config.json
  club: string;      // references clubs.json id
}

export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;      // references clubs.json id
}

export interface IndividualAward {
  category: string;  // references individualCategories[].id in config.json
  awards: IndividualAwardEntry[];
}

export interface SeriesAwards {
  teamAwards: TeamAward[];
  individualAwards: IndividualAward[];
}

// Resolved awards data (display names looked up, categories partitioned by sex)
export interface ResolvedTeamAward {
  categoryName: string;
  clubName: string;
}

export interface ResolvedIndividualAwardEntry {
  position: number;
  name: string;
  clubName: string;
}

export interface ResolvedIndividualAward {
  categoryName: string;
  awards: ResolvedIndividualAwardEntry[];
}

export interface ResolvedSeriesAwards {
  teamAwards: ResolvedTeamAward[];
  overallAwards: ResolvedIndividualAward[];  // sex field absent on config category
  maleAwards: ResolvedIndividualAward[];     // sex === 'M' on config category
  femaleAwards: ResolvedIndividualAward[];   // sex === 'F' on config category
}
```

- [ ] **Step 2: Verify build still compiles**

```bash
npm run build
```

Expected: build succeeds with no TypeScript errors.

- [ ] **Step 3: Commit**

```bash
git add src/lib/types.ts
git commit -m "feat: add SeriesAwards and ResolvedSeriesAwards types"
```

---

### Task 2: Add data loading to `src/lib/results.ts`

**Files:**
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Add glob declarations after the existing `fellIndividualStandingsFiles` glob block (around line 68)**

Add these lines immediately after the `fellIndividualStandingsFiles` block:

```typescript
const roadAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/road-gp/awards.json', { eager: true }
);
const fellAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/fell/awards.json', { eager: true }
);

function awardsFilesForSeries(series: Series) {
  return series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
}
```

- [ ] **Step 2: Update the import at the top of `results.ts` to include `SeriesAwards`**

The current import line is:
```typescript
import type { Club, IndividualStandings, RaceResult, Series, SeriesConfig, TeamResults, TeamStandings } from './types';
```

Replace it with:
```typescript
import type { Club, IndividualStandings, RaceResult, Series, SeriesAwards, SeriesConfig, TeamResults, TeamStandings } from './types';
```

- [ ] **Step 3: Add `hasAwards` and `getAwards` export functions**

Add these two functions at the end of `results.ts`, after `getIndividualStandingsStaticPaths`:

```typescript
export function hasAwards(year: number, series: Series): boolean {
  const files = awardsFilesForSeries(series);
  return `../data/${year}/${series}/awards.json` in files;
}

export function getAwards(year: number, series: Series): SeriesAwards | null {
  const files = awardsFilesForSeries(series);
  return files[`../data/${year}/${series}/awards.json`]?.default ?? null;
}
```

- [ ] **Step 4: Verify build still compiles**

```bash
npm run build
```

Expected: build succeeds with no TypeScript errors.

- [ ] **Step 5: Commit**

```bash
git add src/lib/results.ts
git commit -m "feat: add hasAwards and getAwards data loaders"
```

---

### Task 3: Create `src/components/SeriesAwards.astro`

**Files:**
- Create: `src/components/SeriesAwards.astro`

- [ ] **Step 1: Create the component**

Create `src/components/SeriesAwards.astro` with the following content:

```astro
---
import type { ResolvedSeriesAwards } from '../lib/types';

interface Props {
  awards: ResolvedSeriesAwards;
}

const { awards } = Astro.props;

function positionLabel(pos: number): string {
  if (pos === 1) return '🥇';
  if (pos === 2) return '🥈';
  if (pos === 3) return '🥉';
  const mod10 = pos % 10;
  const mod100 = pos % 100;
  const suffix =
    mod10 === 1 && mod100 !== 11 ? 'st' :
    mod10 === 2 && mod100 !== 12 ? 'nd' :
    mod10 === 3 && mod100 !== 13 ? 'rd' : 'th';
  return `${pos}${suffix}`;
}

const hasMF = awards.maleAwards.length > 0 || awards.femaleAwards.length > 0;
---

<div class="card bg-base-200 mb-6">
  <div class="card-body p-4 gap-4">
    <h2 class="card-title text-base">🏆 Series Winners</h2>

    {awards.teamAwards.length > 0 && (
      <div>
        <p class="text-xs uppercase tracking-wider text-base-content/50 mb-2">Team</p>
        <div class="flex flex-wrap gap-2">
          {awards.teamAwards.map(ta => (
            <span class="badge badge-lg gap-1 font-normal">
              🏆 <span class="text-base-content/60">{ta.categoryName}:</span>
              <span class="font-semibold">{ta.clubName}</span>
            </span>
          ))}
        </div>
      </div>
    )}

    {(awards.overallAwards.length > 0 || hasMF) && (
      <div>
        <p class="text-xs uppercase tracking-wider text-base-content/50 mb-2">Individual</p>

        {awards.overallAwards.length > 0 && (
          <div class="flex flex-col gap-2 mb-3">
            {awards.overallAwards.map(cat => (
              <div class="bg-base-100 rounded-lg p-3">
                <p class="text-xs text-base-content/50 mb-1">{cat.categoryName}</p>
                <div class="flex flex-col gap-1">
                  {cat.awards.map(a => (
                    <div class="flex items-baseline gap-2 text-sm">
                      <span class="w-6 shrink-0">{positionLabel(a.position)}</span>
                      <span class="font-medium">{a.name}</span>
                      <span class="text-base-content/50 text-xs">{a.clubName}</span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}

        {hasMF && (
          <div class="grid grid-cols-2 gap-2">
            <div class="flex flex-col gap-2">
              {awards.maleAwards.map(cat => (
                <div class="bg-base-100 rounded-lg p-3">
                  <p class="text-xs text-base-content/50 mb-1">{cat.categoryName}</p>
                  <div class="flex flex-col gap-1">
                    {cat.awards.map(a => (
                      <div class="flex items-baseline gap-2 text-sm">
                        <span class="w-6 shrink-0">{positionLabel(a.position)}</span>
                        <span class="font-medium">{a.name}</span>
                        <span class="text-base-content/50 text-xs">{a.clubName}</span>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            <div class="flex flex-col gap-2">
              {awards.femaleAwards.map(cat => (
                <div class="bg-base-100 rounded-lg p-3">
                  <p class="text-xs text-base-content/50 mb-1">{cat.categoryName}</p>
                  <div class="flex flex-col gap-1">
                    {cat.awards.map(a => (
                      <div class="flex items-baseline gap-2 text-sm">
                        <span class="w-6 shrink-0">{positionLabel(a.position)}</span>
                        <span class="font-medium">{a.name}</span>
                        <span class="text-base-content/50 text-xs">{a.clubName}</span>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    )}
  </div>
</div>
```

- [ ] **Step 2: Verify build still compiles**

```bash
npm run build
```

Expected: build succeeds. (Component is not yet used, so no visible change.)

- [ ] **Step 3: Commit**

```bash
git add src/components/SeriesAwards.astro
git commit -m "feat: add SeriesAwards component"
```

---

### Task 4: Wire awards into `RaceList` and both index pages

**Files:**
- Modify: `src/components/RaceList.astro`
- Modify: `src/pages/fell/[year]/index.astro`
- Modify: `src/pages/road-gp/[year]/index.astro`

- [ ] **Step 1: Update `src/components/RaceList.astro`**

Replace the full file with:

```astro
---
// src/components/RaceList.astro
import type { Race, ResolvedSeriesAwards, Series } from '../lib/types';
import RaceCard from './RaceCard.astro';
import SeriesAwards from './SeriesAwards.astro';
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
  awards?: ResolvedSeriesAwards;
}

const { races, year, series, availableYears, currentYear, seriesBasePath, seriesLabel, standingsUrl, individualStandingsUrl, awards } = Astro.props;
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

  {awards && <SeriesAwards awards={awards} />}

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

- [ ] **Step 2: Update `src/pages/fell/[year]/index.astro`**

Replace the full file with:

```astro
---
// src/pages/fell/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings } from '../../../lib/results';
import type { ResolvedSeriesAwards } from '../../../lib/types';

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

let awards: ResolvedSeriesAwards | undefined;
if (hasAwards(year, 'fell')) {
  const raw = getAwards(year, 'fell')!;
  const config = getSeriesConfig(year, 'fell');
  const clubs = getClubs(year);

  const resolveClub = (id: string) => clubs.find(c => c.id === id)?.name ?? id;
  const resolveTeamCategoryName = (id: string) =>
    config.teamCategories?.find(c => c.id === id)?.name ?? id;
  const resolveIndividualCategory = (id: string) =>
    config.individualCategories?.find(c => c.id === id);

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

- [ ] **Step 3: Update `src/pages/road-gp/[year]/index.astro`**

Replace the full file with:

```astro
---
// src/pages/road-gp/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings } from '../../../lib/results';
import type { ResolvedSeriesAwards } from '../../../lib/types';

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

let awards: ResolvedSeriesAwards | undefined;
if (hasAwards(year, 'road-gp')) {
  const raw = getAwards(year, 'road-gp')!;
  const config = getSeriesConfig(year, 'road-gp');
  const clubs = getClubs(year);

  const resolveClub = (id: string) => clubs.find(c => c.id === id)?.name ?? id;
  const resolveTeamCategoryName = (id: string) =>
    config.teamCategories?.find(c => c.id === id)?.name ?? id;
  const resolveIndividualCategory = (id: string) =>
    config.individualCategories?.find(c => c.id === id);

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

- [ ] **Step 4: Verify build compiles**

```bash
npm run build
```

Expected: build succeeds. No awards section visible yet (no `awards.json` file exists).

- [ ] **Step 5: Commit**

```bash
git add src/components/RaceList.astro src/pages/fell/[year]/index.astro src/pages/road-gp/[year]/index.astro
git commit -m "feat: wire awards section into series index pages"
```

---

### Task 5: Add sample data and validate end-to-end

**Files:**
- Modify: `src/data/2026/fell/config.json`
- Create: `src/data/2026/fell/awards.json`

- [ ] **Step 1: Add `sex` fields to `individualCategories` in `src/data/2026/fell/config.json`**

Replace the file with:

```json
{
  "ageCategories": ["SEN", "V40", "V50", "V60", "V70"],
  "maxCountingRaces": 3,
  "individualCategories": [
    { "id": "sen-m", "name": "Senior Men",   "sex": "M" },
    { "id": "sen-f", "name": "Senior Women", "sex": "F" },
    { "id": "v40-m", "name": "V40 Men",      "sex": "M" },
    { "id": "v40-f", "name": "V40 Women",    "sex": "F" }
  ],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6 },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4 }
  ]
}
```

- [ ] **Step 2: Create `src/data/2026/fell/awards.json`**

```json
{
  "teamAwards": [
    { "category": "open",   "club": "wesham" },
    { "category": "ladies", "club": "lytham" },
    { "category": "vets",   "club": "preston" }
  ],
  "individualAwards": [
    {
      "category": "sen-m",
      "awards": [
        { "position": 1, "name": "L. Minns",  "club": "blackpool" },
        { "position": 2, "name": "J. Smith",  "club": "wesham" },
        { "position": 3, "name": "T. Guest",  "club": "red-rose" }
      ]
    },
    {
      "category": "sen-f",
      "awards": [
        { "position": 1, "name": "A. Jones",  "club": "chorley" },
        { "position": 3, "name": "B. Clarke", "club": "blackpool" }
      ]
    },
    {
      "category": "v40-m",
      "awards": [
        { "position": 1, "name": "D. Evans",  "club": "wesham" },
        { "position": 2, "name": "M. Clark",  "club": "thornton" }
      ]
    },
    {
      "category": "v40-f",
      "awards": [
        { "position": 1, "name": "C. Hall",   "club": "wesham" },
        { "position": 2, "name": "E. Fox",    "club": "red-rose" },
        { "position": 3, "name": "F. Ward",   "club": "preston" }
      ]
    }
  ]
}
```

- [ ] **Step 3: Run build and confirm awards section appears**

```bash
npm run build && npm run preview
```

Navigate to `http://localhost:4321/fell/2026/` and verify:
- "🏆 Series Winners" section appears above the race list
- Team pills show: "🏆 Open: Wesham RR", "🏆 Ladies: Lytham St. Annes RR", "🏆 Vets: Preston Harriers"
- Individual section shows two columns (Senior Men / Senior Women, V40 Men / V40 Women)
- Senior Women shows positions 1st and 3rd (position 2 absent — no row rendered)
- Club names are fully resolved (e.g. "Wesham RR", not "wesham")

- [ ] **Step 4: Confirm other pages are unaffected**

Navigate to `/road-gp/2026/` and verify no awards section appears (no `awards.json` for road-gp 2026).

- [ ] **Step 5: Commit**

```bash
git add src/data/2026/fell/config.json src/data/2026/fell/awards.json
git commit -m "feat: add sample 2026 fell awards and sex fields to config"
```
