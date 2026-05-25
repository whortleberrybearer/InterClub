# Category Positions on Individual Results Page

**Date:** 2026-05-25  
**Status:** Approved

## Overview

The individual results page gains per-runner team category positions (Open, Ladies, Vets, etc.). Positions are provided by the external results tool as additional `cat_*` columns in the individual results CSV. On desktop the positions appear as a group of columns to the left of the runner name. On mobile the existing IC/Open column is repurposed to show the active category's position when a category chip is selected.

The existing `ic_position` CSV column is retired and replaced by `cat_open`, making all category positions consistent under the `cat_` naming convention.

---

## CSV Schema

### Column naming convention

Each team category gets a column named `cat_{id}`, where `id` matches the category's `id` field in `config.json` (e.g. `cat_open`, `cat_ladies`, `cat_fv40`, `cat_vets`, `cat_vet50s`, `cat_vet60s`).

The `ic_position` column is retired. Its replacement is `cat_open`.

Category position columns may appear in any order in the CSV. The UI renders them in the order defined by `config.teamCategories`.

### Example row

```
position,cat_open,cat_ladies,cat_fv40,cat_vets,cat_vet50s,cat_vet60s,race_number,first_name,last_name,club,age_category,sex,time,series_runner_id
2,1,,,,,,301,Luke,Minns,blackpool,SEN,M,32:41,7
24,14,1,,4,,,301,Emily,Simm,blackpool,V35,F,35:42,12
40,27,,,12,2,,301,Phil,Leybourne,blackpool,V50,M,36:52,
```

- Empty cell = runner did not score in that category.
- `series_runner_id` remains the last column.
- Category columns are optional — CSVs without them parse cleanly with empty `categoryPositions`.

### Historical CSV migration

All existing CSVs that contain an `ic_position` header have that column renamed to `cat_open`. Values are unchanged. This is a one-off mechanical migration run via a script before the feature is deployed.

---

## Data Model

### `RaceResult` (src/lib/types.ts)

Remove:
```typescript
icPosition: number | null;
```

Add:
```typescript
categoryPositions: Record<string, number | null>;
```

Keys are category ids (e.g. `"open"`, `"ladies"`). Value is the runner's position within that category, or `null` if they did not score.

### `parseResultsCsv` (src/lib/results.ts)

- Stop reading the `ic_position` column.
- After parsing all fixed named columns, scan all remaining headers for the `cat_` prefix. For each match, strip the prefix and store the numeric value (or `null` for empty/missing) in `categoryPositions`.
- No config lookup is needed at parse time — category ids are derived directly from column names.

---

## UI Behaviour

### Desktop — Full view (no category chip active)

Column order:

```
Pos | Open | Ladies | FV40 | Vets | Vet50s | Vet60s | No. | Runner | Cat | Time
```

- One column per entry in `config.teamCategories`, using `TeamCategory.name` as the header.
- Category columns are inserted after `Pos` and before `No.`, grouped together.
- Each cell shows `categoryPositions[cat.id]` or `—` when null.
- Category column headers are styled in muted amber to distinguish them from structural columns.
- If no runners have any category positions (historical data), all cells show `—` — columns are not hidden.

### Desktop — category chip active

- Rows filter to only those where `categoryPositions[activeCategoryId]` is non-null.
- The active category column header turns full amber; other category column headers dim slightly.
- Row order stays as overall finish position (no re-sorting).
- All category columns remain visible — a runner may score in multiple categories.

### Mobile — Full view

Unchanged layout: `Pos | Open | No. | Runner | Cat | Time`.  
The column previously labelled "IC" is renamed to "Open" (showing `categoryPositions.open`).

### Mobile — category chip active

- The Open column header renames to the active category name (e.g. "Ladies").
- The Open column value shows `categoryPositions[activeCategoryId]` instead of `categoryPositions.open`.
- The `No.` column is hidden to keep the table within 5 columns without horizontal scroll.
- Rows filter to only those with a non-null value for the active category.

### Initial chip state & backward compatibility

When no runners have any category positions (all `categoryPositions` are empty — historical CSVs without `cat_*` columns), the initial active chip is always "Full". Category chip selection yields zero rows in this case, but the Full view is unaffected.

When category position data is present, the initial chip state follows the existing logic: first category chip pre-selected when no guests are present.

---

## Component Changes

### src/lib/types.ts
- Remove `icPosition` from `RaceResult`.
- Add `categoryPositions: Record<string, number | null>` to `RaceResult`.

### src/lib/results.ts
- `parseResultsCsv`: remove `ic_position` reading; add `cat_*` column detection loop.

### src/components/IndividualResultsLayout.astro

**Frontmatter:**
- Replace all references to `r.icPosition` with `r.categoryPositions?.open ?? null`.
- `teamCategories` (already available from `config`) drives the dynamic column rendering.

**Server-rendered HTML:**
- `<colgroup>` and `<thead>` gain one `<col>`/`<th>` per team category.
- `<tbody>` rows gain one `<td>` per category.
- Mobile IC column header static text becomes "Open".

**Client script:**
- Local `Result` type: remove `icPosition`, add `categoryPositions: Record<string, number | null>`.
- `buildRow`: IC cell reads `r.categoryPositions?.open ?? '–'`.
- A module-level `activeCategoryId: string | null` variable tracks the current selection.
- Category chip/sidebar click handlers set `activeCategoryId` to the clicked category id and call `render()`.
- `render()` reads `activeCategoryId` and:
  - Filters rows to those where `categoryPositions[activeCategoryId]` is non-null (when non-null).
  - On mobile: updates the IC `<th>` text to the active category name; updates each row's IC cell value; toggles a `no-col-hidden` class on the table to hide the `No.` column via CSS.
  - On desktop: adds `active-col` class to the active category `<th>`; dims other category `<th>` elements.
- "Full" chip sets `activeCategoryId` to null and calls `render()`, restoring the IC header text and showing the `No.` column.

### src/pages/road-gp/[year]/[raceId]/results.astro  
### src/pages/fell/[year]/[raceId]/results.astro
- No changes required (both delegate fully to `IndividualResultsLayout`).

---

## Migration Script

A one-off script (not part of the site build) finds all `*.csv` files under `src/data/`, checks for an `ic_position` header, and renames it to `cat_open` in the header row only. Values are unchanged. Run once and commit.

---

## Out of Scope

- Re-sorting rows by category position (rows always stay in overall finish order).
- Showing category positions on the team results page (separate page, unchanged).
- Adding `seriesRunnerId` to team scorer JSON entries (optional future improvement for scorer name linking — not needed for this feature since positions come from the CSV).
- Any changes to the individual standings or team standings pages.
