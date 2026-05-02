# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InterClub is a static website for managing and displaying results for a Lancashire running competition. See [Overview.md](Overview.md) for full domain details.

## Domain Summary

Two annual running series contested by 7 clubs (Blackpool Wyre & Fylde AC, Chorley A&TC, Lytham St. Annes RR, Preston Harriers, Red Rose RR, Thornton Cleveleys RC, Wesham RR):

- **Inter Club Road Grand Prix** — each club hosts one road race (4–5 miles), free to enter for club members, minimum age 15
- **Inter Club Fell Championship** — 4 races organised by external authorities, paid entry, kit requirements

**Individual scoring** — by finish position, broken down by sex and age category (M/F; Junior, Senior, V35–V100 in 5-year bands; V35 female-only). Rules and categories have changed across years.

**Team scoring** — runners grouped into teams by sex/age category. Scorer counts and categories vary by series and year; they are configured in `config.teamCategories` (e.g. Road GP 2026: Open=10, Ladies=5, FV40=5, Vets=6, Vet50s=4, Vet60s=3).

## Tech Stack

- **Framework:** Astro v6 (static site generator)
- **Styling:** Tailwind CSS v4 + DaisyUI v5
- **Testing:** Vitest (pure functions only — glob-dependent loaders are not unit tested)
- **Language:** TypeScript (strict)

## Commands

```bash
npm run dev      # start dev server
npm run build    # build static site to dist/
npm run preview  # serve built output
npm test         # run unit tests
```

> **Note:** TypeScript errors in Astro pages only surface via `npm run build` — `npm test` only runs pure-function unit tests and will not catch type errors in `.astro` files.

## Project Structure

```
src/
  data/
    config.json              # controls currentYear
    {year}/
      clubs.json             # competing clubs for that year (id, name, shortName, logo)
      road-gp/
        races.json           # Road GP schedule
        config.json          # series config (ageCategories, teamCategories, and optionally individualCategories + maxCountingRaces)
        individual-standings.json  # season individual standings (optional; computed externally)
        results/
          {race-id}.csv                      # final individual results
          {race-id}-provisional.csv          # provisional individual results
          {race-id}-teams.json               # final team results
          {race-id}-teams-provisional.json   # provisional team results
                                             # (build prefers final over provisional if both exist)
      fell/
        races.json           # Fell Championship schedule
        config.json          # series config (ageCategories, teamCategories, and optionally individualCategories + maxCountingRaces)
        results/
          {race-id}.csv
          {race-id}-provisional.csv
          {race-id}-teams.json
          {race-id}-teams-provisional.json
        individual-standings.json  # season individual standings (optional; computed externally)
  lib/
    types.ts                 # domain types (Race, Series, SiteConfig, RaceResult, Club,
                             #   SeriesConfig, TeamCategory, TeamResults, TeamClubResult, etc.)
    format.ts                # date formatting utilities
    years.ts                 # pure helper for extracting years from paths
    data.ts                  # race schedule loading via import.meta.glob
    results.ts               # CSV + team JSON parsing; results/clubs/config/team loading
    runners.ts               # runner identity loading; buildRunnerUrlMap; getRunnerProfileStaticPaths
  components/
    Layout.astro             # shared nav + footer wrapper
    RaceCard.astro           # individual race card
    RaceList.astro           # race list with year filter (current year only)
    HistoryRaceList.astro    # condensed archive list for past years (date, name, result links, awards)
    SeriesAwards.astro       # awards section rendered on past-year index pages
    YearFilter.astro         # year dropdown navigation
  pages/
    index.astro              # home page
    road-gp/                 # Road GP schedule + detail pages
      [year]/
        index.astro          # condensed history view for that past year (uses HistoryRaceList)
        team-standings.astro        # season team standings (only generated when team-standings.json exists)
        individual-standings.astro  # season individual standings (only generated when individual-standings.json exists)
        [raceId]/
          results.astro      # individual results page
          team-results.astro # team results page (only generated when team JSON exists)
    fell/                    # Fell Championship schedule + detail pages
      [year]/
        index.astro          # condensed history view for that past year (uses HistoryRaceList)
        team-standings.astro
        individual-standings.astro
        [raceId]/
          results.astro
          team-results.astro
    runners/
      [slug].astro       # runner profile page (aggregates all results and awards for one runner)
```

## Data

Race data lives in `src/data/{year}/{series}/races.json`. The current year is controlled by `src/data/config.json` — update `currentYear` when a new season begins.

To add a new year, create all of these files:

```
src/data/{year}/clubs.json             # competing clubs for that year
src/data/{year}/road-gp/races.json     # each race may have a shortName abbreviation for standings columns
src/data/{year}/road-gp/config.json    # age categories + teamCategories for Road GP
src/data/{year}/road-gp/runners.json   # series runner file — can start as [] and grow as IDs are assigned
src/data/{year}/fell/races.json
src/data/{year}/fell/config.json       # age categories + teamCategories for Fell
src/data/{year}/fell/runners.json      # series runner file — can start as []
```

Then update `src/data/config.json` to set `currentYear`. Missing `clubs.json` or `config.json` causes results pages to silently render with no clubs or categories in the filter bar.

### Adding a new runner

1. Add an entry to `src/data/runners.json` with a new unique `id` (increment from the highest existing id). Use the runner's canonical/current name.
2. Add a matching entry to `src/data/{year}/{series}/runners.json` with a series-local `id` (unique within that file) and `runnerId` pointing to the global entry.
3. In the results CSV, add the series-local `id` in the `series_runner_id` column for the runner's rows.
4. In any `awards.json` individual award entries for this runner, add `"seriesRunnerId": <series-local-id>`.
5. In any `individual-standings.json` runner entries, add `"seriesRunnerId": <series-local-id>`.

Runner data degrades gracefully: rows with no `series_runner_id` simply render without a profile link — existing CSVs and JSON files do not need to be updated all at once.

`getAvailableYears(series)` in `src/lib/data.ts` requires a series argument — it is intentionally series-aware so that years with data for one series but not the other don't generate empty pages.

### Results CSV schema

```
position,ic_position,race_number,first_name,last_name,club,category,sex,time
1,1,42,Luke,Minns,blackpool,V35,M,19:35
9,, ,T.,Guest,Guest,SEN,M,22:14
```

`club` is a club `id` from `clubs.json`, or `Guest` for non-club runners. `ic_position` is empty for guests. `race_number` is optional — the column may be omitted entirely from older CSVs or left empty for individual runners; both cases parse as `null` on `RaceResult.raceNumber`. All fields are optional to support partial historical data.

The optional `series_runner_id` column (last column, integer) links a row to `id` in `src/data/{year}/{series}/runners.json`, enabling runner profile links and profile page aggregation.

### Team results JSON schema

Team results are computed externally and placed alongside the individual results CSVs. File absence means no team results exist for that race.

```json
{
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "points": 7,
          "club": "wesham",
          "total": 175,
          "scorers": [
            { "name": "M. Swarbrick", "position": 5 },
            { "name": "J. Townsend",  "position": 8 }
          ]
        }
      ]
    }
  ]
}
```

- `category` — id matching `teamCategories[].id` in the series `config.json`
- `club` — id matching `clubs.json[].id`
- `points` — stored explicitly; a club that fails to field enough scorers receives 0 points
- scorer `position` — the runner's rank within the sex/age group used for team scoring

### Data loading

CSVs are loaded at build time via `import.meta.glob` with `{ query: '?raw', import: 'default', eager: true }` — this returns the raw file content as a string. Do not use a CSV library; use the `parseResultsCsv` utility in `src/lib/results.ts`. JSON data files (clubs, config, races, team results) are loaded with standard eager glob imports.

**`import.meta.glob` must be called at module level** (top of the file, outside any function or conditional). Vite resolves glob patterns at build time; calling them inside a function causes a runtime error. See `src/lib/runners.ts` for the established pattern of declaring all globs at module scope and referencing them inside functions.

**Dependency direction in lib/:** `runners.ts` imports from `results.ts` and `data.ts`. `results.ts` and `data.ts` do not import from `runners.ts`. Keep this one-way — pages import `buildRunnerUrlMap` directly from `runners.ts`, not via `results.ts` helpers.

Only pure functions (`parseResultsCsv`, `parseTeamResultsPath`, `parseTeamStandingsPath`, `runnerSlug`, `parseSeriesRunnerPath`, date helpers, year extraction) are unit tested. Functions that depend on `import.meta.glob` are validated by the build instead.

### Team standings JSON schema

Season standings are computed externally and placed at `src/data/{year}/{series}/team-standings.json`. File absence means no standings page is generated for that year.

```json
{
  "provisional": true,
  "races": ["bwf-5", "chorley-4"],
  "categories": [
    {
      "category": "open",
      "clubs": [
        {
          "position": 1,
          "club": "wesham",
          "points": [7, null],
          "total": 7,
          "tiebreaker": null
        }
      ]
    }
  ]
}
```

- `provisional` — shows a warning badge on the page when true
- `races` — ordered list of race ids; index maps to each club's `points` array
- `clubs[].points` — one entry per race; `null` for races not yet run (renders as `—`)
- `clubs[].tiebreaker` — nullable string shown beneath the total when non-null
- `races[].shortName` in `races.json` provides the column header abbreviation (e.g. `"BPL"`); falls back to the race id if absent

