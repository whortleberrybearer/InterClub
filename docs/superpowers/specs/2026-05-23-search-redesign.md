# Search Redesign Spec

**Source:** Claude Design handoff — `search-page.jsx` in `interclub/project/`

---

## Scope

Redesign two files: `SearchBox.astro` (nav component) and `search.astro` (full-page results). No data, index, or search logic changes.

---

## SearchBox — nav component

### Mobile (< md breakpoint)
- Renders a search icon button in the nav (32×32, transparent).
- Tapping opens a **full-screen fixed overlay** (z-50):
  - **Header bar:** × close button + search input (amber focus border + box-shadow ring).
  - **Results stream:** As the user types (≥ 3 chars), show grouped result rows (see Result Row below). Each group has a section label ("Runners · 14") + "See all →" link.
  - **"See all N results" CTA:** Dark pill button at the bottom of results linking to `/search?q=…`.
  - **Recent searches:** Below results/CTA, show up to 4 recent queries as clock-icon pills (stored in `localStorage['ic-recent-searches']`). Hidden when no recent searches.
- Closing: × button, ESC key, or tapping outside.
- Query saved to `localStorage['ic-recent-searches']` when user navigates to `/search?q=…`.

### Desktop (≥ md breakpoint)
- Inline search input (w-64 lg:w-80), amber border + glow ring when focused.
- Shows `esc` badge inside the input when focused.
- Typing ≥ 3 chars opens a **380px dropdown** below the input:
  - Grouped by: Runners (max 3 rows), Race Results (max 2 rows), Standings (max 1 row).
  - Each group: small uppercase label + "N matches" monospace count.
  - First runner row gets amber-bg tint (hovered/top-result treatment).
  - Footer: "See all N results for `q`" in amber + ↵ keyboard hint.
- ESC closes; Enter navigates to `/search?q=…`.
- Click outside closes.

---

## search.astro — results page

### Hero header (shown when query ≥ 3 chars)
- "SEARCH RESULTS" uppercase monospace label.
- Query displayed as large heading (`font-head`, 38px desktop / 28px mobile) in quotes.
- Match count: `"N matches across M sections"` in monospace muted.
- Desktop only: jump-to chips row on the right (one per section with count badge).
- **Filter pills** below: All (total) / Runners / Results / Standings / Archives. Active pill = amber background.
- Activating a filter collapses the 2-col grid to 1-col and shows only the matching section(s).

### Result sections
Four sections: **Runners**, **Race Results**, **Standings**, **Season Archives** — each in a card:
- Card header: uppercase condensed section name + monospace count + "Show all N →" amber link (hidden when all results fit).
- "Show all" activates the corresponding filter pill (no separate page).
- Rows: see Result Row below.
- On desktop with "All" filter: sections displayed in a 2-column grid.
- On desktop with a specific filter: single column, more rows shown per section.

### Result Row (shared between SearchBox dropdown and search page)
```
[icon badge 28×28] [label (highlighted) + subtitle] [meta] [›]
```
- **Icon badge:** Rounded square (border-radius 7), colored bg + SVG icon:
  - `runner` → amber-bg, person silhouette SVG
  - `race-detail` / `race-results` → teal-bg, line-chart SVG
  - `standings` → info-bg (oklch(95% 0.04 220)), trophy SVG
  - `year` → canvas-bg, clock SVG
- **Label:** 14px (13.5px dense), medium weight, truncated. Match characters highlighted with oklch(94% 0.12 60) background.
- **Subtitle:** 11.5px muted, truncated (e.g. "Blackpool · SEN M").
- **Meta:** 11px monospace muted (year, race number, etc.).
- **Chevron:** `›` muted, flex-shrink-0.
- Row separator: 1px border-line on top.
- Hover: subtle background change.

### States
- **Prompt** (< 3 chars / no query): "Type at least 3 characters to search." text only.
- **Empty** (query ≥ 3 chars, zero results):
  - 56px rounded icon box with large search SVG.
  - "No matches" heading (font-head, 22px, black).
  - Body: `We couldn't find anything for "q". Try a different spelling or fewer characters.`
  - "TRY SEARCHING FOR" uppercase label + 4 suggestion pills (Rob Danson, Preston 10K, 2015 Road GP, Pendle Round). Clicking a pill fills the input and re-searches.

### Desktop tip bar (bottom of results)
`Tip:` + `⌘K` kbd hint + minimum 3 characters note + "Open full index →" amber link (links to `/search`).

---

## CSS additions needed

- `--color-teal-bg`: `oklch(96% 0.04 195)` — teal badge background (currently missing).
- Filter pill styles (`.pill`, `.pill-active`) in `global.css`.
- Result row hover style.
