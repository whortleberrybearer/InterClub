# Category Metadata in Standings and Awards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move individual category metadata (`sex`, `ageCategory`, `name`) out of `config.individualCategories` and into `individual-standings.json` and `awards.json`, eliminating the verbose per-year category list from config and making both data files self-describing.

**Architecture:** TypeScript types are updated first, deliberately breaking all usage sites so the compiler acts as a change checklist. A new pure function `resolveIndividualCategoryName` handles name derivation. Astro pages and `runners.ts` are then fixed to use the new source of truth. Data file cleanup (config JSON, stray award entry fields) follows.

**Tech Stack:** TypeScript, Astro v6, Vitest

---

## File Map

| File | Change |
|------|--------|
| `src/lib/types.ts` | Remove `IndividualCategory`, remove `individualCategories`/`maxCountingRaces` from `SeriesConfig`, add optional fields to `IndividualStandings`, `IndividualStandingsCategory`, `IndividualStandingsRunner`, `IndividualAward`, `IndividualAwardEntry` |
| `src/lib/results.ts` | Add `resolveIndividualCategoryName` pure function |
| `tests/lib/results.test.ts` | Add tests for `resolveIndividualCategoryName` |
| `src/pages/fell/[year]/individual-standings.astro` | Read `maxCountingRaces` from standings; derive category names; inherit sex/ageCategory from category |
| `src/pages/road-gp/[year]/individual-standings.astro` | Same changes as fell page |
| `src/pages/fell/[year]/index.astro` | Resolve award category name/sex from award object fields |
| `src/pages/road-gp/[year]/index.astro` | Same changes as fell page |
| `src/lib/runners.ts` | Resolve award category name from award object fields |
| `src/data/2025/road-gp/awards.json` | Rename stray `"id"` fields on award entries to `"ageCategory"` |
| `src/data/*/*/config.json` (multiple) | Remove `individualCategories` and `maxCountingRaces` keys |

---

### Task 1: Update TypeScript types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Apply all type changes**

Replace the affected interfaces in `src/lib/types.ts`. The full updated block covering all changed types:

```typescript
// Remove IndividualCategory interface entirely (was lines 115-119)

export interface SeriesConfig {
  ageCategories?: string[];          // renamed from categories; now optional
  teamCategories?: TeamCategory[];
  note?: string;                     // optional; used for suspended seasons
}

// IndividualStandings gains maxCountingRaces
export interface IndividualStandings {
  provisional: boolean;
  maxCountingRaces?: number;  // moved from SeriesConfig; page shows "Best N races count"
  races: string[];
  categories: IndividualStandingsCategory[];
}

// IndividualStandingsCategory gains sex, ageCategory, name
export interface IndividualStandingsCategory {
  id: string;
  sex?: 'M' | 'F';       // when set, runners in this category inherit it
  ageCategory?: string;   // when set, runners in this category inherit it
  name?: string;          // explicit display name override (e.g. "Overall", "Men")
  runners: IndividualStandingsRunner[];
}

// IndividualStandingsRunner — sex and ageCategory become optional
export interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex?: string;
  ageCategory?: string;
  total: number;
  results: Record<string, IndividualRaceResult>;
  seriesRunnerId?: number;
}

// IndividualAward gains sex, ageCategory, name
export interface IndividualAward {
  id: string;
  sex?: 'M' | 'F';       // drives overall/male/female column split in SeriesAwards
  ageCategory?: string;
  name?: string;
  awards: IndividualAwardEntry[];
}

// IndividualAwardEntry gains ageCategory (formalising stray "id" fields in 2025 road-gp awards)
export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;
  ageCategory?: string;
  seriesRunnerId?: number;
}

// ResolvedSeriesAwards — update comments (no functional change)
export interface ResolvedSeriesAwards {
  teamAwards: ResolvedTeamAward[];
  overallAwards: ResolvedIndividualAward[];  // sex absent on award
  maleAwards: ResolvedIndividualAward[];     // sex === 'M' on award
  femaleAwards: ResolvedIndividualAward[];   // sex === 'F' on award
}
```

- [ ] **Step 2: Verify the build now reports TypeScript errors**

