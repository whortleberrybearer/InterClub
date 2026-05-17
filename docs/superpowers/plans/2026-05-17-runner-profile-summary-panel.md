# Runner Profile Summary Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a stats panel to the runner profile page showing club history with year ranges and a compact awards-count summary.

**Architecture:** Three-layer change — new types in `types.ts`, new pure helper + two data-aggregation functions in `runners.ts`, and updated rendering in `[slug].astro`. The Astro page and `runners.ts` props must be updated together in Task 3 (they are co-dependent — removing `clubName` and adding `clubHistory`/`awardSummary` must be consistent across both files).

**Tech Stack:** TypeScript, Astro v6, Vitest (pure-function unit tests only — glob-dependent code is validated by `npm run build`)

---

## File Map

| File | Change |
|------|--------|
| `src/lib/types.ts` | Add `RunnerClubHistory`, `RunnerAwardSummaryEntry`, `RunnerAwardSummary` interfaces |
| `src/lib/runners.ts` | Export `formatYearRanges`; add `buildClubHistory`, `buildAwardSummary`; update `getRunnerProfileStaticPaths` return (drop `clubName`, add `clubHistory` + `awardSummary`); include `club` in series entry accumulation |
| `src/pages/runners/[slug].astro` | Update `Props`, remove `clubName` from destructure, update subtitle, add stats panel |
| `tests/runners.test.ts` | New file — unit tests for `formatYearRanges` |

---

## Task 1: Add new types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add the three new interfaces to `src/lib/types.ts`**

Open `src/lib/types.ts` and append the following after the `RunnerYearBlock` interface (after line 96):

```ts
export interface RunnerClubHistory {
  clubId: string;
  clubName: string;
  yearRanges: string;   // pre-formatted, e.g. "2019–2021, 2025"
}

export interface RunnerAwardSummaryEntry {
  categoryName: string;
  position: number;
  count: number;
}

export interface RunnerAwardSummary {
  roadGp: RunnerAwardSummaryEntry[];
  fell: RunnerAwardSummaryEntry[];
}
```

- [ ] **Step 2: Commit**

```bash
git add src/lib/types.ts
git commit -m "feat: add RunnerClubHistory and RunnerAwardSummary types"
```

---

## Task 2: Add `formatYearRanges` and unit tests

**Files:**
- Modify: `src/lib/runners.ts`
- Create: `tests/runners.test.ts`

- [ ] **Step 1: Write the failing tests**

Create `tests/runners.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { formatYearRanges } from '../src/lib/runners';

describe('formatYearRanges', () => {
  it('returns empty string for empty input', () => {
    expect(formatYearRanges([])).toBe('');
  });

  it('returns a single year as a plain number', () => {
    expect(formatYearRanges([2025])).toBe('2025');
  });

  it('collapses two consecutive years into a range', () => {
    expect(formatYearRanges([2024, 2025])).toBe('2024–2025');
  });

  it('collapses a contiguous run into a single range', () => {
    expect(formatYearRanges([2019, 2020, 2021])).toBe('2019–2021');
  });

  it('separates non-contiguous years with a comma', () => {
    expect(formatYearRanges([2022, 2025])).toBe('2022, 2025');
  });

  it('produces a range then a trailing gap year', () => {
    expect(formatYearRanges([2019, 2020, 2021, 2025])).toBe('2019–2021, 2025');
  });

  it('handles multiple isolated years', () => {
    expect(formatYearRanges([2019, 2021, 2023])).toBe('2019, 2021, 2023');
  });

  it('sorts unsorted input before processing', () => {
    expect(formatYearRanges([2025, 2019, 2020])).toBe('2019–2020, 2025');
  });
});
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
npm test
```

Expected: FAIL — "formatYearRanges is not a function" (or similar import error)

- [ ] **Step 3: Implement `formatYearRanges` in `src/lib/runners.ts`**

Add this function just before the `runnerSlug` export (around line 35). It must be exported so Vitest can import it.

