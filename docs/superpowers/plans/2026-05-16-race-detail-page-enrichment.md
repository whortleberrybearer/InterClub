# Race Detail Page Enrichment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enrich the Road GP race detail page with venue, course, and historical sections; simplify fell race navigation to skip the detail page entirely.

**Architecture:** All new data lives as optional fields in the per-year `races.json` files. The road-gp detail page grows new conditionally-rendered sections. The fell detail page is deleted; `RaceCard` gains series-conditional link logic so fell cards navigate directly to an external URL when present.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4, DaisyUI v5. No new dependencies. TypeScript errors in `.astro` files only surface via `npm run build` — use that to validate each task.

---

## File Map

| File | Action |
|------|--------|
| `src/lib/types.ts` | Add `CourseRecord` interface; add 8 optional fields to `Race` |
| `src/components/RaceCard.astro` | Series-conditional link logic; remove fell-only "External details" button |
| `src/pages/fell/[year]/[raceId].astro` | Delete |
| `src/pages/road-gp/[year]/[raceId].astro` | Major expansion: new sections, past results prop |

---

## Task 1: Extend the Race type

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add `CourseRecord` interface and new `Race` fields**

  Open `src/lib/types.ts`. After the `Race` interface closing brace, insert the new interface. Also extend `Race` with the new optional fields. The full updated section should read:

  ```typescript
  export interface Race {
    id: string;
    name: string;
    date: string;       // ISO date string: "2026-06-07"
    time?: string;      // "HH:MM", e.g. "10:30"
    location?: string;
    distance?: string;
    ascent?: string;    // e.g. "150m"
    startAddress?: string;
    mapEmbedUrl?: string;
    parking?: string;
    routeImage?: string;    // filename relative to /public/images/
    routeDescription?: string;
    courseRecords?: CourseRecord[];
    postRaceVenue?: string;
    detailsUrl?: string;
    image?: string;     // filename relative to /public/images/
    shortName?: string;
  }

  export interface CourseRecord {
    sex: 'M' | 'F';
    time: string;   // "MM:SS", e.g. "24:15"
    name: string;   // e.g. "J. Smith"
    year: number;
  }
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: build completes with no errors. The new fields are all optional so no existing data files need updating.

- [ ] **Step 3: Commit**

  ```bash
  git add src/lib/types.ts
  git commit -m "feat: add CourseRecord type and new optional Race fields"
  ```

---

## Task 2: Update RaceCard for fell navigation

**Files:**
- Modify: `src/components/RaceCard.astro`

The card currently always links to `/{series}/{year}/{id}/`. For fell races it should link directly to `detailsUrl` (external, new tab) when present, or render as a non-interactive `<div>` when absent. The "External details ↗" button inside the card body is removed for fell (the whole card is the link); retained for road-gp.

- [ ] **Step 1: Replace `src/components/RaceCard.astro` with the updated version**

  ```astro
  ---
  // src/components/RaceCard.astro
  import type { Race, Series } from '../lib/types';
  import { formatRaceDate } from '../lib/format';
  import { siteUrl } from '../lib/url';

  interface Props {
    race: Race;
    year: number;
    series: Series;
  }

  const { race, year, series } = Astro.props;
  const { id, name, date, time, location, distance, detailsUrl, image } = race;

  const formattedDate = formatRaceDate(date, time);
  const isFell = series === 'fell';
  const href = isFell
    ? (detailsUrl ?? null)
    : siteUrl(`/${series}/${year}/${id}/`);
  const isExternal = isFell && !!detailsUrl;

  const cardClasses = "card bg-base-100 shadow-sm border border-base-200 hover:shadow-md transition-shadow no-underline";
  ---

  {href ? (
    <a
      href={href}
      class={cardClasses}
      {...(isExternal ? { target: '_blank', rel: 'noopener noreferrer' } : {})}
    >
      {image && (
        <figure>
          <img src={siteUrl(`/images/${image}`)} alt={name} class="w-full h-44 object-cover" loading="lazy" />
        </figure>
      )}
      <div class="card-body gap-1 py-4">
        <p class="text-xs text-base-content/50 uppercase tracking-wide font-medium">{formattedDate}</p>
        <h2 class="card-title text-base font-bold">{name}</h2>
        {(location || distance) && (
          <p class="text-sm text-base-content/70">
            {location}{location && distance && ' · '}{distance}
          </p>
        )}
        {detailsUrl && !isFell && (
          <div class="card-actions justify-end mt-2">
            <a
              href={detailsUrl}
              target="_blank"
              rel="noopener noreferrer"
              class="btn btn-outline btn-xs"
              onclick="event.stopPropagation()"
            >
              External details ↗
            </a>
          </div>
        )}
      </div>
    </a>
  ) : (
    <div class={cardClasses}>
      {image && (
        <figure>
          <img src={siteUrl(`/images/${image}`)} alt={name} class="w-full h-44 object-cover" loading="lazy" />
        </figure>
      )}
      <div class="card-body gap-1 py-4">
        <p class="text-xs text-base-content/50 uppercase tracking-wide font-medium">{formattedDate}</p>
        <h2 class="card-title text-base font-bold">{name}</h2>
        {(location || distance) && (
          <p class="text-sm text-base-content/70">
            {location}{location && distance && ' · '}{distance}
          </p>
        )}
      </div>
    </div>
  )}
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: build completes with no TypeScript errors.