Run: `npm run build 2>&1 | head -60`

Expected: TypeScript errors referencing `individualCategories`, `maxCountingRaces`, and `IndividualCategory`. These are the change checklist — do NOT fix them yet.

---

### Task 2: Add `resolveIndividualCategoryName` with tests

**Files:**
- Modify: `tests/lib/results.test.ts`
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Write the failing tests**

Add this `describe` block at the bottom of `tests/lib/results.test.ts`:

```typescript
import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath, parseIndividualStandingsPath, pivotIndividualAwardsByCategory, resolveIndividualCategoryName } from '../../src/lib/results';

// ... existing tests ...

describe('resolveIndividualCategoryName', () => {
  it('returns name override when provided', () => {
    expect(resolveIndividualCategoryName('overall', undefined, undefined, 'Overall')).toBe('Overall');
  });

  it('returns name override regardless of sex/ageCategory', () => {
    expect(resolveIndividualCategoryName('x', 'M', 'V40', 'Custom')).toBe('Custom');
  });

  it('derives Senior Men from SEN + M', () => {
    expect(resolveIndividualCategoryName('sen-male', 'M', 'SEN')).toBe('Senior Men');
  });

  it('derives Junior Women from JUN + F', () => {
    expect(resolveIndividualCategoryName('jun-female', 'F', 'JUN')).toBe('Junior Women');
  });

  it('derives V40 Men from V40 + M', () => {
    expect(resolveIndividualCategoryName('v40-male', 'M', 'V40')).toBe('V40 Men');
  });

  it('derives V55 Women from V55 + F', () => {
    expect(resolveIndividualCategoryName('v55-female', 'F', 'V55')).toBe('V55 Women');
  });

  it('derives Men from sex M with no ageCategory', () => {
    expect(resolveIndividualCategoryName('male', 'M')).toBe('Men');
  });

  it('derives Women from sex F with no ageCategory', () => {
    expect(resolveIndividualCategoryName('female', 'F')).toBe('Women');
  });

  it('falls back to raw id when no sex, ageCategory, or name', () => {
    expect(resolveIndividualCategoryName('something-custom')).toBe('something-custom');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npm test -- --reporter=verbose 2>&1 | grep -A3 "resolveIndividualCategoryName"`

Expected: `resolveIndividualCategoryName is not a function` or similar import error.

- [ ] **Step 3: Implement `resolveIndividualCategoryName` in `results.ts`**

Add this export near the top of the pure-function exports in `src/lib/results.ts` (alongside `parseResultsCsv` etc.):

```typescript
export function resolveIndividualCategoryName(
  id: string,
  sex?: string,
  ageCategory?: string,
  name?: string,
): string {
  if (name) return name;
  if (!sex) return id;
  const sexLabel = sex === 'M' ? 'Men' : 'Women';
  if (!ageCategory) return sexLabel;
  const ageLabel =
    ageCategory === 'SEN' ? 'Senior' :
    ageCategory === 'JUN' ? 'Junior' :
    ageCategory;
  return `${ageLabel} ${sexLabel}`;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `npm test`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```
git add src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat: add resolveIndividualCategoryName pure function"
```

---

### Task 3: Fix individual standings pages

Both pages are structurally identical — apply the same changes to each.

**Files:**
- Modify: `src/pages/fell/[year]/individual-standings.astro`
- Modify: `src/pages/road-gp/[year]/individual-standings.astro`

- [ ] **Step 1: Update the fell individual-standings page**

Replace the frontmatter block of `src/pages/fell/[year]/individual-standings.astro` (lines 1–31):

```astro
---
// src/pages/fell/[year]/individual-standings.astro
import Layout from '../../../components/Layout.astro';
import { getRaces } from '../../../lib/data';
import { getIndividualStandingsStaticPaths, resolveIndividualCategoryName } from '../../../lib/results';
import type { Club, SeriesConfig, IndividualStandings } from '../../../lib/types';
import { buildRunnerUrlMap } from '../../../lib/runners';
import { siteUrl } from '../../../lib/url';

export async function getStaticPaths() {
  return getIndividualStandingsStaticPaths('fell').map(p => ({
    ...p,
    props: { ...p.props, runnerUrlMap: buildRunnerUrlMap(p.props.year, 'fell') },
  }));
}

