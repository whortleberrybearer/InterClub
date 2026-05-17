# Individual History Page Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the per-year card layout on the individual history page with a two-level tabbed (Male / Female / Overall → age category) table showing years as rows and 1st / 2nd / 3rd positions as columns.

**Architecture:** Add a pure `pivotIndividualAwardsByCategory` function to `results.ts` that reshapes year-keyed award data into category-keyed table data. Both history pages (`road-gp` and `fell`) call this function and pass the result to a rewritten `AwardsHistoryIndividuals` component that renders two-level tabs and a table per category. Tab state is managed by an inline `<script>` using data attributes.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4, DaisyUI v5, Vitest

---

### Task 1: Add types and pivot function to `results.ts`

**Files:**
- Modify: `src/lib/results.ts` (append to end of file)

- [ ] **Step 1: Add the new interfaces and function**

Append to the end of `src/lib/results.ts`:

```ts
// ---- Individual history pivot ----

export interface YearlyResolvedIndividual {
  year: number;
  categories: Array<{
    id: string;
    name: string;
    sex: 'M' | 'F' | null;
    awards: Array<{
      position: number;
      name: string;
      clubName: string;
      runnerUrl?: string;
    }>;
  }>;
}

export interface CategoryHistoryEntry {
  name: string;
  clubName: string;
  runnerUrl?: string;
}

export interface CategoryHistoryRow {
  year: number;
  positions: {
    1: CategoryHistoryEntry | null;
    2: CategoryHistoryEntry | null;
    3: CategoryHistoryEntry | null;
  };
}

export interface CategoryHistoryData {
  id: string;
  name: string;
  sex: 'M' | 'F' | null;
  rows: CategoryHistoryRow[];
}

export function pivotIndividualAwardsByCategory(
  yearlyData: YearlyResolvedIndividual[]
): CategoryHistoryData[] {
  const categoryMap = new Map<string, { name: string; sex: 'M' | 'F' | null }>();
  for (const yearly of yearlyData) {
    for (const cat of yearly.categories) {
      if (!categoryMap.has(cat.id)) {
        categoryMap.set(cat.id, { name: cat.name, sex: cat.sex });
      }
    }
  }

  return Array.from(categoryMap.entries()).map(([id, meta]) => {
    const rows = yearlyData
      .filter(yearly => yearly.categories.some(c => c.id === id))
      .map(yearly => {
        const cat = yearly.categories.find(c => c.id === id)!;
        const findPos = (pos: number) => cat.awards.find(a => a.position === pos);
        const mapEntry = (a: ReturnType<typeof findPos>): CategoryHistoryEntry | null =>
          a ? { name: a.name, clubName: a.clubName, runnerUrl: a.runnerUrl } : null;
        return {
          year: yearly.year,
          positions: {
            1: mapEntry(findPos(1)),
            2: mapEntry(findPos(2)),
            3: mapEntry(findPos(3)),
          },
        };
      });
    return { id, name: meta.name, sex: meta.sex, rows };
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add src/lib/results.ts
git commit -m "feat: add pivotIndividualAwardsByCategory to results.ts"
```

---

### Task 2: Test `pivotIndividualAwardsByCategory`

**Files:**
- Modify: `tests/lib/results.test.ts`

- [ ] **Step 1: Write failing tests**

Add to `tests/lib/results.test.ts` (add to the imports line at the top):

```ts
import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath, parseIndividualStandingsPath, pivotIndividualAwardsByCategory } from '../../src/lib/results';
```

Then append the following `describe` block to `tests/lib/results.test.ts`:

