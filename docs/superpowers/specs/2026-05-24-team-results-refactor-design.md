# Team Results Refactor — Design Spec
_2026-05-24_

## Scope

Three targeted improvements to reduce duplication introduced when `TeamResultsLayout.astro` was built:

1. Extract `TeamClubCard.astro` — eliminate ~80 lines of duplicated card markup
2. Add `getSeriesLabel` / `getSeriesLongLabel` to `format.ts` — remove inline ternaries across layout components

Item skipped: shared category-nav JS module (deferred).
Item deferred: individual results page hero refactor (out of scope).

---

## 1. `TeamClubCard.astro`

### Problem
`TeamResultsLayout` contains two near-identical blocks of card markup — one for the desktop pane (`dt-detail-*` IDs) and one for the mobile/tablet pane (`mb-detail-*` IDs). Both must always be in the DOM so the cross-view accordion sync can mirror state. The only differences are:
- ID prefix (`dt-detail-` vs `mb-detail-`)
- Club name font size (`text-[17px]` vs `text-[16px]`)
- Scorer grid: `repeat(auto-fill, minmax(140px, 1fr))` inline style (desktop) vs `grid-cols-2 sm:grid-cols-3` (mobile)

### Solution
New `src/components/TeamClubCard.astro` component.

**Props:**
```ts
interface Props {
  detailId: string;
  position: number;
  clubName: string;
  total: number;
  scorers: TeamScorer[];
  scorerCount?: number;          // from catConfig; drives the incomplete-team warning
  runnerUrlMap: Record<number, string>;
  variant: 'desktop' | 'mobile';
}
```

**No `<script>` block.** `TeamResultsLayout` owns all accordion logic (the cross-view sync requires a single handler). This is intentional — the component is a pure markup shell.

**Variant differences** handled with prop-driven ternaries inside the component:
- `variant === 'desktop'`: club name `text-[17px]`, scorer grid via inline `style`
- `variant === 'mobile'`: club name `text-[16px]`, scorer grid via `grid-cols-2 sm:grid-cols-3`

**Usage in `TeamResultsLayout`:**
```astro
<!-- Desktop -->
<TeamClubCard
  detailId={`dt-detail-${i}-${clubResult.club}`}
  variant="desktop"
  {position} {clubName} {total} {scorers} {scorerCount} {runnerUrlMap}
/>

<!-- Mobile/tablet -->
<TeamClubCard
  detailId={`mb-detail-${i}-${clubResult.club}`}
  variant="mobile"
  {position} {clubName} {total} {scorers} {scorerCount} {runnerUrlMap}
/>
```

`MobileAccordionCard` is **not changed** — it remains the component for standings pages and retains its own script.

---

## 2. `getSeriesLabel` / `getSeriesLongLabel` in `format.ts`

### Problem
Three layout components and at least one page compute series display names inline:
```ts
const seriesLabel = series === 'road-gp' ? 'Road GP' : 'Fell Championship';
const seriesLong  = series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
```

### Solution
Add to `src/lib/format.ts`:
```ts
export function getSeriesLabel(series: Series): string {
  return series === 'road-gp' ? 'Road GP' : 'Fell Championship';
}

export function getSeriesLongLabel(series: Series): string {
  return series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
}
```

**Files updated** (replace inline ternaries with function calls):
- `src/components/TeamResultsLayout.astro`
- `src/components/TeamStandingsLayout.astro`
- `src/components/IndividualStandingsLayout.astro`
- `src/pages/road-gp/[year]/[raceId].astro` (if it uses the computed form)

Static pages that hardcode `'Road GP'` or `'Fell Championship'` as literals are **not touched**.

---

## Non-goals

- No changes to `MobileAccordionCard`, `ChipBar`, or `TeamStandingsLayout` accordion/category logic
- No changes to the individual results page hero (deferred to a later refactor)
- No new shared category-nav JS module (skipped)