interface Props {
  year: number;
  standings: IndividualStandings;
  clubs: Club[];
  config: SeriesConfig;
  linkedRaceIds: string[];
  runnerUrlMap: Record<number, string>;
}

const { year, standings, clubs, runnerUrlMap } = Astro.props;
const linkedRaceIds = new Set(Astro.props.linkedRaceIds);
const races = getRaces(year, 'fell');
const raceById = Object.fromEntries(races.map(r => [r.id, r]));
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
---
```

Then replace the two template spots that reference the removed config fields:

Replace:
```astro
    {config.maxCountingRaces && (
      <p class="text-sm text-base-content/60 mt-0.5">Best {config.maxCountingRaces} races count</p>
    )}
```
With:
```astro
    {standings.maxCountingRaces && (
      <p class="text-sm text-base-content/60 mt-0.5">Best {standings.maxCountingRaces} races count</p>
    )}
```

Replace:
```astro
        const label = categoryById[cat.category]?.name ?? cat.category;
```
With:
```astro
        const label = resolveIndividualCategoryName(cat.id, cat.sex, cat.ageCategory, cat.name);
```

In the runner row section, replace the two occurrences of `runner.sex` and `runner.ageCategory` used as HTML data attributes and the `catLabel` variable. Find:
```astro
                  class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30"
                    data-sex={runner.sex}
                    data-age-cat={runner.ageCategory}
```
Replace with:
```astro
                  class="border-b border-base-200/50 last:border-0 hover:bg-base-200/30"
                    data-sex={runner.sex ?? cat.sex}
                    data-age-cat={runner.ageCategory ?? cat.ageCategory}
```

Find the mobile card:
```astro
                class="runner-card border-b border-base-200 last:border-0"
                data-sex={runner.sex}
                data-age-cat={runner.ageCategory}
```
Replace with:
```astro
                class="runner-card border-b border-base-200 last:border-0"
                data-sex={runner.sex ?? cat.sex}
                data-age-cat={runner.ageCategory ?? cat.ageCategory}
```

Find:
```astro
                    const catLabel = `${runner.sex}${runner.ageCategory}`;
```
Replace with:
```astro
                    const effectiveSex = runner.sex ?? cat.sex ?? '';
                    const effectiveAgeCategory = runner.ageCategory ?? cat.ageCategory ?? '';
                    const catLabel = `${effectiveSex}${effectiveAgeCategory}`;
```

The mobile version has the same catLabel — find and replace it too:
```astro
                  const catLabel = `${runner.sex}${runner.ageCategory}`;
```
Replace with:
```astro
                  const effectiveSex = runner.sex ?? cat.sex ?? '';
                  const effectiveAgeCategory = runner.ageCategory ?? cat.ageCategory ?? '';
                  const catLabel = `${effectiveSex}${effectiveAgeCategory}`;
```

Also remove the now-unused `categoryById` line (since we removed it from the frontmatter in the first edit, verify it's gone).

- [ ] **Step 2: Apply identical changes to the road-gp individual-standings page**

`src/pages/road-gp/[year]/individual-standings.astro` is structurally identical to the fell page. Apply all the same edits with these substitutions:
- `fell` → `road-gp` in paths and strings
- `Road Grand Prix` in titles

The logic changes (maxCountingRaces, resolveIndividualCategoryName, data-sex/data-age-cat, catLabel) are character-for-character identical.

- [ ] **Step 3: Build to verify no TypeScript errors in these pages**

Run: `npm run build 2>&1 | grep "individual-standings"`

Expected: no errors referencing `individual-standings.astro`.

- [ ] **Step 4: Commit**

```
git add src/pages/fell/[year]/individual-standings.astro src/pages/road-gp/[year]/individual-standings.astro
git commit -m "feat: derive individual category names from standings data"
```

---

### Task 4: Fix awards resolution in year index pages

**Files:**
- Modify: `src/pages/fell/[year]/index.astro`
- Modify: `src/pages/road-gp/[year]/index.astro`

Both pages have identical logic. In each, find the awards resolution block (currently around lines 38–67).

- [ ] **Step 1: Update fell index.astro**

In `src/pages/fell/[year]/index.astro`, replace the import line:
```typescript
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings } from '../../../lib/results';
```
With:
```typescript
import { getAwards, getClubs, getSeriesConfig, hasAwards, hasIndividualStandings, hasTeamStandings, resolveIndividualCategoryName } from '../../../lib/results';
```

Replace the `resolveIndividualCategory` helper and the `partitioned` mapping:
```typescript
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
```
With:
```typescript
  const runnerUrlMap = buildRunnerUrlMap(year, 'fell');

  const partitioned = raw.individualAwards.map(ia => ({
    sex: ia.sex,
    resolved: {
      categoryName: resolveIndividualCategoryName(ia.id, ia.sex, ia.ageCategory, ia.name),
      awards: ia.awards.map(a => ({
        position: a.position,
        name: a.name,
        clubName: resolveClub(a.club),
        runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
      })),
    },
  }));