- [ ] **Step 3: Commit**

  ```bash
  git add src/components/RaceCard.astro
  git commit -m "feat: fell race cards link directly to external URL, not detail page"
  ```

---

## Task 3: Delete the fell detail page

**Files:**
- Delete: `src/pages/fell/[year]/[raceId].astro`

Nothing in the site links to fell detail page URLs now that `RaceCard` bypasses them.

- [ ] **Step 1: Delete the file**

  ```bash
  git rm src/pages/fell/[year]/[raceId].astro
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: build completes. No routes for `/fell/{year}/{id}/` are generated. No links point to those URLs.

- [ ] **Step 3: Commit**

  ```bash
  git commit -m "feat: remove fell race detail page (cards now link externally)"
  ```

---

## Task 4: Expand the Road GP detail page

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId].astro`

Adds: Getting Here, The Course, After the Race, and Past Results sections. Past results are computed in `getStaticPaths` by scanning all available years for matching results.

- [ ] **Step 1: Replace `src/pages/road-gp/[year]/[raceId].astro` with the expanded version**

  ```astro
  ---
  // src/pages/road-gp/[year]/[raceId].astro
  import Layout from '../../../components/Layout.astro';
  import { getAvailableYears, getRaces, getCurrentYear } from '../../../lib/data';
  import { formatRaceDate } from '../../../lib/format';
  import { hasResults } from '../../../lib/results';
  import { siteUrl } from '../../../lib/url';
  import type { Race } from '../../../lib/types';

  export async function getStaticPaths() {
    const allYears = getAvailableYears('road-gp');
    return allYears.flatMap(year =>
      getRaces(year, 'road-gp').map(race => {
        const pastResults = allYears
          .filter(y => y < year && hasResults(y, 'road-gp', race.id))
          .sort((a, b) => b - a)
          .map(y => ({ year: y, url: siteUrl(`/road-gp/${y}/${race.id}/results/`) }));
        return {
          params: { year: String(year), raceId: race.id },
          props: { race, year, pastResults },
        };
      })
    );
  }

  interface Props {
    race: Race;
    year: number;
    pastResults: { year: number; url: string }[];
  }

  const { race, year, pastResults } = Astro.props;
  const {
    name, date, time, location, distance, ascent,
    detailsUrl, image, startAddress, mapEmbedUrl,
    parking, routeImage, routeDescription, courseRecords,
    postRaceVenue,
  } = race;
  const formattedDate = formatRaceDate(date, time);
  const currentYear = getCurrentYear();
  const backUrl = year === currentYear ? siteUrl('/road-gp/') : siteUrl(`/road-gp/${year}/`);
  const resultsExist = hasResults(year, 'road-gp', race.id);
  const hasAddressText = !!(startAddress || parking);
  const hasCourseContent = !!(routeDescription || routeImage || (courseRecords && courseRecords.length > 0));
  ---

  <Layout title={name}>
    <div class="mb-4">
      <a href={backUrl} class="btn btn-ghost btn-sm gap-1 -ml-3">← Road Grand Prix</a>
    </div>

    <div class="card bg-base-100 shadow-sm border border-base-200">
      {image && (
        <figure>
          <img src={siteUrl(`/images/${image}`)} alt={name} class="w-full h-56 object-cover" />
        </figure>
      )}
      <div class="card-body gap-4">

        <!-- Header -->
        <p class="text-sm text-base-content/50 uppercase tracking-wide font-medium">{formattedDate}</p>
        <h1 class="text-2xl font-bold">{name}</h1>
        {location && <p class="text-base-content/70">{location}</p>}
        {(distance || ascent) && (
          <div class="flex flex-wrap gap-2">
            {distance && <span class="badge badge-outline">{distance}</span>}
            {ascent && <span class="badge badge-outline">↑ {ascent}</span>}
          </div>
        )}

        <!-- Getting Here -->
        {(startAddress || mapEmbedUrl) && (
          <>
            <div class="divider my-1 text-sm font-semibold">Getting Here</div>
            {hasAddressText ? (
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <dl class="flex flex-col gap-3">
                  {startAddress && (
                    <div>
                      <dt class="text-xs text-base-content/50 uppercase tracking-wide mb-1">Start location</dt>
                      <dd class="font-medium">{startAddress}</dd>
                    </div>
                  )}
                  {parking && (
                    <div>
                      <dt class="text-xs text-base-content/50 uppercase tracking-wide mb-1">Parking</dt>
                      <dd class="text-base-content/80">{parking}</dd>
                    </div>
                  )}
                </dl>
                {mapEmbedUrl && (
                  <iframe
                    src={mapEmbedUrl}
                    class="w-full h-64 rounded-lg border-0"
                    loading="lazy"
                    referrerpolicy="no-referrer-when-downgrade"
                  ></iframe>
                )}
              </div>
            ) : (
              <iframe
                src={mapEmbedUrl}
                class="w-full h-64 rounded-lg border-0"
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade"
              ></iframe>
            )}
          </>
        )}

        <!-- The Course -->
        {hasCourseContent && (
          <>
            <div class="divider my-1 text-sm font-semibold">The Course</div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="flex flex-col gap-3">
                {routeDescription && (
                  <p class="text-base-content/80">{routeDescription}</p>
                )}
                {courseRecords && courseRecords.length > 0 && (
                  <div>
                    <p class="text-xs text-base-content/50 uppercase tracking-wide mb-2">Course Records</p>
                    <div class="flex flex-col gap-1">
                      {courseRecords.map(record => (
                        <div class="flex items-center gap-2 text-sm">
                          <span class={`badge badge-sm ${record.sex === 'M' ? 'badge-info' : 'badge-secondary'}`}>
                            {record.sex === 'M' ? 'Men' : 'Women'}
                          </span>
                          <span class="font-medium font-mono">{record.time}</span>
                          <span class="text-base-content/70">{record.name}</span>
                          <span class="text-base-content/50">({record.year})</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
              {routeImage && (
                <img
                  src={siteUrl(`/images/${routeImage}`)}
                  alt={`${name} route`}
                  class="w-full rounded-lg object-cover"
                  loading="lazy"
                />
              )}
            </div>
          </>
        )}

        <!-- After the Race -->
        {postRaceVenue && (
          <>
            <div class="divider my-1 text-sm font-semibold">After the Race</div>
            <p class="text-base-content/80">{postRaceVenue}</p>
          </>
        )}

        <!-- Past Results -->
        {pastResults.length > 0 && (
          <>
            <div class="divider my-1 text-sm font-semibold">Past Results</div>
            <div class="flex flex-wrap items-center gap-2">
              {pastResults.map((r, i) => (
                <>
                  {i > 0 && <span class="text-base-content/30">·</span>}
                  <a href={r.url} class="link link-hover text-sm">{r.year}</a>
                </>
              ))}
            </div>
          </>
        )}

        <!-- Actions -->
        {(detailsUrl || resultsExist) && (
          <div class="card-actions mt-2 flex-wrap">
            {detailsUrl && (
              <a href={detailsUrl} target="_blank" rel="noopener noreferrer" class="btn btn-primary">
                View race details ↗
              </a>
            )}
            {resultsExist && (
              <a href={siteUrl(`/road-gp/${year}/${race.id}/results/`)} class="btn btn-outline">
                View Results
              </a>
            )}
          </div>
        )}

      </div>
    </div>
  </Layout>
  ```

