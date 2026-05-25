# Series Detail Layout — Design Spec

_2026-05-25_

## Overview

Redesign the series index pages (`road-gp/index.astro`, `fell/index.astro`) to match the `series-details.jsx` prototype from the Claude Design handoff bundle. The new design replaces the current plain stacked-card layout with a responsive, editorially-styled page that includes a series header hero, a race schedule table with live states, a 2×2 info card grid, an archive picker, and a sticky desktop sidebar.

## Component

**`src/components/SeriesDetailLayout.astro`** — new shared layout used by both series pages. Pattern matches the existing `TeamStandingsLayout` / `IndividualResultsLayout` convention.

### Props

```ts
export interface Props {
  series: Series;
  year: number;
  races: Race[];
  config: SeriesConfig;
  availableYears: number[];
  seriesTitle: string;               // "Road Grand Prix" | "Fell Championship"
  subtitle: string;                  // "7 races · April – September · Lancashire"
  teamStandingsUrl?: string;
  individualStandingsUrl?: string;
}
```

### Slots

| Slot | Content |
|---|---|
| `description` | Intro paragraph(s) — series-specific HTML, may include a callout block |
| `rules` | `<li>` elements for the Key Rules section |
| `individual-awards` | One paragraph describing individual award scoring |

Team scoring rules are identical for both series and are hardcoded inside the component.

## Responsive Layout

### Hero section (`hero` slot — full-width `bg-surface` band)

**Mobile / tablet (`lg:hidden`):**
- Row: `{year} Season` amber label · big title · `subtitle` in mono — with "Past seasons" dashed button (details/summary popover) floated right
- Row below: Standings buttons (`btn-primary` + amber-outline) — only shown when URLs are provided

**Desktop (`hidden lg:block`):**
- Eyebrow: `{year} Season` amber · separator line · `Round N of M next` mono
- Title at 52px Barlow Condensed extrabold
- Below title: description (left, max 600px) alongside standings buttons (right, flex-shrink-0)

### Main content (default slot, within `max-w-4xl`)

**Mobile / tablet only:** description section rendered here (hidden on desktop, where it lives in the hero).

**Desktop two-column grid** `lg:grid-cols-[1fr_220px] gap-8 items-start`:

#### Main column

1. **Schedule card** (`card overflow-hidden`) — full-width table with:
   - Header row: `{pastCount} of {races.length} run` mono count
   - Columns (responsive): `#` (hidden mobile) · Date · Race name · Location (hidden mobile, omitted when not set) · Results
   - Row states:
     - **Past** — `opacity-70`
     - **Next** — `bg-amber-bg`; "Next" chip (`badge badge-warning`); "Provisional" chip when applicable
     - **Upcoming** — default
   - Results cell: `Results →` (amber) + `Team →` (muted) links; `—` mono for races without results

2. **2×2 info card grid** (`grid md:grid-cols-2 gap-5 mt-5`):
   - **Key Rules** — `<slot name="rules" />` in a bulleted list with amber dot markers
   - **Team Categories** — table from `config.teamCategories`; columns: Category / Scorers / Eligibility (when `eligibility` field present)
   - **Team Scoring** — hardcoded four-point list with `›` mono prefix markers
   - **Individual Awards** — `<slot name="individual-awards" />`

#### Sidebar (desktop only, `hidden lg:block sticky top-6`)

- **"The Archive"** card (`card p-5`):
  - Header: `THE ARCHIVE` label + `Past seasons` title + one-line description
  - Decade groups: 2020s, 2010s, 2000s, 1990s, 1985–89 (each filtered to only show groups with data)
  - Each year: 2-char link (e.g. `'26`) in a `grid-cols-4` mono grid, `bg-canvas` pill, amber on hover
- **Founded note** — dashed border card: "Series founded {oldestYear}. {N} seasons of results."

#### Recent seasons strip (mobile / tablet only, `lg:hidden`)

- `border-t border-line` separator
- Row: `RECENT SEASONS` label + `Full archive ({oldestYear}–{mostRecentPastYear}) →` amber link
- `grid-cols-4` of year cards showing last 4 past years with "Last season" / "N yr ago" sub-label

## Data Changes

### `src/lib/types.ts`

Add optional `eligibility` field to `TeamCategory`:

```ts
export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
  eligibility?: string;   // e.g. "All finishers", "Women", "Men & Women 40+"
}
```

### `src/lib/results.ts`

Add `isResultsProvisional(year, series, raceId)` — checks file keys only, no CSV parsing:

```ts
export function isResultsProvisional(year: number, series: Series, raceId: string): boolean {
  const files = csvFilesForSeries(series);
  const hasFinal = Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}.csv`) && !k.includes('-provisional')
  );
  return !hasFinal && Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}-provisional.csv`)
  );
}
```

### `src/data/2026/road-gp/config.json`

Add `eligibility` to each team category entry:

```json
{ "id": "open",   "name": "Open",    "scorerCount": 10, "eligibility": "All finishers" },
{ "id": "ladies", "name": "Ladies",  "scorerCount": 5,  "eligibility": "Women" },
{ "id": "fv40",   "name": "FV40",    "scorerCount": 5,  "eligibility": "Women 40+" },
{ "id": "vets",   "name": "Vets",    "scorerCount": 6,  "eligibility": "Men 40+, Women 35+" },
{ "id": "vet50s", "name": "Vet 50s", "scorerCount": 4,  "eligibility": "Men & Women 50+" },
{ "id": "vet60s", "name": "Vet 60s", "scorerCount": 3,  "eligibility": "Men & Women 60+" }
```

### `src/data/2026/fell/config.json`

Add `eligibility` to Fell's three team categories:

```json
{ "id": "open",   "name": "Open",   "scorerCount": 6, "eligibility": "Any age, any sex" },
{ "id": "ladies", "name": "Ladies", "scorerCount": 3, "eligibility": "Women" },
{ "id": "vets",   "name": "Vets",   "scorerCount": 4, "eligibility": "Men & Women 40+" }
```

## Pages Updated

### `src/pages/road-gp/index.astro`

Replace current markup entirely. Uses `SeriesDetailLayout` with:
- `seriesTitle="Road Grand Prix"`
- `subtitle="7 races · April – September · Lancashire"`
- `description` slot: series intro + David Wood callout block
- `rules` slot: 5 Road GP rules
- `individual-awards` slot: "best 4 of 7 races" paragraph

### `src/pages/fell/index.astro`

Replace current markup entirely. Uses `SeriesDetailLayout` with:
- `seriesTitle="Fell Championship"`
- `subtitle="4 races · March – September · Lancashire"`
- `description` slot: fell series intro
- `rules` slot: 2 fell-specific rules
- `individual-awards` slot: "best 3 of 4 races" paragraph

## Tailwind Token Mapping

| Design CSS var | Tailwind class |
|---|---|
| `--ic-amber` | `text-amber` / `bg-amber` / `border-amber` |
| `--ic-amber-bg` | `bg-amber-bg` |
| `--ic-surface` | `bg-surface` |
| `--ic-bg` | `bg-canvas` |
| `--ic-border` | `border-line` |
| `--ic-text` | `text-content` |
| `--ic-muted` | `text-muted` |
| `--ff-head` | `font-head` |
| `--ff-mono` | `font-mono` |

## Build Verification

TypeScript errors in Astro pages only surface via `npm run build`. After implementation, run `npm run build` to confirm no type errors. `npm test` validates any pure-function changes (the new `isResultsProvisional` is not unit tested as it depends on `import.meta.glob`).
