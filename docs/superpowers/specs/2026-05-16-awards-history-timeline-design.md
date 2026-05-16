# Awards History Timeline Design

**Date:** 2026-05-16  
**Status:** Approved

## Overview

Add dedicated history pages showing award winners across all years for each series (Road GP and Fell Championship). This allows users to see the evolution of winners over time without navigating to individual year pages, particularly useful for years with minimal data (trophy-only winners).

## Pages & Routes

Create four new pages:
- `/road-gp/history/teams` — Team award winners (tabular)
- `/road-gp/history/individuals` — Individual award winners (chronological cards)
- `/fell/history/teams` — Team award winners (tabular)
- `/fell/history/individuals` — Individual award winners (chronological cards)

Implementation: Dynamic pages using `[series]` and `[type]` route parameters in `src/pages/history/[series]/[type].astro`

## Teams History Page

**Layout:** Tabular with years as rows, team categories as columns.

**Structure:**
- Year column on the left: displayed prominently, descending order (newest first)
- One column per team category from `config.teamCategories`
- Column headers: category name from config
- Each cell: winning club name, or "—" if no awards data exists for that year/category
- All years with awards data are shown; years with no awards file are skipped entirely

**Data Source:**
- Load all `src/data/{year}/{series}/awards.json` files for the series
- Extract `teamAwards` array
- Build a matrix: `year × teamCategory → winningClubName`
- Resolve club names from `clubs.json`

**Edge Cases:**
- Year has no awards file: skip the year entirely
- Year has awards file but no team awards: row still appears but cells show "—"
- Team category doesn't exist in a year's config: show "—"

**Sorting:** Years in descending order (newest first, 2026 at top)

## Individuals History Page

**Layout:** Chronological year cards in reverse chronological order.

**Card Structure (per year):**
- Year header displayed prominently (e.g., "2025")
- All award categories from that year's `individualAwards` array
- For each category:
  - Category name as a subheading (e.g., "Senior Men")
  - All placed finishers (1st, 2nd, 3rd, etc.) listed as rows
  - Each row shows:
    - Position badge: medal emoji (🥇 for 1st, 🥈 for 2nd, 🥉 for 3rd, ordinal number for 4th+)
    - Runner name (bold)
    - Club (in smaller text/muted color)
    - Age category if available (e.g., "SEN", "V40")
    - Link to runner profile if `seriesRunnerId` exists in awards data

**Data Source:**
- Load all `src/data/{year}/{series}/awards.json` files
- Extract `individualAwards` array
- Sort years descending (newest first)
- Resolve club names from `clubs.json`
- Build runner profile links using `getRunnerProfileUrl()` where `seriesRunnerId` is present

**Styling/Components:**
- Reuse or adapt `SeriesAwards.astro` component logic for rendering awards
- Each year is a distinct card with visual separation (border, background, spacing)
- Categories within a year are grouped visually
- Responsive: stack on mobile, consider two-column layout on larger screens if needed

**Edge Cases:**
- Year has no awards file: skip the year entirely
- Year has awards file but no individual awards: year card still appears but shows "No individual awards"
- Runner has no `seriesRunnerId`: name displays without profile link
- Sparse positions (e.g., only 1st place awarded in a category): show only those positions

**Sorting:** Years in descending order (newest first, 2026 at top); categories in order they appear in awards JSON (which matches `config.individualCategories` order)

## Navigation

**Entry Points:**
- Add links on series index pages (e.g., `/road-gp/[year]/index.astro`) to `/road-gp/history/individuals` and `/road-gp/history/teams`
- Optional: Add "View all winners" link on current-year series pages
- Optional: Add to main navigation or footer

**Implementation:** Add navigation UI (buttons or text links) to existing components or index pages

## Data Loading

**Build-Time:**
- Use `import.meta.glob()` at module level to load all awards files
- Pattern: `src/data/*/road-gp/awards.json` and `src/data/*/fell/awards.json`
- Load as JSON with `{ eager: true }`
- Extract and normalize data at component render time

**No Runtime Fetching:** All data is static and resolved at build time (Astro static generation)

## Implementation Details

### New Components

**`AwardsHistoryTeams.astro`**
- Props: `series: 'road-gp' | 'fell'`, `allAwards: AwardsData[]`
- Renders tabular team awards history
- Resolves club names and category names
- Handles missing data gracefully

**`AwardsHistoryIndividuals.astro`**
- Props: `series: 'road-gp' | 'fell'`, `allAwards: AwardsData[]`
- Renders year cards with individual awards
- Renders each award with position badge, name, club, category
- Links to runner profiles where available
- Handles missing data gracefully

### New Page

**`src/pages/history/[series]/[type].astro`**
- Dynamic page with two route parameters: `series` and `type`
- Valid combinations:
  - `series`: 'road-gp', 'fell'
  - `type`: 'teams', 'individuals'
- Loads all relevant awards files via glob
- Passes data to appropriate component (`AwardsHistoryTeams` or `AwardsHistoryIndividuals`)
- Generates all four pages at build time

**Static Paths:** `getStaticPaths()` returns:
```
[
  { params: { series: 'road-gp', type: 'teams' } },
  { params: { series: 'road-gp', type: 'individuals' } },
  { params: { series: 'fell', type: 'teams' } },
  { params: { series: 'fell', type: 'individuals' } },
]
```

### Type Definitions

Extend `src/lib/types.ts` if needed:
- `SeriesAwardsHistory` — array of yearly awards by series
- Reuse existing `TeamAward`, `IndividualAward`, `ResolvedSeriesAwards` types

### Styling

- Use existing Tailwind + DaisyUI components
- Tables: `table` with DaisyUI table styling
- Cards: `card` component with `bg-base-200` or similar
- Year headers: large, clear typography
- Position badges: emoji + text (reuse `positionLabel()` logic from `SeriesAwards.astro`)
- Responsive: cards stack on mobile; table may scroll horizontally on small screens

## Testing

**Manual Testing:**
- Verify both series pages load correctly
- Check all four routes generate (road-gp teams, road-gp individuals, fell teams, fell individuals)
- Confirm years are sorted descending (newest first)
- Verify missing awards data is handled gracefully (skipped or shown as "—")
- Test runner profile links (click a winner with `seriesRunnerId`)
- Test responsive layout on mobile, tablet, desktop

**No Unit Tests:** Data loading depends on `import.meta.glob()`, so validation happens at build time.

## Success Criteria

- ✅ Four new history pages are generated and accessible
- ✅ Teams history shows winners in tabular format
- ✅ Individuals history shows winners in chronological year cards
- ✅ All years with awards data are included; years without are skipped
- ✅ Runner profile links work where `seriesRunnerId` is present
- ✅ Navigation links added to series pages
- ✅ Pages are responsive and render correctly on all device sizes
- ✅ Build completes without errors

## Open Questions / Future Enhancements

- Should there be a searchable runner lookup on individuals history? (Deferred)
- Should years with no data show a placeholder or be skipped? (Decided: skip entirely)
- Should team winners show runner names (who competed for the team)? (Deferred)