```ts
describe('pivotIndividualAwardsByCategory', () => {
  it('returns empty array for empty input', () => {
    expect(pivotIndividualAwardsByCategory([])).toEqual([]);
  });

  it('returns one category entry for a single year with one category', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'sen-m',
        name: 'Senior Men',
        sex: 'M' as const,
        awards: [
          { position: 1, name: 'A. Smith', clubName: 'Wesham' },
          { position: 2, name: 'B. Jones', clubName: 'Preston' },
        ],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('sen-m');
    expect(result[0].name).toBe('Senior Men');
    expect(result[0].sex).toBe('M');
    expect(result[0].rows).toHaveLength(1);
    expect(result[0].rows[0].year).toBe(2024);
    expect(result[0].rows[0].positions[1]).toEqual({ name: 'A. Smith', clubName: 'Wesham', runnerUrl: undefined });
    expect(result[0].rows[0].positions[2]).toEqual({ name: 'B. Jones', clubName: 'Preston', runnerUrl: undefined });
    expect(result[0].rows[0].positions[3]).toBeNull();
  });

  it('omits years that have no entry for a category', () => {
    const input = [
      {
        year: 2024,
        categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [{ position: 1, name: 'A', clubName: 'X' }] }],
      },
      {
        year: 2023,
        categories: [], // no sen-m this year
      },
      {
        year: 2022,
        categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [{ position: 1, name: 'B', clubName: 'Y' }] }],
      },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows).toHaveLength(2);
    expect(result[0].rows.map(r => r.year)).toEqual([2024, 2022]);
  });

  it('preserves the input year order (caller is responsible for sorting)', () => {
    const input = [
      { year: 2025, categories: [{ id: 'sen-f', name: 'Senior Women', sex: 'F' as const, awards: [{ position: 1, name: 'C', clubName: 'Z' }] }] },
      { year: 2024, categories: [{ id: 'sen-f', name: 'Senior Women', sex: 'F' as const, awards: [{ position: 1, name: 'D', clubName: 'W' }] }] },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].year).toBe(2025);
    expect(result[0].rows[1].year).toBe(2024);
  });

  it('returns null for positions not present in the data', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'v40-m', name: 'V40 Men', sex: 'M' as const,
        awards: [{ position: 1, name: 'E', clubName: 'Q' }],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].positions[2]).toBeNull();
    expect(result[0].rows[0].positions[3]).toBeNull();
  });

  it('propagates runnerUrl when present', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'sen-m', name: 'Senior Men', sex: 'M' as const,
        awards: [{ position: 1, name: 'F', clubName: 'R', runnerUrl: '/runners/f-surname' }],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].positions[1]?.runnerUrl).toBe('/runners/f-surname');
  });

  it('collects all categories across all years', () => {
    const input = [
      { year: 2024, categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [] }] },
      { year: 2023, categories: [{ id: 'v40-f', name: 'V40 Women', sex: 'F' as const, awards: [] }] },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result).toHaveLength(2);
    expect(result.map(c => c.id)).toContain('sen-m');
    expect(result.map(c => c.id)).toContain('v40-f');
  });

  it('propagates null sex for overall categories', () => {
    const input = [{
      year: 2024,
      categories: [{ id: 'overall', name: 'Overall', sex: null, awards: [] }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].sex).toBeNull();
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npm test -- --reporter=verbose 2>&1 | tail -30
```

Expected: failures on `pivotIndividualAwardsByCategory` (function not yet exported / tests newly added). If they pass already, check that the import in step 1 was correct.

- [ ] **Step 3: Run tests to verify they pass (function already added in Task 1)**

```bash
npm test -- --reporter=verbose 2>&1 | tail -30
```

Expected: all `pivotIndividualAwardsByCategory` tests PASS.

- [ ] **Step 4: Commit**

```bash
git add tests/lib/results.test.ts
git commit -m "test: add pivotIndividualAwardsByCategory tests"
```

---

### Task 3: Rewrite `AwardsHistoryIndividuals.astro`

**Files:**
- Modify: `src/components/AwardsHistoryIndividuals.astro`

- [ ] **Step 1: Replace the entire file content**