```

- [ ] **Step 2: Apply identical changes to road-gp index.astro**

`src/pages/road-gp/[year]/index.astro` is structurally identical. Apply the same edits (the code is character-for-character the same except for `'fell'` → `'road-gp'` in the `buildRunnerUrlMap` call and path strings in imports).

- [ ] **Step 3: Build to verify no TypeScript errors in these pages**

Run: `npm run build 2>&1 | grep "index.astro"`

Expected: no errors in `[year]/index.astro` files.

- [ ] **Step 4: Commit**

```
git add src/pages/fell/[year]/index.astro src/pages/road-gp/[year]/index.astro
git commit -m "feat: resolve award category names from award object fields"
```

---

### Task 5: Fix runners.ts

**Files:**
- Modify: `src/lib/runners.ts`

- [ ] **Step 1: Update the award name resolution in `getAwardsForRunner`**

In `src/lib/runners.ts`, find the `getAwardsForRunner` function (around line 134). Replace:

```typescript
function getAwardsForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileAward[] {
  const awardsFiles = series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
  const raw = awardsFiles[`../data/${year}/${series}/awards.json`]?.default;
  if (!raw) return [];
  const config = getSeriesConfig(year, series);
  const found: RunnerProfileAward[] = [];
  for (const ia of raw.individualAwards) {
    const entry = ia.awards.find(a => a.seriesRunnerId === seriesLocalId);
    if (entry) {
      const categoryName = config.individualCategories?.find(c => c.id === ia.id)?.name ?? ia.id;
      found.push({ categoryName, position: entry.position });
    }
  }
  return found;
}
```

With:

```typescript
function getAwardsForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileAward[] {
  const awardsFiles = series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
  const raw = awardsFiles[`../data/${year}/${series}/awards.json`]?.default;
  if (!raw) return [];
  const found: RunnerProfileAward[] = [];
  for (const ia of raw.individualAwards) {
    const entry = ia.awards.find(a => a.seriesRunnerId === seriesLocalId);
    if (entry) {
      const categoryName = resolveIndividualCategoryName(ia.id, ia.sex, ia.ageCategory, ia.name);
      found.push({ categoryName, position: entry.position });
    }
  }
  return found;
}
```

Also add the import at the top of the file. Find the existing results import:
```typescript
import { getSeriesConfig, ... } from './results';
```
Add `resolveIndividualCategoryName` to that import, e.g.:
```typescript
import { getSeriesConfig, resolveIndividualCategoryName, ... } from './results';
```

(Keep `getSeriesConfig` in the import only if it's used elsewhere in the file. If the only usage was in `getAwardsForRunner`, remove it too.)

- [ ] **Step 2: Check if `getSeriesConfig` is still used in runners.ts**

Run: `grep -n "getSeriesConfig" src/lib/runners.ts`

If the only hit was the line we just removed, also remove `getSeriesConfig` from the results import.

- [ ] **Step 3: Build to verify**

Run: `npm run build 2>&1 | grep "runners.ts"`

Expected: no errors.

- [ ] **Step 4: Commit**

```
git add src/lib/runners.ts
git commit -m "feat: resolve runner award category names from award fields"
```

---

### Task 6: Fix stray `"id"` fields in 2025 road-gp awards

**Files:**
- Modify: `src/data/2025/road-gp/awards.json`

The award entries under `individualAwards[].awards[]` have `"id": "SEN"` / `"id": "V35"` etc. that should be `"ageCategory"`.

- [ ] **Step 1: Rename the stray fields**

In `src/data/2025/road-gp/awards.json`, do a find-and-replace scoped to the award entry objects. Each occurrence looks like:

```json
{
  "position": 1,
  "name": "Katie Littlefair",
  "club": "preston",
  "id": "SEN",
  "seriesRunnerId": 164
}
```

Change every `"id": "<ageCategory>"` inside an award entry to `"ageCategory": "<ageCategory>"`. The parent `IndividualAward` objects keep their `"id"` field unchanged — only the `"id"` fields on the `IndividualAwardEntry` objects (the ones alongside `"position"`, `"name"`, `"club"`) need renaming.

Note: not all award entries have this field — only some entries in the `"female"` and `"male"` categories have it. Entries in the vet categories (v40+) do not.

After the edit, the affected entries should look like:

```json
{
  "position": 1,
  "name": "Katie Littlefair",
  "club": "preston",
  "ageCategory": "SEN",
  "seriesRunnerId": 164
}
```

- [ ] **Step 2: Verify with a build**

Run: `npm run build 2>&1 | grep "awards"`

Expected: no errors.

- [ ] **Step 3: Commit**

```
git add src/data/2025/road-gp/awards.json
git commit -m "fix: rename stray id fields to ageCategory on 2025 road-gp award entries"
```

---

### Task 7: Remove `individualCategories` and `maxCountingRaces` from config files

**Files:**
- Modify: all `src/data/*/*/config.json` files that contain these keys

- [ ] **Step 1: Find all affected config files**

Run:
```
grep -rl "individualCategories\|maxCountingRaces" src/data
```

This will list every config.json (and any other file) that still has these keys. The output is the list of files to edit.

- [ ] **Step 2: Remove the keys from each file**

For each file listed, remove:
- The entire `"individualCategories": [...]` array (including the key)
- The `"maxCountingRaces": N` line

The remaining keys (`ageCategories`, `teamCategories`, `note`) are unchanged. A cleaned config looks like:

```json
{
  "ageCategories": ["SEN", "V40", "V50", "V60", "V70"],
  "teamCategories": [
    { "id": "open",   "name": "Open",    "scorerCount": 5 },
    { "id": "ladies", "name": "Ladies",  "scorerCount": 3 },
    { "id": "vets",   "name": "Vets",    "scorerCount": 4 },
    { "id": "v50",    "name": "Vet 50s", "scorerCount": 3 },
    { "id": "v60",    "name": "Vet 60s", "scorerCount": 2 }
  ]
}
```

- [ ] **Step 3: Verify no config files still have the removed keys**

Run: `grep -rl "individualCategories\|maxCountingRaces" src/data`

Expected: no output (empty).

- [ ] **Step 4: Commit**

```
git add src/data
git commit -m "chore: remove individualCategories and maxCountingRaces from series configs"
```

---

### Task 8: Full build verification

- [ ] **Step 1: Run the full build**

Run: `npm run build`

Expected: zero TypeScript errors, site builds successfully.

- [ ] **Step 2: Run all tests**

Run: `npm test`

Expected: all tests pass.

- [ ] **Step 3: Spot-check the built output**

Open `dist/fell/2025/individual-standings/index.html` and `dist/road-gp/2025/individual-standings/index.html`. Verify:
- Category tab labels render correctly (e.g. "Men", "Women", "V40 Men")
- The "Best N races count" notice is absent (existing standings files don't yet carry `maxCountingRaces` — that's correct per the spec, which makes migration opt-in). Confirm no JavaScript errors in the console.

Open `dist/fell/2025/index.html` and `dist/road-gp/2025/index.html`. Verify:
- Individual awards section renders with correct category names
- Male/female column split is correct

- [ ] **Step 4: Commit if any final fixes were needed**

If step 3 revealed issues, fix and commit. Otherwise no commit needed — all work is already committed.
