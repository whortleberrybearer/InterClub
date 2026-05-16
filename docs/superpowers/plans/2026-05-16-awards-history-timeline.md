# Awards History Timeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create dedicated history pages showing award winners across all years for Road GP and Fell Championship series without requiring navigation to individual year pages.

**Architecture:** Build four static pages using dynamic routing (`[series]/[type]`), reusing award resolution logic from existing year pages. Load all awards files at build time via `import.meta.glob`, aggregate by series, and render in two layouts (tabular for teams, cards for individuals). Navigation links guide users to history pages from series index pages.

**Tech Stack:** Astro (static generation), TypeScript, TailwindCSS + DaisyUI, existing types and data loading patterns from `src/lib/results.ts`.

---

## File Structure

**New files:**
- `src/components/AwardsHistoryTeams.astro` — Renders tabular team awards history
- `src/components/AwardsHistoryIndividuals.astro` — Renders chronological year cards with individual awards
- `src/pages/history/[series]/[type].astro` — Dynamic page router for four history pages

**Modified files:**
- `src/lib/results.ts` — Add helper functions to load and aggregate awards across all years
- `src/pages/road-gp/[year]/index.astro` — Add navigation link to history pages
- `src/pages/fell/[year]/index.astro` — Add navigation link to history pages

---

## Task 1: Add Award Aggregation Helpers to `src/lib/results.ts`

**Files:**
- Modify: `src/lib/results.ts:1-90` (add new functions after existing imports and globs)

- [ ] **Step 1: Add new import.meta.glob calls for awards data**

Open `src/lib/results.ts` and locate the existing `import.meta.glob` declarations (around line 76-85). After the existing `roadAwardsFiles` and `fellAwardsFiles` globs, these are already defined, so we'll use them to build aggregation functions.

No code changes needed here — the globs already exist.

- [ ] **Step 2: Add getAllAwardsByYear helper function**

Add this function after the existing helper functions in `src/lib/results.ts`:

```typescript
interface YearlyAwardsData {
  year: number;
  awards: SeriesAwards;
  clubs: Club[];
  config: SeriesConfig;
}

export function getAllAwardsByYear(series: Series): YearlyAwardsData[] {
  const awardsFiles = awardsFilesForSeries(series);
  const awardsList: YearlyAwardsData[] = [];

  Object.keys(awardsFiles).forEach(path => {
    const match = path.match(/\/data\/(\d+)\//);
    if (!match) return;
    
    const year = parseInt(match[1], 10);
    const awards = awardsFiles[path].default;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    
    awardsList.push({ year, awards, clubs, config });
  });

  // Sort by year descending (newest first)
  return awardsList.sort((a, b) => b.year - a.year);
}
```

- [ ] **Step 3: Run npm test to ensure no TypeScript errors**

```bash
npm test
```

Expected: All tests pass or fail in pre-existing ways (no new errors introduced).

- [ ] **Step 4: Run npm run build to check that globs work correctly**

```bash
npm run build
```

Expected: Build completes successfully; no "glob not found" or import errors.

- [ ] **Step 5: Commit**

```bash
git add src/lib/results.ts
git commit -m "feat: add getAllAwardsByYear helper for aggregating awards by year"
```

---

## Task 2: Create AwardsHistoryTeams Component

**Files:**
- Create: `src/components/AwardsHistoryTeams.astro`

- [ ] **Step 1: Create the component file with props interface**

Create `src/components/AwardsHistoryTeams.astro` with the following content:

```astro
---
import type { Series, TeamCategory, Club } from '../lib/types';

interface YearlyTeamAwards {
  year: number;
  categoryWinners: Record<string, string | null>; // categoryId → clubName or null
}

interface Props {
  series: Series;
  yearlyData: YearlyTeamAwards[];
  allCategories: TeamCategory[];
}

const { yearlyData, allCategories } = Astro.props;
---

<div class="overflow-x-auto">
  <table class="table table-sm w-full">
    <thead>
      <tr>
        <th class="text-base">Year</th>
        {allCategories.map(cat => (
          <th class="text-center text-sm">{cat.name}</th>
        ))}
      </tr>
    </thead>
    <tbody>
      {yearlyData.map(yearly => (
        <tr class="hover">
          <td class="font-semibold">{yearly.year}</td>
          {allCategories.map(cat => (
            <td class="text-center text-sm">
              {yearly.categoryWinners[cat.id] ?? '—'}
            </td>
          ))}
        </tr>
      ))}
    </tbody>
  </table>
</div>
```

