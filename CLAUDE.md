# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

InterClub is a static website for managing and displaying results for a Lancashire running competition. See [Overview.md](Overview.md) for full domain details.

## Domain Summary

Two annual running series contested by 7 clubs (Blackpool Wyre & Fylde AC, Chorley A&TC, Lytham St. Annes RR, Preston Harriers, Red Rose RR, Thornton Cleveleys RC, Wesham RR):

- **Inter Club Road Grand Prix** — each club hosts one road race (4–5 miles), free to enter for club members, minimum age 15
- **Inter Club Fell Championship** — 4 races organised by external authorities, paid entry, kit requirements

**Individual scoring** — by finish position, broken down by sex and age category (M/F; Junior, Senior, V35–V100 in 5-year bands; V35 female-only). Rules and categories have changed across years.

**Team scoring** — runners grouped into teams by sex/age category (Open=10 runners, Female=5, Vets=4, Vet50=3). Rules also vary by year and series.

## Tech Stack

- **Framework:** Astro v6 (static site generator)
- **Styling:** Tailwind CSS v4 + DaisyUI v5
- **Testing:** Vitest
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
      road-gp/
        races.json           # Road GP schedule
      fell/
        races.json           # Fell Championship schedule
  lib/
    types.ts                 # domain types (Race, Series, SiteConfig)
    format.ts                # date formatting utilities
    years.ts                 # pure helper for extracting years from paths
    data.ts                  # data loading via import.meta.glob
  components/
    Layout.astro             # shared nav + footer wrapper
    RaceCard.astro           # individual race card
    RaceList.astro           # race list with year filter
    YearFilter.astro         # year dropdown navigation
  pages/
    index.astro              # home page
    road-gp/                 # Road GP schedule + detail pages
    fell/                    # Fell Championship schedule + detail pages
```

## Data

Race data lives in `src/data/{year}/{series}/races.json`. The current year is controlled by `src/data/config.json` — update `currentYear` when a new season begins.

To add a new year, create `src/data/{year}/road-gp/races.json` and `src/data/{year}/fell/races.json`, then update `config.json`.

`getAvailableYears(series)` in `src/lib/data.ts` requires a series argument — it is intentionally series-aware so that years with data for one series but not the other don't generate empty pages.