### Individual standings JSON schema

Season individual standings are computed externally and placed at `src/data/{year}/{series}/individual-standings.json`. File absence means no individual standings page is generated for that year.

```json
{
  "provisional": true,
  "races": ["fell-race-1", "fell-race-2"],
  "categories": [
    {
      "category": "sen-m",
      "runners": [
        {
          "position": 1,
          "name": "Luke Minns",
          "club": "blackpool",
          "sex": "M",
          "ageCategory": "SEN",
          "total": 47,
          "results": {
            "fell-race-1": { "points": 25, "counting": true },
            "fell-race-3": { "points": 22, "counting": false }
          }
        }
      ]
    }
  ]
}
```

- `category` — id matching `individualCategories[].id` in the series `config.json`
- `runners[].results` — sparse map keyed by race id; only races the runner actually entered are present (no nulls)
- `results[raceId].counting` — `false` when this race didn't count toward the runner's total (shown dimmed with strikethrough on the page)
- `runners[].total` — pre-computed and stored explicitly
- `runners[].sex` / `runners[].ageCategory` — stored separately for client-side filtering; displayed combined as e.g. `MSEN`, `FV40`
- `runners[].seriesRunnerId` — optional; references `id` in `src/data/{year}/{series}/runners.json`; enables a link to the runner's profile page

### Series config.json schema

```json
{
  "ageCategories": ["SEN", "V40", "V50"],
  "maxCountingRaces": 3,
  "individualCategories": [
    { "id": "sen-m", "name": "Senior Men" },
    { "id": "v40-f", "name": "V40 Women" }
  ],
  "teamCategories": [
    { "id": "open", "name": "Open", "scorerCount": 6 }
  ]
}
```

- `ageCategories` — age bands shown in the results filter bar (note: formerly named `categories` — do not use the old name)
- `maxCountingRaces` — optional; when set, individual standings page shows "Best N races count" and marks non-counting results
- `individualCategories` — optional; defines which tabs appear on the individual standings page and in what order; `id` is referenced by `individual-standings.json` and `awards.json`; optional `sex: "M" | "F"` field controls column placement on the awards section (absent = Overall, full-width)
- `teamCategories` — defines team scoring groups; `id` is referenced by team results JSON files and `awards.json`

### Awards JSON schema

End-of-season award winners are placed at `src/data/{year}/{series}/awards.json`. File absence means no awards section is shown on the series index page.

```json
{
  "teamAwards": [
    { "category": "open",   "club": "wesham" },
    { "category": "ladies", "club": "lytham" }
  ],
  "individualAwards": [
    {
      "category": "sen-m",
      "awards": [
        { "position": 1, "name": "L. Minns", "club": "blackpool", "seriesRunnerId": 1 },
        { "position": 3, "name": "T. Guest", "club": "red-rose" }
      ]
    }
  ]
}
```

- `teamAwards[].category` — id matching `teamCategories[].id` in `config.json`; one award per team category (the winning club only)
- `individualAwards[].category` — id matching `individualCategories[].id` in `config.json`
- `individualAwards[].awards[].position` — explicit; gaps are allowed (e.g. position 2 absent means no 2nd-place award was given)
- `individualAwards[].awards[].seriesRunnerId` — optional; references `id` in `src/data/{year}/{series}/runners.json`; enables a link to the runner's profile page
- `club` — id matching `clubs.json[].id`; display name resolved at build time
- Awards are placed at `src/data/{year}/{series}/awards.json` for a past year — they are announced the following season, so they belong on the past-year archive page, not the current-year page
- On past-year pages (`[year]/index.astro`) the awards section renders below the race list under a `{year} Awards` heading, only when this file exists; the current-year pages never show awards

### Global runner registry schema

`src/data/runners.json` — one entry per canonical runner identity:

```json
{ "id": 1, "firstName": "Luke", "lastName": "Minns", "club": "blackpool", "sex": "M", "category": "V35" }
```

### Series runner file schema

`src/data/{year}/{series}/runners.json` — links series-local IDs to the global registry:

```json
{ "id": 1, "runnerId": 1, "firstName": "Luke", "lastName": "Minns", "club": "blackpool", "sex": "M", "category": "V35" }
```

- `id` — series-local numeric ID; referenced by `series_runner_id` in results CSVs and `seriesRunnerId` in awards JSON
- `runnerId` — references the global `runners.json` `id`
- `number` — optional bib number for this series/year

The results CSV `series_runner_id` column (last, optional) references `id` in the series runner file.
The awards JSON `seriesRunnerId` field (optional on individual award entries) references the same `id`.