- [ ] **Step 2: Verify component syntax with npm run build**

```bash
npm run build
```

Expected: Build completes successfully; no Astro syntax errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/AwardsHistoryTeams.astro
git commit -m "feat: create AwardsHistoryTeams component with tabular layout"
```

---

## Task 3: Create AwardsHistoryIndividuals Component

**Files:**
- Create: `src/components/AwardsHistoryIndividuals.astro`

- [ ] **Step 1: Create the component file with award resolution logic**

Create `src/components/AwardsHistoryIndividuals.astro`:

```astro
---
import type { Series, IndividualCategory } from '../lib/types';

interface ResolvedAwardEntry {
  position: number;
  name: string;
  clubName: string;
  ageCategory?: string;
  runnerUrl?: string;
}

interface ResolvedCategory {
  categoryName: string;
  awards: ResolvedAwardEntry[];
}

interface YearlyIndividualAwards {
  year: number;
  categories: ResolvedCategory[];
}

interface Props {
  series: Series;
  yearlyData: YearlyIndividualAwards[];
}

const { yearlyData } = Astro.props;

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
---

<div class="space-y-6">
  {yearlyData.map(yearly => (
    <div class="card bg-base-200">
      <div class="card-body p-6">
        <h2 class="card-title text-2xl mb-4">{yearly.year}</h2>
        
        {yearly.categories.length === 0 ? (
          <p class="text-base-content/60">No individual awards</p>
        ) : (
          <div class="space-y-4">
            {yearly.categories.map(cat => (
              <div class="bg-base-100 rounded-lg p-4">
                <p class="text-sm font-semibold text-base-content/70 mb-3">{cat.categoryName}</p>
                <div class="space-y-2">
                  {cat.awards.map(award => (
                    <div class="flex items-baseline gap-3 text-sm">
                      <span class="w-6 shrink-0 text-lg">{positionLabel(award.position)}</span>
                      <div class="flex-1 min-w-0">
                        {award.runnerUrl ? (
                          <a href={award.runnerUrl} class="font-medium link link-hover">
                            {award.name}
                          </a>
                        ) : (
                          <span class="font-medium">{award.name}</span>
                        )}
                      </div>
                      <span class="text-base-content/50 text-xs shrink-0">{award.clubName}</span>
                      {award.ageCategory && (
                        <span class="text-base-content/50 text-xs shrink-0">{award.ageCategory}</span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  ))}
</div>
```

- [ ] **Step 2: Verify component syntax with npm run build**

```bash
npm run build
```

Expected: Build completes successfully; no Astro syntax errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/AwardsHistoryIndividuals.astro
git commit -m "feat: create AwardsHistoryIndividuals component with year cards"
```

---

## Task 4: Create Dynamic History Page

**Files:**
- Create: `src/pages/history/[series]/[type].astro`

- [ ] **Step 1: Create page directory structure**

```bash
mkdir -p src/pages/history/\[series\]
```

- [ ] **Step 2: Create the main page file**

Create `src/pages/history/[series]/[type].astro`:

```astro
---
import Layout from '../../../components/Layout.astro';
import AwardsHistoryTeams from '../../../components/AwardsHistoryTeams.astro';
import AwardsHistoryIndividuals from '../../../components/AwardsHistoryIndividuals.astro';
import { getAllAwardsByYear } from '../../../lib/results';
import { getClubs, getSeriesConfig } from '../../../lib/results';
import { buildRunnerUrlMap } from '../../../lib/runners';
import type { Series, TeamCategory, IndividualCategory } from '../../../lib/types';

export function getStaticPaths() {
  return [
    { params: { series: 'road-gp', type: 'teams' } },
    { params: { series: 'road-gp', type: 'individuals' } },
    { params: { series: 'fell', type: 'teams' } },
    { params: { series: 'fell', type: 'individuals' } },
  ];
}

const { series, type } = Astro.params as { series: Series; type: 'teams' | 'individuals' };

const allYearlyAwards = getAllAwardsByYear(series);

const seriesLabel = series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
const pageTitle = type === 'teams' ? `${seriesLabel} Team Winners` : `${seriesLabel} Individual Winners`;
const backLink = series === 'road-gp' ? '/road-gp' : '/fell';

if (type === 'teams') {
  // Collect all unique team categories across all years
  const allCategoriesSet = new Set<string>();
  allYearlyAwards.forEach(yearly => {
    yearly.config.teamCategories?.forEach(cat => {
      allCategoriesSet.add(cat.id);
    });
  });

  // Create team category objects with names from the first year that has each category
  const categoryMap = new Map<string, TeamCategory>();
  allYearlyAwards.forEach(yearly => {
    yearly.config.teamCategories?.forEach(cat => {
      if (!categoryMap.has(cat.id)) {
        categoryMap.set(cat.id, cat);
      }
    });
  });
  const allCategories = Array.from(categoryMap.values());

  // Build yearly data
  const yearlyTeamData = allYearlyAwards.map(yearly => {
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

    return {
      year: yearly.year,
      categoryWinners,
    };
  });

  ---

  <Layout title={pageTitle}>
    <div class="container mx-auto px-4 py-6">
      <div class="mb-6">
        <a href={backLink} class="btn btn-sm btn-ghost">← Back</a>
      </div>
      <h1 class="text-3xl font-bold mb-6">{pageTitle}</h1>
      <AwardsHistoryTeams
        series={series}
        yearlyData={yearlyTeamData}
        allCategories={allCategories}
      />
    </div>
  </Layout>
} else {
  // type === 'individuals'
  // Collect individual awards across all years
  const yearlyIndividualData = allYearlyAwards.map(yearly => {
    const runnerUrlMap = buildRunnerUrlMap(yearly.year, series);
    
    const categories = yearly.awards.individualAwards.map(ia => {
      const cat = yearly.config.individualCategories?.find(c => c.id === ia.category);
      
      return {
        categoryName: cat?.name ?? ia.category,
        awards: ia.awards.map(a => ({
          position: a.position,
          name: a.name,
          clubName: yearly.clubs.find(c => c.id === a.club)?.name ?? a.club,
          ageCategory: undefined, // Awards don't include age category, only category
          runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
        })),
      };
    });

    return {
      year: yearly.year,
      categories,
    };
  });

  ---

  <Layout title={pageTitle}>
    <div class="container mx-auto px-4 py-6">
      <div class="mb-6">
        <a href={backLink} class="btn btn-sm btn-ghost">← Back</a>
      </div>
      <h1 class="text-3xl font-bold mb-6">{pageTitle}</h1>
      <AwardsHistoryIndividuals
        series={series}
        yearlyData={yearlyIndividualData}
      />
    </div>
  </Layout>
}
```

- [ ] **Step 3: Run npm run build to verify page generation**

```bash
npm run build
```

Expected: Build completes successfully; four new routes generated (road-gp/history/teams, road-gp/history/individuals, fell/history/teams, fell/history/individuals).

- [ ] **Step 4: Run npm run preview and manually test all four routes**

```bash
npm run preview
```

Then navigate to:
- `http://localhost:3000/road-gp/history/teams` — Check table renders with years and categories
- `http://localhost:3000/road-gp/history/individuals` — Check year cards display
- `http://localhost:3000/fell/history/teams` — Check table renders
- `http://localhost:3000/fell/history/individuals` — Check year cards display

Expected: Pages load without errors; tables and cards display data correctly.

- [ ] **Step 5: Commit**

```bash
git add src/pages/history/\[series\]/\[type\].astro
git commit -m "feat: create dynamic history page router for teams and individuals"
```

---

## Task 5: Add Navigation Links to Series Index Pages

**Files:**
- Modify: `src/pages/road-gp/[year]/index.astro`
- Modify: `src/pages/fell/[year]/index.astro`

- [ ] **Step 1: Add navigation link to Road GP history on `road-gp/[year]/index.astro`**

Open `src/pages/road-gp/[year]/index.astro` and find the `<HistoryRaceList>` component (around line 72-85). Add a navigation section above it:

```astro
<Layout title={`Road Grand Prix ${year}`}>
  <div class="container mx-auto px-4 py-4">
    <div class="flex gap-2 mb-4">
      <a href="/road-gp/history/teams" class="btn btn-sm btn-outline">
        📊 Team Winners History
      </a>
      <a href="/road-gp/history/individuals" class="btn btn-sm btn-outline">
        🏃 Individual Winners History
      </a>
    </div>
  </div>
  <HistoryRaceList
    ...
  />
</Layout>
```

- [ ] **Step 2: Run npm run build to verify syntax**

```bash
npm run build
```

Expected: Build completes without errors.

- [ ] **Step 3: Run npm run preview and test the Road GP history link**

```bash
npm run preview
```

Navigate to `http://localhost:3000/road-gp/2025` (or any past year page) and click both new buttons to verify they link correctly.

Expected: Buttons appear on the page and links work.

- [ ] **Step 4: Add navigation link to Fell history on `fell/[year]/index.astro`**

Open `src/pages/fell/[year]/index.astro` and add the same navigation section above `<HistoryRaceList>`:

```astro
<Layout title={`Fell Championship ${year}`}>
  <div class="container mx-auto px-4 py-4">
    <div class="flex gap-2 mb-4">
      <a href="/fell/history/teams" class="btn btn-sm btn-outline">
        📊 Team Winners History
      </a>
      <a href="/fell/history/individuals" class="btn btn-sm btn-outline">
        🏃 Individual Winners History
      </a>
    </div>
  </div>
  <HistoryRaceList
    ...
  />
</Layout>
```

- [ ] **Step 5: Run npm run preview and test Fell history link**

```bash
npm run preview
```

Navigate to `http://localhost:3000/fell/2023` (or any past year page) and click both new buttons.

Expected: Buttons appear and links work correctly.

- [ ] **Step 6: Commit**

```bash
git add src/pages/road-gp/\[year\]/index.astro src/pages/fell/\[year\]/index.astro
git commit -m "feat: add history navigation links to series index pages"
```

---

## Task 6: Manual Testing and Verification

**Files:**
- None (verification only)

- [ ] **Step 1: Run full build and check for errors**

```bash
npm run build
```

Expected: Build completes successfully with no errors or warnings related to new code.

- [ ] **Step 2: Start dev server and test responsive layout**

```bash
npm run dev
```

Navigate to each history page and check:
- Table on teams pages renders correctly with proper column alignment
- Year cards on individuals pages display properly
- Mobile viewport (DevTools mobile emulation): cards stack vertically, table scrolls horizontally
- Tablet/desktop: layout looks good with proper spacing

Expected: All pages render correctly across viewport sizes.

- [ ] **Step 3: Test data accuracy**

On Road GP individual history (`/road-gp/history/individuals`):
- Verify years appear in descending order (newest first)
- Click a few runner profile links (where available) to confirm they lead to correct runner pages
- Verify position badges show 🥇🥈🥉 for top 3, then ordinal numbers

On Road GP team history (`/road-gp/history/teams`):
- Verify years appear in descending order
- Check that team categories are correct (match config.json from a sample year)
- Verify "—" appears for years missing data in a category

Expected: All data displays accurately.

- [ ] **Step 4: Test Fell Championship pages similarly**

Navigate to `/fell/history/individuals` and `/fell/history/teams` and perform the same checks.

Expected: Pages render correctly and data is accurate for Fell series.

- [ ] **Step 5: Verify missing data handling**

Check a year with sparse awards or no awards file (if applicable):
- Individuals page should skip years with no awards file
- Team page should skip years with no awards file
- No errors or blank cards should appear

Expected: Pages handle missing data gracefully.

- [ ] **Step 6: Final commit verification**

```bash
git log --oneline -6
```

Expected: Last 6 commits include the new feature commits from this plan.

---

## Done: Awards History Timeline

All four history pages are now live and accessible:
- `/road-gp/history/teams` — Tabular team award winners
- `/road-gp/history/individuals` — Year cards with individual award winners
- `/fell/history/teams` — Tabular team award winners
- `/fell/history/individuals` — Year cards with individual award winners

Navigation links added to series index pages guide users to the history pages.