```ts
export function formatYearRanges(years: number[]): string {
  if (years.length === 0) return '';
  const sorted = [...years].sort((a, b) => a - b);
  const ranges: string[] = [];
  let start = sorted[0];
  let end = sorted[0];
  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i] === end + 1) {
      end = sorted[i];
    } else {
      ranges.push(start === end ? `${start}` : `${start}–${end}`);
      start = sorted[i];
      end = sorted[i];
    }
  }
  ranges.push(start === end ? `${start}` : `${start}–${end}`);
  return ranges.join(', ');
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
npm test
```

Expected: all 8 tests PASS

- [ ] **Step 5: Commit**

```bash
git add src/lib/runners.ts tests/runners.test.ts
git commit -m "feat: add formatYearRanges with tests"
```

---

## Task 3: Update `runners.ts` and `[slug].astro` together

These two files must be updated in a single commit — `runners.ts` drops the `clubName` prop and adds `clubHistory` + `awardSummary`, and the Astro page must match.

**Files:**
- Modify: `src/lib/runners.ts`
- Modify: `src/pages/runners/[slug].astro`

- [ ] **Step 1: Update the import list in `runners.ts`**

At the top of `src/lib/runners.ts`, update the type import to include the new types:

```ts
import type {
  Club, GlobalRunner, RunnerClubHistory, RunnerAwardSummary, RunnerAwardSummaryEntry,
  RunnerProfileAward, RunnerProfileRace,
  RunnerYearBlock, RunnerYearSeries, Series, SeriesAwards, SeriesRunner,
} from './types';
```

- [ ] **Step 2: Add `buildClubHistory` to `runners.ts`**

Add this function after `resolveClubName` (around line 137):

```ts
function buildClubHistory(entries: Array<{ year: number; club: string }>): RunnerClubHistory[] {
  const clubYears = new Map<string, Set<number>>();
  for (const { year, club } of entries) {
    if (!clubYears.has(club)) clubYears.set(club, new Set());
    clubYears.get(club)!.add(year);
  }
  return [...clubYears.entries()]
    .map(([clubId, yearsSet]) => {
      const years = [...yearsSet].sort((a, b) => a - b);
      return { clubId, clubName: resolveClubName(clubId), yearRanges: formatYearRanges(years), firstYear: years[0] };
    })
    .sort((a, b) => a.firstYear - b.firstYear)
    .map(({ clubId, clubName, yearRanges }) => ({ clubId, clubName, yearRanges }));
}
```

- [ ] **Step 3: Add `buildAwardSummary` to `runners.ts`**

Add this function directly after `buildClubHistory`:

```ts
function buildAwardSummary(yearBlocks: RunnerYearBlock[]): RunnerAwardSummary {
  const roadGpCounts = new Map<string, RunnerAwardSummaryEntry>();
  const fellCounts = new Map<string, RunnerAwardSummaryEntry>();

  function tally(map: Map<string, RunnerAwardSummaryEntry>, award: RunnerProfileAward) {
    const key = `${award.categoryName}|${award.position}`;
    const entry = map.get(key) ?? { categoryName: award.categoryName, position: award.position, count: 0 };
    entry.count++;
    map.set(key, entry);
  }

  for (const block of yearBlocks) {
    for (const award of block.roadGp?.awards ?? []) tally(roadGpCounts, award);
    for (const award of block.fell?.awards ?? []) tally(fellCounts, award);
  }

  return {
    roadGp: [...roadGpCounts.values()],
    fell: [...fellCounts.values()],
  };
}
```

- [ ] **Step 4: Update `getRunnerProfileStaticPaths` to include `club` in entries and return new props**

Replace the entire `getRunnerProfileStaticPaths` function with:

```ts
export function getRunnerProfileStaticPaths() {
  const globalRunners = getGlobalRunners();
  const allSeriesFiles = { ...roadSeriesRunnerFiles, ...fellSeriesRunnerFiles };

  // Build: globalRunnerId → [{ year, series, seriesLocalId, club }]
  const globalToSeries = new Map<number, Array<{ year: number; series: Series; seriesLocalId: number; club: string }>>();
  for (const [path, fileData] of Object.entries(allSeriesFiles)) {
    const parsed = parseSeriesRunnerPath(path);
    if (!parsed) continue;
    for (const sr of fileData.default) {
      const list = globalToSeries.get(sr.runnerId) ?? [];
      list.push({ year: parsed.year, series: parsed.series, seriesLocalId: sr.id, club: sr.club });
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
    const clubHistory = buildClubHistory(entries);
    const awardSummary = buildAwardSummary(yearBlocks);

    return {
      params: { slug },
      props: { runner, clubHistory, awardSummary, yearBlocks },
    };
  });
}
```

- [ ] **Step 5: Update `src/pages/runners/[slug].astro` — frontmatter**

Replace the entire frontmatter block (lines 1–33) with:

```ts
---
import Layout from '../../components/Layout.astro';
import { getRunnerProfileStaticPaths } from '../../lib/runners';
import { siteUrl } from '../../lib/url';
import type { GlobalRunner, RunnerYearBlock, RunnerClubHistory, RunnerAwardSummary } from '../../lib/types';

export async function getStaticPaths() {
  return getRunnerProfileStaticPaths();
}

interface Props {
  runner: GlobalRunner;
  clubHistory: RunnerClubHistory[];
  awardSummary: RunnerAwardSummary;
  yearBlocks: RunnerYearBlock[];
}

const { runner, clubHistory, awardSummary, yearBlocks } = Astro.props;
const title = `${runner.firstName} ${runner.lastName}`;
const allYears = yearBlocks.map(b => b.year);
const hasAwards = awardSummary.roadGp.length + awardSummary.fell.length > 0;

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
```

- [ ] **Step 6: Update `src/pages/runners/[slug].astro` — template**

Replace the `<h1>` and subtitle paragraph, then insert the stats panel. The new markup to place after the opening `<Layout title={title}>` tag and before the `<!-- Filter bar -->` comment:

```astro
  <h1 class="text-2xl font-bold mb-1">{title}</h1>
  <p class="text-sm text-base-content/60 mb-4">
    {runner.sex === 'M' ? 'Men' : 'Women'} &middot; {runner.category}
  </p>

  <!-- Stats panel -->
  <div class={`bg-base-100 border border-base-200 rounded-lg p-4 mb-6 grid gap-6 ${hasAwards ? 'grid-cols-2' : 'grid-cols-1'}`}>
    <div>
      <h2 class="text-xs font-bold uppercase tracking-wider text-base-content/50 mb-2">Competed for</h2>
      {clubHistory.map(ch => (
        <div class="flex justify-between gap-4 text-sm mb-1">
          <span class="font-medium">{ch.clubName}</span>
          <span class="text-base-content/60">{ch.yearRanges}</span>
        </div>
      ))}
    </div>
    {hasAwards && (
      <div>
        <h2 class="text-xs font-bold uppercase tracking-wider text-base-content/50 mb-2">Awards</h2>
        {awardSummary.roadGp.length > 0 && (
          <div class="mb-3">
            <div class="text-xs font-bold uppercase tracking-wider text-base-content/40 mb-1">Road GP</div>
            {awardSummary.roadGp.map(a => (
              <div class="text-sm">{a.categoryName} &mdash; {positionLabel(a.position)}{a.count > 1 ? ` ×${a.count}` : ''}</div>
            ))}
          </div>
        )}
        {awardSummary.fell.length > 0 && (
          <div>
            <div class="text-xs font-bold uppercase tracking-wider text-base-content/40 mb-1">Fell</div>
            {awardSummary.fell.map(a => (
              <div class="text-sm">{a.categoryName} &mdash; {positionLabel(a.position)}{a.count > 1 ? ` ×${a.count}` : ''}</div>
            ))}
          </div>
        )}
      </div>
    )}
  </div>
```

- [ ] **Step 7: Verify the build passes**

```bash
npm run build
```

Expected: build completes with no TypeScript errors. Fix any type errors before committing.

- [ ] **Step 8: Commit**

```bash
git add src/lib/runners.ts src/pages/runners/[slug].astro
git commit -m "feat: add runner profile summary panel with club history and awards"
```
