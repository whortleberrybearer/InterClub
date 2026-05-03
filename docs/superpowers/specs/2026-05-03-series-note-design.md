# Series Note Field Design

**Date:** 2026-05-03  
**Topic:** Generic series-level note for year/series pages (e.g. suspended seasons)

## Problem

Years with no races (e.g. 2020 and 2021, suspended due to COVID-19) create a gap in the history navigation. There is currently no way to represent these years in the site or explain why they are absent.

## Solution

Add an optional `note` field to the series `config.json`. The note is displayed as quiet italic text on the year history page, alongside or in place of the race list. The mechanism is generic — any year/series can carry a note for any reason.

## Data Layer

### `SeriesConfig` type (`src/lib/types.ts`)

- Add `note?: string`
- Change `ageCategories: string[]` → `ageCategories?: string[]` (only needed when results exist; safe to omit for empty years)

### New data files for 2020 and 2021

Four pairs of files (one per series per year):

```
src/data/2020/road-gp/races.json   →  []
src/data/2020/road-gp/config.json  →  { "note": "Season suspended due to the COVID-19 pandemic." }
src/data/2020/fell/races.json      →  []
src/data/2020/fell/config.json     →  { "note": "Season suspended due to the COVID-19 pandemic." }

src/data/2021/road-gp/races.json   →  []
src/data/2021/road-gp/config.json  →  { "note": "Season suspended due to the COVID-19 pandemic." }
src/data/2021/fell/races.json      →  []
src/data/2021/fell/config.json     →  { "note": "Season suspended due to the COVID-19 pandemic." }
```

The empty `races.json` files make those years discoverable by `getAvailableYears` — no change to discovery logic is required. `getSeriesConfig` already returns a safe default for missing files, so all other years are unaffected.

## Page Layer

### `src/pages/road-gp/[year]/index.astro` and `src/pages/fell/[year]/index.astro`

- Read `note` from the result of `getSeriesConfig(year, series)`
- Pass it as `note={config.note}` to `HistoryRaceList`

### `src/components/HistoryRaceList.astro`

- Add `note?: string` to the `Props` interface
- Remove the `"No races found for {year}."` fallback message — when there are no races the slot is simply empty
- Render the note (when present) as a quiet line immediately after the race list slot:

```astro
{note && <p class="text-base-content/60 italic text-sm mt-2">{note}</p>}
```

The note renders regardless of whether races exist, so a partial season with an explanatory note works naturally.

## Scope

- No changes to results pages, standings pages, team results pages, or runner profile pages
- No changes to the current year page (`road-gp/index.astro`, `fell/index.astro`)
- No changes to year discovery logic in `data.ts`

## Example Rendered Output

```
Road Grand Prix — 2020
                              [year filter]

Season suspended due to the COVID-19 pandemic.
```
