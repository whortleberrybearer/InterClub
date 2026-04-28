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

## Project Structure

```
src/
  data/
    config.json              # controls currentYear
    {year}/
      clubs.json             # competing clubs for that year (id, name, shortName, logo)
      road-gp/
        races.json           # Road GP schedule
        config.json          # series config (age categories + teamCategories)
        results/
          {race-id}.csv                      # final individual results
          {race-id}-provisional.csv          # provisional individual results
          {race-id}-teams.json               # final team results
          {race-id}-teams-provisional.json   # provisional team results
                                             # (build prefers final over provisional if both exist)
      fell/
        races.json           # Fell Championship schedule
        config.json          # series config (age categories + teamCategories)
        results/
          {race-id}.csv
          {race-id}-provisional.csv
          {race-id}-teams.json
          {race-id}-teams-provisional.json
  lib/
    types.ts                 # domain types (Race, Series, SiteConfig, RaceResult, Club,
                             #   SeriesConfig, TeamCategory, TeamResults, TeamClubResult, etc.)
    format.ts                # date formatting utilities
    years.ts                 # pure helper for extracting years from paths
    data.ts                  # race schedule loading via import.meta.glob
    results.ts               # CSV + team JSON parsing; results/clubs/config/team loading
  components/
    Layout.astro             # shared nav + footer wrapper
    RaceCard.astro           # individual race card
    RaceList.astro           # race list with year filter
    YearFilter.astro         # year dropdown navigation
  pages/
    index.astro              # home page
    road-gp/                 # Road GP schedule + detail pages
      [year]/
        index.astro          # schedule for that year
        team-standings.astro # season team standings (only generated when team-standings.json exists)
        [raceId]/
          results.astro      # individual results page
          team-results.astro # team results page (only generated when team JSON exists)
    fell/                    # Fell Championship schedule + detail pages
      [year]/
        index.astro
        team-standings.astro
        [raceId]/
          results.astro
          team-results.astro
```

## Data

Race data lives in `src/data/{year}/{series}/races.json`. The current year is controlled by `src/data/config.json` — update `currentYear` when a new season begins.

To add a new year, create all of these files:

```
src/data/{year}/clubs.json             # competing clubs for that year
src/data/{year}/road-gp/races.json     # each race may have a shortName abbreviation for standings columns
src/data/{year}/road-gp/config.json    # age categories + teamCategories for Road GP
src/data/{year}/fell/races.json
src/data/{year}/fell/config.json       # age categories + teamCategories for Fell
```

Then update `src/data/config.json` to set `currentYear`. Missing `clubs.json` or `config.json` causes results pages to silently render with no clubs or categories in the filter bar.

`getAvailableYears(series)` in `src/lib/data.ts` requires a series argument — it is intentionally series-aware so that years with data for one series but not the other don't generate empty pages.

### Results CSV schema

```
position,ic_position,first_name,last_name,club,category,sex,time
1,1,Luke,Minns,blackpool,V35,M,19:35
9,,T.,Guest,Guest,SEN,M,22:14
```

`club` is a club `id` from `clubs.json`, or `Guest` for non-club runners. `ic_position` is empty for guests. All fields are optional to support partial historical data.

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

Only pure functions (`parseResultsCsv`, `parseTeamResultsPath`, `parseTeamStandingsPath`, date helpers, year extraction) are unit tested. Functions that depend on `import.meta.glob` are validated by the build instead.

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