```astro
---
import type { CategoryHistoryData } from '../lib/results';

interface Props {
  categories: CategoryHistoryData[];
}

const { categories } = Astro.props;

const groups = [
  { key: 'M',       label: 'Male',    cats: categories.filter(c => c.sex === 'M') },
  { key: 'F',       label: 'Female',  cats: categories.filter(c => c.sex === 'F') },
  { key: 'overall', label: 'Overall', cats: categories.filter(c => c.sex === null) },
].filter(g => g.cats.length > 0);
---

{groups.length === 0 ? (
  <p class="text-base-content/60">No individual awards recorded.</p>
) : (
  <div>
    <div role="tablist" class="tabs tabs-border mb-2">
      {groups.map((group, i) => (
        <button
          role="tab"
          class={`tab${i === 0 ? ' tab-active' : ''}`}
          data-top-tab={group.key}
        >
          {group.label}
        </button>
      ))}
    </div>

    {groups.map((group, i) => (
      <div data-top-panel={group.key} class={i > 0 ? 'hidden' : ''}>
        {group.cats.length > 1 && (
          <div role="tablist" class="tabs tabs-border mb-4">
            {group.cats.map((cat, j) => (
              <button
                role="tab"
                class={`tab${j === 0 ? ' tab-active' : ''}`}
                data-sub-tab={cat.id}
                data-group={group.key}
              >
                {cat.name}
              </button>
            ))}
          </div>
        )}

        {group.cats.map((cat, j) => (
          <div
            data-sub-panel={cat.id}
            data-group={group.key}
            class={j > 0 ? 'hidden' : ''}
          >
            {cat.rows.length === 0 ? (
              <p class="text-base-content/60">No awards recorded.</p>
            ) : (
              <div class="overflow-x-auto">
                <table class="table table-sm w-full">
                  <caption class="sr-only">{cat.name} award winners by year</caption>
                  <thead>
                    <tr>
                      <th scope="col">Year</th>
                      <th scope="col">1st</th>
                      <th scope="col">2nd</th>
                      <th scope="col">3rd</th>
                    </tr>
                  </thead>
                  <tbody>
                    {cat.rows.map(row => (
                      <tr class="hover">
                        <td class="font-semibold">{row.year}</td>
                        {([1, 2, 3] as const).map(pos => {
                          const entry = row.positions[pos];
                          return (
                            <td class="text-sm">
                              {entry ? (
                                <span>
                                  {entry.runnerUrl ? (
                                    <a href={entry.runnerUrl} class="link link-hover font-medium">{entry.name}</a>
                                  ) : (
                                    <span class="font-medium">{entry.name}</span>
                                  )}
                                  <span class="text-base-content/50 ml-1">({entry.clubName})</span>
                                </span>
                              ) : <span>—</span>}
                            </td>
                          );
                        })}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        ))}
      </div>
    ))}
  </div>
)}

<script>
  document.querySelectorAll<HTMLButtonElement>('[data-top-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      const key = btn.dataset.topTab!;
      document.querySelectorAll('[data-top-tab]').forEach(t => t.classList.remove('tab-active'));
      btn.classList.add('tab-active');
      document.querySelectorAll('[data-top-panel]').forEach(p => p.classList.add('hidden'));
      document.querySelector(`[data-top-panel="${key}"]`)?.classList.remove('hidden');
    });
  });

  document.querySelectorAll<HTMLButtonElement>('[data-sub-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      const catId = btn.dataset.subTab!;
      const group = btn.dataset.group!;
      document.querySelectorAll(`[data-sub-tab][data-group="${group}"]`).forEach(t => t.classList.remove('tab-active'));
      btn.classList.add('tab-active');
      document.querySelectorAll(`[data-sub-panel][data-group="${group}"]`).forEach(p => p.classList.add('hidden'));
      document.querySelector(`[data-sub-panel="${catId}"][data-group="${group}"]`)?.classList.remove('hidden');
    });
  });
</script>
```

- [ ] **Step 2: Commit**

```bash
git add src/components/AwardsHistoryIndividuals.astro
git commit -m "feat: rewrite AwardsHistoryIndividuals with tabbed table layout"
```

---

### Task 4: Update road-gp history page

**Files:**
- Modify: `src/pages/road-gp/history/[type].astro`

- [ ] **Step 1: Replace the individuals section of the page**

Replace the entire file with:

