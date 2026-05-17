# Individual History Page Redesign

**Date:** 2026-05-17  
**Series:** Road GP and Fell Championship  
**Page:** `/road-gp/history/individuals` and `/fell/history/individuals`

## Problem

The current individual history page groups award winners by year (one card per year). This makes it hard to compare who won a specific category across different years — you have to scroll through every year card and mentally filter. The team history page (`/road-gp/history/teams`) solves this well with a table where years are rows and categories are columns.

## Goal

Redesign the individual history page to use the same year-as-rows pattern, making it easy to see "who won Senior Men each year" at a glance.

## Design

### Data Shape

The page (`[type].astro`) pivots the existing year-keyed data into a category-first structure before passing it to the component:

```ts
interface CategoryHistoryData {
  id: string;
  name: string;
  sex: 'M' | 'F' | null;  // from config.individualCategories[].sex; null = Overall
  rows: Array<{
    year: number;
    positions: {
      1: { name: string; clubName: string; runnerUrl?: string } | null;
      2: { name: string; clubName: string; runnerUrl?: string } | null;
      3: { name: string; clubName: string; runnerUrl?: string } | null;
    };
  }>;
}
```

- All categories across all years are included (union of all `individualCategories` from all yearly configs)
- `rows` only includes years that have at least one award entry for that category (years with no entry are omitted entirely)
- `rows` are ordered newest year first
- Positions 1, 2, 3 are fixed columns — not derived from data. If a position wasn't awarded in a given year, the value is `null` (renders as `—`)

### Tab Structure

Two-level tab navigation:

**Top-level tabs:** Male | Female | Overall  
Derived from the `sex` field on `individualCategories`:
- `"M"` → Male tab
- `"F"` → Female tab  
- `null` / absent → Overall tab
- Tabs are only rendered if at least one category belongs to that group

**Sub-tabs:** One tab per category within the active top-level group  
(e.g. Male → Overall, Senior, V40, V45, V50, V55, V60, V65, V70, V75)

Tab state managed by a small inline `<script>` (plain JS, class toggling). DaisyUI radio-based tabs don't compose cleanly across two levels. The first top tab and its first sub-tab are active on page load.

### Table

Each category panel renders a table:

| Year | 1st | 2nd | 3rd |
|------|-----|-----|-----|
| 2025 | L. Minns (Blackpool) | R. Danson (Preston) | S. Evans (Preston) |
| 2024 | … | … | — |

- Columns: Year (left-aligned, bold), 1st, 2nd, 3rd (fixed headings)
- Cell content: "Name (Club)" — runner name links to profile page when `runnerUrl` is available
- Missing position: `—`
- Years with no award entry for this category are omitted from the table entirely
- Matches the visual style of `AwardsHistoryTeams` (DaisyUI `table table-sm`, `hover` rows)

## Files Changed

### Modified
- `src/components/AwardsHistoryIndividuals.astro` — replace card-per-year layout with tabbed table layout; new props interface using `CategoryHistoryData[]`
- `src/pages/road-gp/history/[type].astro` — pivot individual data from year-keyed to category-keyed before passing to component
- `src/pages/fell/history/[type].astro` — same pivot as road-gp

### No changes needed
- `AwardsHistoryTeams.astro` — unchanged
- Data files (`awards.json`, `config.json`) — unchanged
- `results.ts` / `runners.ts` — unchanged

## Edge Cases

- **Category appears in only one year:** Still gets a tab and a single-row table
- **No awards for a series:** Page renders with empty state (existing behaviour)
- **Top-level group has no categories:** That top tab is not rendered
- **Position 4+ in awards data:** Ignored — only positions 1, 2, 3 are shown
