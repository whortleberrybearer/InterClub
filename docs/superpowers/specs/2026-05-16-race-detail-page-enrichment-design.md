# Race Detail Page Enrichment

**Date:** 2026-05-16
**Series scope:** Road GP only

## Overview

Expand the Road GP race detail page (`road-gp/[year]/[raceId].astro`) with richer venue, course, and historical information. Simultaneously simplify fell race navigation so fell race cards link directly to an external URL rather than an internal detail page.

---

## Data Model

### New `CourseRecord` type (`src/lib/types.ts`)

```typescript
export interface CourseRecord {
  sex: 'M' | 'F';
  time: string;   // "MM:SS", e.g. "24:15"
  name: string;   // e.g. "J. Smith"
  year: number;
}
```

### New optional fields on `Race` interface (`src/lib/types.ts`)

```typescript
ascent?: string;           // e.g. "150m"
startAddress?: string;     // full street address of start line
mapEmbedUrl?: string;      // Google Maps embed URL from Share → Embed a map
parking?: string;          // free-text parking instructions
routeImage?: string;       // image filename relative to /public/images/
routeDescription?: string; // free-text route description
courseRecords?: CourseRecord[];
postRaceVenue?: string;    // free-text post-race venue description
```

All fields are optional. All existing fields (`distance`, `location`, `image`, `detailsUrl`, etc.) are unchanged.

### Example `races.json` entry

```json
{
  "id": "blackpool",
  "name": "Blackpool Wyre & Fylde Inter Club",
  "shortName": "BPL",
  "date": "2026-04-08",
  "time": "19:00",
  "location": "Stanley Park, Blackpool",
  "image": "blackpool-hero.jpg",
  "distance": "4.5 miles",
  "ascent": "50m",
  "startAddress": "Stanley Park, West Park Drive, Blackpool FY3 9HU",
  "mapEmbedUrl": "https://www.google.com/maps/embed?pb=...",
  "parking": "Free car parking available in the main Stanley Park car park off West Park Drive. Arrive early on race night as spaces fill quickly.",
  "routeImage": "blackpool-route.jpg",
  "routeDescription": "Two laps of Stanley Park on surfaced paths. The route takes in the boating lake and rose garden before climbing through the woodland section on each lap.",
  "courseRecords": [
    { "sex": "M", "time": "24:15", "name": "J. Smith", "year": 2019 },
    { "sex": "F", "time": "27:42", "name": "A. Jones", "year": 2021 }
  ],
  "postRaceVenue": "Saddle Inn, West Park Drive, Blackpool FY3 9HU. Refreshments provided by the host club."
}
```

---

## Road GP Detail Page (`src/pages/road-gp/[year]/[raceId].astro`)

### Layout (Option 1 — map/image right, text left)

All new sections are conditionally rendered — if none of the relevant fields are set, the section does not appear.

#### Header (existing, lightly changed)
- Hero image (`image`) — full width, existing behaviour
- Date/time in small uppercase text
- Race name as `h1`
- `location` (if set) — short venue label, shown as a subtitle below the race name, unchanged from current behaviour
- Distance and ascent rendered as small badge/chip elements (replacing the existing `<dl>` grid for those two fields)

#### Getting Here
Shown when `startAddress` or `mapEmbedUrl` is set.

When both address/parking text and `mapEmbedUrl` are present: two-column layout (stacks to single column on mobile) — text left, map right.
When only `mapEmbedUrl` is set (no `startAddress` or `parking`): map renders full-width.
When only address/parking text is set (no `mapEmbedUrl`): single column, text only.

Left column content (each item only renders if its field is set):
- "Start location" label + `startAddress` text
- "Parking" label + `parking` text

Right column: Google Maps `<iframe>` using `mapEmbedUrl` as `src`, with `loading="lazy"`.

#### The Course
Shown when any of `routeImage`, `routeDescription`, or `courseRecords` is set.

Two-column layout (stacks on mobile):
- **Left:** `routeDescription` text (if set); course records table/rows (if `courseRecords` is set) — one row per record showing sex label, time, name, year
- **Right:** `routeImage` rendered as `<img>` from `/public/images/` (if set)

#### After the Race
Shown when `postRaceVenue` is set. Single-column free-text block.

#### Past Results
Shown when at least one previous year has results for this `raceId`.

Computed in `getStaticPaths`: iterate all years returned by `getAvailableYears('road-gp')` that are less than the current race's year, check `hasResults(y, 'road-gp', race.id)`, collect matching years and their results URLs. Passed as a prop to the page.

Rendered as a row of year links: `2025 · 2024 · 2023`

#### Actions (existing, repositioned to bottom)
- "View Results" button when `hasResults` is true for this race/year

---

## Fell Race Navigation (`src/components/RaceCard.astro`)

The `RaceCard` component is shared between road GP and fell. Card link behaviour changes based on series:

| Series | `detailsUrl` present | Card behaviour |
|--------|----------------------|----------------|
| `road-gp` | either | Links to `/{series}/{year}/{id}/` (unchanged) |
| `fell` | yes | Card `<a>` links to `detailsUrl`, `target="_blank" rel="noopener noreferrer"` |
| `fell` | no | Card renders without an `<a>` wrapper — displays info only, non-navigable |

The "External details ↗" button inside the card body is removed for fell series (the whole card becomes the link). It is retained for road GP races that have `detailsUrl` set.

---

## Fell Detail Page (`src/pages/fell/[year]/[raceId].astro`)

Deleted. No fell detail page is generated. Nothing in the site links to this URL pattern for fell races.

---

## Files Changed

| File | Change |
|------|--------|
| `src/lib/types.ts` | Add `CourseRecord` interface; add 8 new optional fields to `Race` |
| `src/pages/road-gp/[year]/[raceId].astro` | Major expansion — new sections, past results prop |
| `src/components/RaceCard.astro` | Conditional link logic for fell vs road GP |
| `src/pages/fell/[year]/[raceId].astro` | Deleted |
| `src/data/{year}/road-gp/races.json` | New optional fields added per race as data is available |

No changes to results pages, team results pages, standings pages, or any other components.

---

## Notes

- The `mapEmbedUrl` value is obtained from Google Maps via Share → Embed a map → copy the `src` attribute of the iframe. It is stored verbatim in `races.json`.
- All new fields degrade gracefully when absent — no section renders rather than rendering empty.
- `HistoryRaceList.astro` (used for past-year road GP pages) is not changed — it already links directly to results, bypassing the detail page.
- Course records are stored explicitly in `races.json`; they are not computed from results data.
