# Race Schedule Website — Design Spec

**Date:** 2026-04-24
**Status:** Approved

## Overview

A static website for the Inter Club running competition that displays race schedules for both series (Road Grand Prix and Fell Championship). Built to support historical browsing across years, with results and standings as a planned future phase.

## Tech Stack

- **Framework:** Astro (static site generator)
- **Styling:** Tailwind CSS + DaisyUI (pre-built component library)
- **Deployment:** Static HTML output — compatible with Netlify, Vercel, or GitHub Pages
- **Data:** JSON files, edited directly by a technical maintainer

Astro was chosen over Next.js because it generates pure static HTML with zero JavaScript overhead by default, is purpose-built for content-heavy sites, and pairs naturally with DaisyUI without requiring a React integration.

## Data Structure

Race data is organised by year and series under `src/data/`. A top-level config file controls which year is treated as current:

```json
// src/data/config.json
{
  "currentYear": 2026
}
```

The `currentYear` value determines which data folder populates `/road-gp/` and `/fell/`. Historical years are accessible at `/road-gp/[year]/` and `/fell/[year]/`. The current year is always available at both `/road-gp/` (canonical) and `/road-gp/2026/` (redirects to canonical).

Race data folders live under `src/data/`:

```
src/data/
  2026/
    road-gp/
      races.json        ← race schedule
      categories.json   ← scoring categories for this year
      winners.json      ← award winners
      results/
        [race-id].json  ← individual race results
    fell/
      races.json
      categories.json
      winners.json
      results/
        [race-id].json
  2025/
    road-gp/
      ...
    fell/
      ...
```

Each year and series is fully self-contained, reflecting that scoring rules and categories have changed over the years.

### Race schema (`races.json`)

```json
[
  {
    "id": "bwf-5",
    "name": "Blackpool Wyre & Fylde 5",
    "date": "2026-06-07",
    "time": "10:30",
    "location": "Stanley Park, Blackpool",
    "distance": "5 miles",
    "detailsUrl": "https://...",
    "image": "bwf-5.jpg"
  }
]
```

Only `id`, `name`, and `date` are required. All other fields are optional — the race card renders gracefully when they are absent.

## Navigation

Series-first navigation with year as a filter on each series page.

```
Inter Club  |  Road GP  |  Fell Championship
```

On each series page, a year dropdown (e.g. "2026 ▾") lets users navigate to historical seasons. The default view always shows the current year.

This keeps primary navigation simple for regular visitors while making history accessible without a dedicated section.

## Pages

| Page | URL | Content |
|------|-----|---------|
| Home | `/` | Overview of both series, current year summary, links to each series |
| Road GP Schedule | `/road-gp/` | Card list of races for current year, year filter |
| Fell Schedule | `/fell/` | Card list of races for current year, year filter |
| Race Detail | `/road-gp/[race-id]/` | Full race info, venue image, map (future) |
| Road GP Schedule (historical) | `/road-gp/[year]/` | Card list for a past year |
| Fell Schedule (historical) | `/fell/[year]/` | Card list for a past year |

Future pages (Phase 2+):

| Page | URL |
|------|-----|
| Standings | `/road-gp/standings/`, `/road-gp/[year]/standings/` |
| Winners | `/road-gp/winners/`, `/road-gp/[year]/winners/` |
| Race Results | `/road-gp/[race-id]/results/` |

## Race Schedule Layout

Each series page displays races as a vertical card list. Each card shows:

- Date and time (formatted, e.g. "Sun 7 Jun · 10:30")
- Race name (prominent)
- Location and distance
- Optional link to further details
- Optional venue image (renders only when `image` is provided in JSON)
- Room for a map embed in future (card layout supports extension)

Cards are mobile-first: single column on small screens, readable without horizontal scrolling. The layout is deliberately spacious to accommodate future image and map additions without restructuring.

## Components

| Component | Purpose |
|-----------|---------|
| `Layout.astro` | Shared wrapper — nav, footer, page title |
| `RaceCard.astro` | Individual race card (used in schedule list) |
| `RaceList.astro` | Wraps a list of RaceCards for a given series/year |
| `YearFilter.astro` | Dropdown to navigate between years on a series page |

## Out of Scope (Phase 1)

- Results display
- Standings tables
- Winners pages
- Runner profiles
- Any server-side logic or database
- Admin interface — data is edited directly in JSON files
