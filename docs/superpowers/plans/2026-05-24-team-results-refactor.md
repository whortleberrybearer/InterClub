# Team Results Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract a `TeamClubCard` component to eliminate duplicated card markup in `TeamResultsLayout`, and add `getSeriesLabel`/`getSeriesLongLabel` helpers to `format.ts` to replace inline ternaries across three layout components.

**Architecture:** Two independent changes — a pure-function utility added to an existing module (with tests), and a new markup-only Astro component (verified by build). No behaviour changes; this is a structural refactor.

**Tech Stack:** Astro v6, TypeScript (strict), Vitest, Tailwind CSS v4

---

## File Map

| Action | File |
|--------|------|
| Modify | `src/lib/format.ts` |
| Modify | `tests/lib/format.test.ts` |
| Create | `src/components/TeamClubCard.astro` |
| Modify | `src/components/TeamResultsLayout.astro` |
| Modify | `src/components/TeamStandingsLayout.astro` |
| Modify | `src/components/IndividualStandingsLayout.astro` |

---

## Task 1: Add `getSeriesLabel` / `getSeriesLongLabel` to `format.ts` (TDD)

**Files:**
- Modify: `tests/lib/format.test.ts`
- Modify: `src/lib/format.ts`

- [ ] **Step 1: Add failing tests**

Append to `tests/lib/format.test.ts`:

```ts
import { describe, it, expect } from 'vitest';
import { formatRaceDate, getSeriesLabel, getSeriesLongLabel } from '../../src/lib/format';

// ... existing formatRaceDate tests unchanged ...

describe('getSeriesLabel', () => {
  it('returns short label for road-gp', () => {
    expect(getSeriesLabel('road-gp')).toBe('Road GP');
  });
  it('returns short label for fell', () => {
    expect(getSeriesLabel('fell')).toBe('Fell Championship');
  });
});

describe('getSeriesLongLabel', () => {
  it('returns long label for road-gp', () => {
    expect(getSeriesLongLabel('road-gp')).toBe('Road Grand Prix');
  });
  it('returns long label for fell', () => {
    expect(getSeriesLongLabel('fell')).toBe('Fell Championship');
  });
});
```

- [ ] **Step 2: Run tests — expect failures**

```bash
npm test
```

Expected: 4 new failures — `getSeriesLabel is not a function`, `getSeriesLongLabel is not a function`.

- [ ] **Step 3: Implement the functions**

In `src/lib/format.ts`, add after the existing `formatRaceDate` function:

```ts
import type { Series } from './types';

export function getSeriesLabel(series: Series): string {
  return series === 'road-gp' ? 'Road GP' : 'Fell Championship';
}

export function getSeriesLongLabel(series: Series): string {
  return series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
}
```

> Note: `format.ts` currently has no imports. Add the `import type { Series }` line at the top of the file.

- [ ] **Step 4: Run tests — expect all pass**

```bash
npm test
```

Expected: all tests pass including the 4 new ones.

- [ ] **Step 5: Commit**

```bash
git add src/lib/format.ts tests/lib/format.test.ts
git commit -m "feat: add getSeriesLabel and getSeriesLongLabel helpers to format.ts"
```

---

## Task 2: Use `getSeriesLabel` / `getSeriesLongLabel` in layout components

**Files:**
- Modify: `src/components/TeamResultsLayout.astro`
- Modify: `src/components/TeamStandingsLayout.astro`
- Modify: `src/components/IndividualStandingsLayout.astro`

### TeamResultsLayout.astro

- [ ] **Step 1: Replace inline ternaries**

In the frontmatter of `src/components/TeamResultsLayout.astro`, replace:

```ts
import { getRace } from '../lib/data';
import { siteUrl } from '../lib/url';
import type { Club, Series, SeriesConfig, TeamResults } from '../lib/types';
```

with:

```ts
import { getRace } from '../lib/data';
import { siteUrl } from '../lib/url';
import { getSeriesLabel, getSeriesLongLabel } from '../lib/format';
import type { Club, Series, SeriesConfig, TeamResults } from '../lib/types';
```

Then replace:

```ts
const seriesLabel = series === 'road-gp' ? 'Road GP' : 'Fell Championship';
const seriesLong  = series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
```

with:

```ts
const seriesLabel = getSeriesLabel(series);
const seriesLong  = getSeriesLongLabel(series);
```

### TeamStandingsLayout.astro

- [ ] **Step 2: Replace inline ternaries**

In the frontmatter of `src/components/TeamStandingsLayout.astro`, add the import (it already imports from `../lib/data` and `../lib/url`):

```ts
import { getSeriesLabel, getSeriesLongLabel } from '../lib/format';
```

Then replace:

```ts
const seriesLabel = series === 'road-gp' ? 'Road GP' : 'Fell Championship';
const seriesLong  = series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
```

with:

```ts
const seriesLabel = getSeriesLabel(series);
const seriesLong  = getSeriesLongLabel(series);
```

### IndividualStandingsLayout.astro

- [ ] **Step 3: Replace inline ternary**

In `src/components/IndividualStandingsLayout.astro`, add the import after line 24 (`import { siteUrl } from '../lib/url';`):

```ts
import { getSeriesLongLabel } from '../lib/format';
```

Replace line 38:

```ts
const seriesLabel = series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
```

with:

```ts
const seriesLong = getSeriesLongLabel(series);
```

Then update the two template references. Replace:

```astro
<Layout title={`${seriesLabel} ${year} — Individual Standings`}>
```

with:

```astro
<Layout title={`${seriesLong} ${year} — Individual Standings`}>
```

And replace:

```astro
<p class="text-sm text-muted mt-2">{year} Inter Club {seriesLabel}</p>
```

with:

```astro
<p class="text-sm text-muted mt-2">{year} Inter Club {seriesLong}</p>
```

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

Expected: `1314 page(s) built` with no errors.

- [ ] **Step 5: Commit**

```bash
git add src/components/TeamResultsLayout.astro src/components/TeamStandingsLayout.astro src/components/IndividualStandingsLayout.astro
git commit -m "refactor: use getSeriesLabel/getSeriesLongLabel in layout components"
```

---

## Task 3: Create `TeamClubCard.astro`

**Files:**
- Create: `src/components/TeamClubCard.astro`

- [ ] **Step 1: Create the component**

Create `src/components/TeamClubCard.astro` with this content:

```astro
---
// src/components/TeamClubCard.astro
//
// Markup shell for a collapsible team club card used by TeamResultsLayout.
// No <script> block — TeamResultsLayout owns all accordion and sync logic.
//
// Two variants:
//   desktop — auto-fill scorer grid, slightly larger club name font
//   mobile  — 2/3-col scorer grid, slightly smaller club name font
import type { TeamScorer } from '../lib/types';

interface Props {
  detailId: string;
  position: number;
  clubName: string;
  total: number;
  scorers: TeamScorer[];
  /** Required scorer count from catConfig; drives the incomplete-team warning. */
  scorerCount?: number;
  runnerUrlMap: Record<number, string>;
  variant: 'desktop' | 'mobile';
}

const { detailId, position, clubName, total, scorers, scorerCount, runnerUrlMap, variant } = Astro.props;
const isDesktop = variant === 'desktop';
---

<div class="bg-surface border border-line rounded-xl mb-2 overflow-hidden">
  <button
    class="accordion-toggle w-full flex items-center gap-3 py-3 pl-3 pr-3 text-left hover:bg-canvas/50 transition-colors"
    data-target={detailId}
    aria-expanded="false"
  >
    <span class="font-mono text-sm font-medium text-muted w-6 shrink-0 text-center tabular-nums">
      {position}
    </span>
    <div class="flex-1 min-w-0">
      <div class:list={[
        'font-head font-bold tracking-[-0.01em] leading-[1.15] truncate',
        isDesktop ? 'text-[17px]' : 'text-[16px]',
      ]}>{clubName}</div>
    </div>
    <div class="text-right shrink-0 flex flex-col items-end justify-center min-h-10">
      <div class="font-mono text-[22px] font-medium leading-none tabular-nums">{total}</div>
      {scorerCount != null && scorers.length < scorerCount && (
        <div class="font-mono text-[10px] text-muted mt-0.5 tabular-nums">
          {scorers.length} scorer{scorers.length !== 1 ? 's' : ''}
        </div>
      )}
    </div>
    <span class="chevron text-content/30 text-xs transition-transform shrink-0">▾</span>
  </button>
  <div id={detailId} class="hidden border-t border-dashed border-line">
    {isDesktop ? (
      <div class="grid gap-x-3 gap-y-0.5 p-3"
           style="grid-template-columns: repeat(auto-fill, minmax(140px, 1fr))">
        {scorers.map(scorer => {
          const url = scorer.seriesRunnerId != null ? runnerUrlMap[scorer.seriesRunnerId] : undefined;
          return (
            <div class="flex items-baseline gap-1.5 py-[3px] min-w-0">
              <span class="font-mono text-[11px] text-muted w-[22px] text-right shrink-0 tabular-nums">{scorer.position}</span>
              {url
                ? <a href={url} class="text-[12.5px] flex-1 min-w-0 truncate link link-hover">{scorer.name || '–'}</a>
                : <span class="text-[12.5px] flex-1 min-w-0 truncate">{scorer.name || '–'}</span>
              }
            </div>
          );
        })}
      </div>
    ) : (
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-x-3 gap-y-0.5 p-3">
        {scorers.map(scorer => {
          const url = scorer.seriesRunnerId != null ? runnerUrlMap[scorer.seriesRunnerId] : undefined;
          return (
            <div class="flex items-baseline gap-1.5 py-[3px] min-w-0">
              <span class="font-mono text-[10px] text-muted w-5 text-right shrink-0 tabular-nums">{scorer.position}</span>
              {url
                ? <a href={url} class="text-xs flex-1 min-w-0 truncate link link-hover">{scorer.name || '–'}</a>
                : <span class="text-xs flex-1 min-w-0 truncate">{scorer.name || '–'}</span>
              }
            </div>
          );
        })}
      </div>
    )}
  </div>
</div>
```