- [ ] **Step 2: Verify build passes**

  ```bash
  npm run build
  ```

  Expected: build completes with no TypeScript or template errors.

- [ ] **Step 3: Run dev server and spot-check**

  ```bash
  npm run dev
  ```

  Open a road-gp race detail page (e.g. `http://localhost:4321/road-gp/2026/blackpool/`) and verify:
  - The page loads with no errors
  - Date, name, and location display as before
  - No new sections appear (2026 data has no new fields yet — all sections are conditional)
  - The "View Results" button still works if results exist

  Stop the dev server when done.

- [ ] **Step 4: Commit**

  ```bash
  git add src/pages/road-gp/[year]/[raceId].astro
  git commit -m "feat: expand road-gp race detail page with venue, course, and history sections"
  ```

---

## Task 5: Add enrichment data to a race (smoke test with real data)

Add new fields to one race in `src/data/2026/road-gp/races.json` to verify all new sections render correctly end-to-end.

**Files:**
- Modify: `src/data/2026/road-gp/races.json`

- [ ] **Step 1: Add test data to one race entry**

  Open `src/data/2026/road-gp/races.json`. Find the first race entry and add the new optional fields. For example, if the first entry is the Blackpool race:

  ```json
  {
    "id": "blackpool",
    "name": "Blackpool Wyre & Fylde Inter Club",
    "shortName": "BPL",
    "date": "2026-04-08",
    "time": "19:00",
    "location": "Stanley Park, Blackpool",
    "ascent": "50m",
    "startAddress": "Stanley Park, West Park Drive, Blackpool FY3 9HU",
    "mapEmbedUrl": "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d9435.351522907996!2d-3.041577!3d53.807667!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x487b41e4e3e9e3e3%3A0x1e3b3b3b3b3b3b3b!2sStanley%20Park!5e0!3m2!1sen!2suk!4v1620000000000!5m2!1sen!2suk",
    "parking": "Free car parking available in the main Stanley Park car park off West Park Drive. Arrive early on race night as spaces fill quickly.",
    "routeDescription": "Two laps of Stanley Park on surfaced paths. The route takes in the boating lake and rose garden before climbing through the woodland section on each lap.",
    "courseRecords": [
      { "sex": "M", "time": "24:15", "name": "J. Smith", "year": 2019 },
      { "sex": "F", "time": "27:42", "name": "A. Jones", "year": 2021 }
    ],
    "postRaceVenue": "Saddle Inn, West Park Drive, Blackpool FY3 9HU. Refreshments provided by the host club."
  }
  ```

  Use a real Google Maps embed URL for the actual venue — get it from Google Maps → Share → Embed a map → copy the `src` attribute. The URL above is a placeholder for testing only.