```astro
---
import Layout from '../../../components/Layout.astro';
import AwardsHistoryTeams from '../../../components/AwardsHistoryTeams.astro';
import AwardsHistoryIndividuals from '../../../components/AwardsHistoryIndividuals.astro';
import { getAllAwardsByYear, pivotIndividualAwardsByCategory } from '../../../lib/results';
import { buildRunnerUrlMap } from '../../../lib/runners';
import type { TeamCategory, CategoryHistoryData } from '../../../lib/types';

export function getStaticPaths() {
  return [
    { params: { type: 'teams' } },
    { params: { type: 'individuals' } },
  ];
}

const series = 'road-gp';
const { type } = Astro.params as { type: 'teams' | 'individuals' };

const allYearlyAwards = getAllAwardsByYear(series);

const pageTitle = type === 'teams' ? 'Road Grand Prix Team Winners' : 'Road Grand Prix Individual Winners';

// Prepare team data
let allCategories: TeamCategory[] = [];
let yearlyTeamData: Array<{ year: number; categoryWinners: Record<string, string | null> }> = [];

if (type === 'teams') {
  const categoryMap = new Map<string, TeamCategory>();
  allYearlyAwards.forEach(yearly => {
    yearly.config.teamCategories?.forEach(cat => {
      if (!categoryMap.has(cat.id)) {
        categoryMap.set(cat.id, cat);
      }
    });
  });
  allCategories = Array.from(categoryMap.values());

  yearlyTeamData = allYearlyAwards.map(yearly => {
    const categoryWinners: Record<string, string | null> = {};
    allCategories.forEach(cat => {
      const award = yearly.awards.teamAwards.find(ta => ta.category === cat.id);
      if (award) {
        const clubName = yearly.clubs.find(c => c.id === award.club)?.name ?? award.club;
        categoryWinners[cat.id] = clubName;
      } else {
        categoryWinners[cat.id] = null;
      }
    });
    return { year: yearly.year, categoryWinners };
  });
}

// Prepare individual data
let categoryData: CategoryHistoryData[] = [];

if (type === 'individuals') {
  const yearlyResolved = allYearlyAwards.map(yearly => {
    const runnerUrlMap = buildRunnerUrlMap(yearly.year, series);
    return {
      year: yearly.year,
      categories: yearly.awards.individualAwards.map(ia => {
        const configCat = yearly.config.individualCategories?.find(c => c.id === ia.category);
        return {
          id: ia.category,
          name: configCat?.name ?? ia.category,
          sex: configCat?.sex ?? null,
          awards: ia.awards.map(a => ({
            position: a.position,
            name: a.name,
            clubName: yearly.clubs.find(c => c.id === a.club)?.name ?? a.club ?? '',
            runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
          })),
        };
      }),
    };
  });
  categoryData = pivotIndividualAwardsByCategory(yearlyResolved);
}
---

<Layout title={pageTitle}>
  <div class="container mx-auto px-4 py-6">
    <div class="mb-6">
      <a href="/road-gp" class="btn btn-sm btn-ghost">← Back</a>
    </div>
    <h1 class="text-3xl font-bold mb-6">{pageTitle}</h1>
    {type === 'teams' ? (
      <AwardsHistoryTeams
        series={series}
        yearlyData={yearlyTeamData}
        allCategories={allCategories}
      />
    ) : (
      <AwardsHistoryIndividuals categories={categoryData} />
    )}
  </div>
</Layout>
```

Note: `CategoryHistoryData` is imported from `'../../../lib/types'` — but it's defined in `results.ts`. Update the import to `'../../../lib/results'`:

```ts
import type { TeamCategory } from '../../../lib/types';
import { getAllAwardsByYear, pivotIndividualAwardsByCategory } from '../../../lib/results';
import type { CategoryHistoryData } from '../../../lib/results';
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/road-gp/history/[type].astro
git commit -m "feat: update road-gp history page to use pivoted individual data"
```

---

### Task 5: Update fell history page

**Files:**
- Modify: `src/pages/fell/history/[type].astro`

- [ ] **Step 1: Read the current fell history page**

Read `src/pages/fell/history/[type].astro` to confirm its structure matches the road-gp version.

- [ ] **Step 2: Apply the same changes as Task 4**

Replace the file with the same content as the road-gp version from Task 4, changing only:
- `const series = 'road-gp';` → `const series = 'fell';`
- `pageTitle` values: `'Fell Championship Team Winners'` and `'Fell Championship Individual Winners'`
- `<a href="/road-gp"` → `<a href="/fell"`
- All three import paths: `'../../../components/...'` → `'../../../components/...'` (same depth, no change needed)
- All three import paths from lib: `'../../../lib/...'` (same depth, no change needed)

The full file content to write:

```astro
---
import Layout from '../../../components/Layout.astro';
import AwardsHistoryTeams from '../../../components/AwardsHistoryTeams.astro';
import AwardsHistoryIndividuals from '../../../components/AwardsHistoryIndividuals.astro';
import { getAllAwardsByYear, pivotIndividualAwardsByCategory } from '../../../lib/results';
import { buildRunnerUrlMap } from '../../../lib/runners';
import type { TeamCategory } from '../../../lib/types';
import type { CategoryHistoryData } from '../../../lib/results';

export function getStaticPaths() {
  return [
    { params: { type: 'teams' } },
    { params: { type: 'individuals' } },
  ];
}

const series = 'fell';
const { type } = Astro.params as { type: 'teams' | 'individuals' };

const allYearlyAwards = getAllAwardsByYear(series);

const pageTitle = type === 'teams' ? 'Fell Championship Team Winners' : 'Fell Championship Individual Winners';

// Prepare team data
let allCategories: TeamCategory[] = [];
let yearlyTeamData: Array<{ year: number; categoryWinners: Record<string, string | null> }> = [];

if (type === 'teams') {
  const categoryMap = new Map<string, TeamCategory>();
  allYearlyAwards.forEach(yearly => {
    yearly.config.teamCategories?.forEach(cat => {
      if (!categoryMap.has(cat.id)) {
        categoryMap.set(cat.id, cat);
      }
    });
  });
  allCategories = Array.from(categoryMap.values());

  yearlyTeamData = allYearlyAwards.map(yearly => {
    const categoryWinners: Record<string, string | null> = {};
    allCategories.forEach(cat => {
      const award = yearly.awards.teamAwards.find(ta => ta.category === cat.id);
      if (award) {
        const clubName = yearly.clubs.find(c => c.id === award.club)?.name ?? award.club;
        categoryWinners[cat.id] = clubName;
      } else {
        categoryWinners[cat.id] = null;
      }
    });
    return { year: yearly.year, categoryWinners };
  });
}

// Prepare individual data
let categoryData: CategoryHistoryData[] = [];

if (type === 'individuals') {
  const yearlyResolved = allYearlyAwards.map(yearly => {
    const runnerUrlMap = buildRunnerUrlMap(yearly.year, series);
    return {
      year: yearly.year,
      categories: yearly.awards.individualAwards.map(ia => {
        const configCat = yearly.config.individualCategories?.find(c => c.id === ia.category);
        return {
          id: ia.category,
          name: configCat?.name ?? ia.category,
          sex: configCat?.sex ?? null,
          awards: ia.awards.map(a => ({
            position: a.position,
            name: a.name,
            clubName: yearly.clubs.find(c => c.id === a.club)?.name ?? a.club ?? '',
            runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
          })),
        };
      }),
    };
  });
  categoryData = pivotIndividualAwardsByCategory(yearlyResolved);
}
---

<Layout title={pageTitle}>
  <div class="container mx-auto px-4 py-6">
    <div class="mb-6">
      <a href="/fell" class="btn btn-sm btn-ghost">← Back</a>
    </div>
    <h1 class="text-3xl font-bold mb-6">{pageTitle}</h1>
    {type === 'teams' ? (
      <AwardsHistoryTeams
        series={series}
        yearlyData={yearlyTeamData}
        allCategories={allCategories}
      />
    ) : (
      <AwardsHistoryIndividuals categories={categoryData} />
    )}
  </div>
</Layout>
```

- [ ] **Step 3: Commit**

```bash
git add src/pages/fell/history/[type].astro
git commit -m "feat: update fell history page to use pivoted individual data"
```

---

### Task 6: Build verification

**Files:** None (verification only)

- [ ] **Step 1: Run unit tests**

```bash
npm test 2>&1 | tail -20
```

Expected: all tests PASS, no failures.

- [ ] **Step 2: Run build**

```bash
npm run build 2>&1 | tail -40
```

Expected: build completes with no TypeScript errors. If you see type errors, the most likely causes are:
- `CategoryHistoryData` imported from wrong path — must be `'../../../lib/results'`, not `'../../../lib/types'`
- `series` prop still being passed to `AwardsHistoryIndividuals` — the new component does not accept a `series` prop; remove it

- [ ] **Step 3: Commit if build is clean**

If the build passes without errors, no additional commit is needed (all changes are already committed). If you made fixes, commit them:

```bash
git add -p
git commit -m "fix: resolve build errors in individual history pages"
```