- [ ] **Step 2: Verify build passes with new file (not yet used)**

```bash
npm run build
```

Expected: same page count, no errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/TeamClubCard.astro
git commit -m "feat: add TeamClubCard component (markup shell, no script)"
```

---

## Task 4: Use `TeamClubCard` in `TeamResultsLayout`

**Files:**
- Modify: `src/components/TeamResultsLayout.astro`

- [ ] **Step 1: Add import**

In the frontmatter of `src/components/TeamResultsLayout.astro`, add:

```ts
import TeamClubCard from './TeamClubCard.astro';
```

- [ ] **Step 2: Replace desktop card block**

In the desktop section (`hidden lg:grid`), find the comment `<!-- Collapsible team cards (desktop, single column) -->` and replace the entire `{cat.clubs.map(...)}` block that follows it with:

```astro
<!-- Collapsible team cards (desktop, single column) -->
{cat.clubs.map(clubResult => (
  <TeamClubCard
    detailId={`dt-detail-${i}-${clubResult.club}`}
    position={clubResult.position}
    clubName={clubById[clubResult.club]?.name ?? clubResult.club}
    total={clubResult.total}
    scorers={clubResult.scorers}
    scorerCount={catConfig?.scorerCount}
    runnerUrlMap={runnerUrlMap}
    variant="desktop"
  />
))}
```

- [ ] **Step 3: Replace mobile/tablet card block**

In the mobile/tablet section (`lg:hidden`), find the comment `<!-- Cards: full-width single column at all mobile/tablet sizes -->` and replace the `<div>` and its `{cat.clubs.map(...)}` content with:

```astro
<!-- Cards: full-width single column at all mobile/tablet sizes -->
<div>
  {cat.clubs.map(clubResult => (
    <TeamClubCard
      detailId={`mb-detail-${i}-${clubResult.club}`}
      position={clubResult.position}
      clubName={clubById[clubResult.club]?.name ?? clubResult.club}
      total={clubResult.total}
      scorers={clubResult.scorers}
      scorerCount={catConfig?.scorerCount}
      runnerUrlMap={runnerUrlMap}
      variant="mobile"
    />
  ))}
</div>
```

- [ ] **Step 4: Verify build passes**

```bash
npm run build
```

Expected: `1314 page(s) built` with no errors.

- [ ] **Step 5: Verify tests still pass**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 6: Commit and push**

```bash
git add src/components/TeamResultsLayout.astro
git commit -m "refactor: replace duplicated card markup with TeamClubCard component"
git push
```