- [ ] **Step 2: Start dev server and verify all sections render**

  ```bash
  npm run dev
  ```

  Navigate to `http://localhost:4321/road-gp/2026/blackpool/` and verify:
  - **Header:** ascent badge appears alongside distance
  - **Getting Here:** two-column layout with address+parking on left, map on right
  - **The Course:** route description on left, course records (Men/Women rows) below it; right column empty (no routeImage set yet — that's fine)
  - **After the Race:** post-race venue text appears
  - **Past Results:** year links appear for any prior years that have results for `blackpool`

- [ ] **Step 3: Verify fell race cards**

  Navigate to `http://localhost:4321/fell/` and verify:
  - Fell races with `detailsUrl` set: clicking the card opens the external URL in a new tab
  - Fell races without `detailsUrl`: card is non-interactive (no cursor pointer, no navigation)
  - No "External details ↗" button appears inside fell cards

- [ ] **Step 4: Remove test data before committing**

  Revert `src/data/2026/road-gp/races.json` to its original state (remove the test fields you added). Real data will be populated separately as races are set up each year.

  ```bash
  git checkout src/data/2026/road-gp/races.json
  ```

- [ ] **Step 5: Final build check**

  ```bash
  npm run build
  ```

  Expected: clean build, no errors.

- [ ] **Step 6: Commit**

  No files were changed permanently in this task (test data was reverted). No commit needed.
