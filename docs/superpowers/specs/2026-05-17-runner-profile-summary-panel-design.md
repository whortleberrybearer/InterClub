# Runner Profile — Summary Panel

**Date:** 2026-05-17  
**Status:** Approved

## Goal

Add a stats panel to the runner profile page (`src/pages/runners/[slug].astro`) that surfaces two pieces of information currently buried in the year-by-year timeline:

1. **Club history with year ranges** — which clubs the runner competed for, and in which years (with gap handling).
2. **Awards summary** — a compact count of championship awards won, grouped by series and category.

## What the Page Looks Like Today

The runner profile page shows:
- Runner name (h1)
- Single subtitle line: `{club} · {sex} · {category}` — all sourced from the global `runners.json` (one static snapshot)
- Filter bar (series / year / race dropdowns)
- Year blocks: one per year the runner competed, each containing Road GP and/or Fell race tables with date, race name, and time; inline trophy awards per year

## Design

### Stats Panel

A card inserted **between the runner name/subtitle and the filter bar**. Two columns:

| Left | Right |
|------|-------|
| Competed for (clubs + years) | Awards summary |

The right column (Awards) is **omitted entirely** when the runner has no awards — the panel collapses to a single full-width column for club history.

### Left Column — Competed For

One row per distinct club the runner has competed for across all years and both series. Each row shows:

```
Club Name   YYYY, YYYY–YYYY
```

Year ranges are derived from the union of years the runner appears in any series runner file under that club. Contiguous years collapse to a range (`2019–2022`); gaps are listed separately (`2019–2022, 2025`). A single year shows as a plain year (`2025`).

If the runner has competed for only one club, a single row is shown. The existing global-registry club in the subtitle line is **removed** (the panel replaces it — the subtitle becomes `{sex} · {category}` only, avoiding duplication).

### Right Column — Awards Summary

Grouped by series (Road GP then Fell), then by category name + position:

```
ROAD GP
Senior Men — 1st  ×3
V40 Men — 3rd  ×1

FELL
Senior Men — 2nd  ×1
```

The `×N` count appears when N > 1; a single award shows without a count suffix. Position is the ordinal from `awards.json` (`position: 1` → "1st", etc.). Category name is resolved from `individualCategories[].name` in the series config.

Each series subsection (`ROAD GP` / `FELL`) only renders if that series has at least one award entry — a runner with only Road GP awards sees no Fell heading.

Full award details (year, link to series page) remain in the existing per-year trophy links within the year blocks — the summary panel is counts only.

## Data Requirements

### Club history per runner

**Source:** series runner files `src/data/{year}/{series}/runners.json` — each entry has a `club` field.

**Logic in `getRunnerProfileStaticPaths`:**
- For each global runner, collect `{ year, club }` pairs from all series runner entries (both road-gp and fell).
- Deduplicate by `(year, club)` — a runner in both series in the same year for the same club counts once.
- Group by `club`.
- For each club, sort years and compute contiguous ranges.

A helper `formatYearRanges(years: number[]): string` converts a sorted array of years to a human-readable string with gap handling (e.g. `[2019,2020,2021,2025]` → `"2019–2021, 2025"`).

**New type additions to `src/lib/types.ts`:**

```ts
export interface RunnerClubHistory {
  clubId: string;
  clubName: string;
  yearRanges: string;   // pre-formatted, e.g. "2019–2021, 2025"
}
```

### Awards summary

**Source:** already aggregated per year in `RunnerYearBlock` via `getAwardsForRunner`. The existing `RunnerProfileAward` has `{ categoryName, position }`.

**Logic:** Lift award aggregation to the profile level — group across all year blocks by `(series, categoryName, position)` and count occurrences.

**New type additions:**

```ts
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

### Props change

`getRunnerProfileStaticPaths` adds two new props:

```ts
interface Props {
  runner: GlobalRunner;
  // clubName: string;       ← removed (replaced by clubHistory)
  clubHistory: RunnerClubHistory[];
  awardSummary: RunnerAwardSummary;
  yearBlocks: RunnerYearBlock[];
}
```

`resolveClubName` is still needed internally (used by `clubHistory` construction), but the top-level `clubName` prop is dropped.

## Rendering

In `[slug].astro`:

- Subtitle line changes from `{clubName} · {sex} · {category}` to `{sex} · {category}`.
- Stats panel renders after the subtitle and before the filter bar.
- Panel uses `bg-base-100 border border-base-200 rounded-lg p-4 mb-6 grid gap-6` with `grid-cols-2` when `awardSummary.roadGp.length + awardSummary.fell.length > 0`, otherwise `grid-cols-1`.
- Year ranges use the `text-base-content/60` muted style for readability.
- Awards section headings (`ROAD GP`, `FELL`) use the existing `text-xs font-bold uppercase tracking-wider text-base-content/50` pattern already on the page.
- `positionLabel()` (already defined in the page) formats award positions.

## What Does Not Change

- The filter bar and its client-side JS — no changes.
- The year block structure and race tables — no changes.
- The per-year inline trophy award links — kept as-is; the summary panel complements them rather than replacing them.
- `RunnerYearSeries.awards` — still populated and still rendered per-year.

## Out of Scope

- Race position/IC position columns in the race table (separate feature).
- Category progression display.
- Race count totals.
