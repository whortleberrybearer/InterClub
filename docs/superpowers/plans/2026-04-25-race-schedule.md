# Race Schedule Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a static Astro website displaying race schedules for the Inter Club Road Grand Prix and Fell Championship, with mobile-first card layouts and year-based historical navigation.

**Architecture:** Astro generates pure static HTML at build time from JSON data files organised by year and series. Pages are series-first (`/road-gp/`, `/fell/`) with a year filter dropdown for historical browsing. Race detail pages live at `/road-gp/[year]/[raceId]/`.

**Tech Stack:** Astro 5, Tailwind CSS v3, DaisyUI v4, Vitest for unit tests.

---

## File Map

```
astro.config.mjs              ← Astro config with Tailwind integration
tailwind.config.mjs           ← Tailwind + DaisyUI plugin config
tsconfig.json                 ← TypeScript config (strict mode)
vitest.config.ts              ← Vitest config
public/
  images/                     ← venue images (empty, ready for use)
src/
  data/
    config.json               ← { "currentYear": 2026 }
    2026/
      road-gp/
        races.json            ← Road GP schedule
      fell/
        races.json            ← Fell Championship schedule
  lib/
    types.ts                  ← TypeScript interfaces (Race, SiteConfig, Series)
    format.ts                 ← Pure date/time formatting utilities
    years.ts                  ← Pure helper: extract unique years from file paths
    data.ts                   ← Data loading via import.meta.glob + re-exports
  components/
    Layout.astro              ← DaisyUI navbar + footer wrapper
    RaceCard.astro            ← Single race card
    RaceList.astro            ← Vertical list of RaceCards
    YearFilter.astro          ← Year dropdown (navigates on change)
  pages/
    index.astro               ← Home: both series summary for current year
    road-gp/
      index.astro             ← Road GP current-year schedule
      [year]/
        index.astro           ← Road GP historical schedule
        [raceId].astro        ← Road GP race detail
    fell/
      index.astro             ← Fell current-year schedule
      [year]/
        index.astro           ← Fell historical schedule
        [raceId].astro        ← Fell race detail
tests/
  lib/
    format.test.ts            ← Tests for format.ts
    years.test.ts             ← Tests for years.ts
```

---

## Task 1: Scaffold Astro project

**Files:**
- Create: `astro.config.mjs`
- Create: `tailwind.config.mjs`
- Create: `vitest.config.ts`
- Modify: `package.json` (created by scaffold)
- Modify: `tsconfig.json` (created by scaffold)

- [ ] **Step 1: Initialise Astro with minimal template**

Run in the repo root (answer `y` to any prompts about the non-empty directory):

```bash
npm create astro@latest . -- --template minimal --install --no-git
```

Expected output ends with: `✔ Project initialised!`

- [ ] **Step 2: Add Tailwind CSS integration**

```bash
npx astro add tailwind --yes
```

Expected: installs `@astrojs/tailwind` and `tailwindcss`, creates `tailwind.config.mjs`.

- [ ] **Step 3: Install DaisyUI**

```bash
npm install -D daisyui@latest
```

- [ ] **Step 4: Install Vitest**

```bash
npm install -D vitest
```

- [ ] **Step 5: Update `tailwind.config.mjs` to enable DaisyUI**

```javascript
// tailwind.config.mjs
import daisyui from 'daisyui';

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx}'],
  plugins: [daisyui],
  daisyui: {
    themes: ['light'],
    logs: false,
  },
};
```

- [ ] **Step 6: Update `astro.config.mjs`**

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [tailwind()],
});
```

- [ ] **Step 7: Create `vitest.config.ts`**

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
});
```

- [ ] **Step 8: Add test script to `package.json`**

In `package.json`, add to the `"scripts"` block:

```json
"test": "vitest run",
"test:watch": "vitest"
```

- [ ] **Step 9: Add `public/images/.gitkeep`**

Create an empty file at `public/images/.gitkeep` so the directory is tracked by git.

- [ ] **Step 10: Verify build passes**

```bash
npm run build
```

Expected: `dist/` directory created, no errors.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "chore: scaffold Astro project with Tailwind and DaisyUI"
```

---

## Task 2: Types and sample data

**Files:**
- Create: `src/lib/types.ts`
- Create: `src/data/config.json`
- Create: `src/data/2026/road-gp/races.json`
- Create: `src/data/2026/fell/races.json`

- [ ] **Step 1: Create `src/lib/types.ts`**

```typescript
// src/lib/types.ts
export type Series = 'road-gp' | 'fell';

export interface SiteConfig {
  currentYear: number;
}

export interface Race {
  id: string;
  name: string;
  date: string;       // ISO date string: "2026-06-07"
  time?: string;      // "HH:MM", e.g. "10:30"
  location?: string;
  distance?: string;
  detailsUrl?: string;
  image?: string;     // filename relative to /public/images/
}
```

- [ ] **Step 2: Create `src/data/config.json`**

```json
{
  "currentYear": 2026
}
```

- [ ] **Step 3: Create `src/data/2026/road-gp/races.json`**

```json
[
  {
    "id": "bwf-5",
    "name": "Blackpool Wyre & Fylde 5",
    "date": "2026-06-07",
    "time": "10:30",
    "location": "Stanley Park, Blackpool",
    "distance": "5 miles"
  },
  {
    "id": "chorley-4",
    "name": "Chorley 4",
    "date": "2026-06-21",
    "time": "10:00",
    "location": "Astley Park, Chorley",
    "distance": "4 miles"
  },
  {
    "id": "lytham-5",
    "name": "Lytham St Annes 5",
    "date": "2026-07-05",
    "time": "10:00",
    "location": "Lytham Green",
    "distance": "5 miles"
  },
  {
    "id": "preston-5",
    "name": "Preston Harriers 5",
    "date": "2026-07-19",
    "time": "10:00",
    "location": "Moor Park, Preston",
    "distance": "5 miles"
  },
  {
    "id": "red-rose-4",
    "name": "Red Rose 4",
    "date": "2026-08-02",
    "time": "10:00",
    "location": "Worden Park, Leyland",
    "distance": "4 miles"
  },
  {
    "id": "thornton-5",
    "name": "Thornton Cleveleys 5",
    "date": "2026-08-16",
    "time": "10:00",
    "location": "Anchorsholme Park",
    "distance": "5 miles"
  },
  {
    "id": "wesham-5",
    "name": "Wesham 5",
    "date": "2026-08-30",
    "time": "10:00",
    "location": "Wesham",
    "distance": "5 miles"
  }
]
```

- [ ] **Step 4: Create `src/data/2026/fell/races.json`**

```json
[
  {
    "id": "fell-race-1",
    "name": "Fell Race 1",
    "date": "2026-06-14",
    "time": "11:00",
    "location": "TBC",
    "distance": "TBC"
  },
  {
    "id": "fell-race-2",
    "name": "Fell Race 2",
    "date": "2026-07-12",
    "time": "11:00",
    "location": "TBC",
    "distance": "TBC"
  },
  {
    "id": "fell-race-3",
    "name": "Fell Race 3",
    "date": "2026-08-09",
    "time": "11:00",
    "location": "TBC",
    "distance": "TBC"
  },
  {
    "id": "fell-race-4",
    "name": "Fell Race 4",
    "date": "2026-09-06",
    "time": "11:00",
    "location": "TBC",
    "distance": "TBC"
  }
]
```

- [ ] **Step 5: Commit**

```bash
git add src/lib/types.ts src/data/
git commit -m "feat: add TypeScript types and 2026 race data"
```

---

## Task 3: Format utilities with tests

**Files:**
- Create: `src/lib/format.ts`
- Create: `tests/lib/format.test.ts`

- [ ] **Step 1: Write failing tests first**

```typescript
// tests/lib/format.test.ts
import { describe, it, expect } from 'vitest';
import { formatRaceDate } from '../../src/lib/format';

describe('formatRaceDate', () => {
  it('formats date with time', () => {
    expect(formatRaceDate('2026-06-07', '10:30')).toBe('Sun 7 Jun · 10:30');
  });

  it('formats date without time', () => {
    expect(formatRaceDate('2026-06-07')).toBe('Sun 7 Jun');
  });

  it('formats a date in July', () => {
    expect(formatRaceDate('2026-07-05', '10:00')).toBe('Sun 5 Jul · 10:00');
  });

  it('formats a date in August', () => {
    expect(formatRaceDate('2026-08-30', '10:00')).toBe('Sun 30 Aug · 10:00');
  });

  it('handles single-digit days without zero padding', () => {
    expect(formatRaceDate('2026-06-07')).toBe('Sun 7 Jun');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npm test
```

Expected: FAIL — `Cannot find module '../../src/lib/format'`

- [ ] **Step 3: Implement `src/lib/format.ts`**

```typescript
// src/lib/format.ts
const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export function formatRaceDate(date: string, time?: string): string {
  const [year, month, day] = date.split('-').map(Number);
  // Use local date constructor to avoid timezone shifts
  const d = new Date(year, month - 1, day);
  const dayName = DAYS[d.getDay()];
  const monthName = MONTHS[month - 1];
  const dateStr = `${dayName} ${day} ${monthName}`;
  return time ? `${dateStr} · ${time}` : dateStr;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
npm test
```

Expected: PASS — 5 tests passing

- [ ] **Step 5: Commit**

```bash
git add src/lib/format.ts tests/lib/format.test.ts
git commit -m "feat: add date formatting utility with tests"
```

---

## Task 4: Data utilities with tests

**Files:**
- Create: `src/lib/years.ts`
- Create: `src/lib/data.ts`
- Create: `tests/lib/years.test.ts`

- [ ] **Step 1: Write failing tests for `years.ts`**

```typescript
// tests/lib/years.test.ts
import { describe, it, expect } from 'vitest';
import { extractYears } from '../../src/lib/years';

describe('extractYears', () => {
  it('extracts unique years sorted descending', () => {
    const paths = [
      '../data/2026/road-gp/races.json',
      '../data/2026/fell/races.json',
      '../data/2025/road-gp/races.json',
      '../data/2025/fell/races.json',
    ];
    expect(extractYears(paths)).toEqual([2026, 2025]);
  });

  it('returns empty array for no paths', () => {
    expect(extractYears([])).toEqual([]);
  });

  it('handles a single year', () => {
    const paths = ['../data/2026/road-gp/races.json'];
    expect(extractYears(paths)).toEqual([2026]);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npm test
```

Expected: FAIL — `Cannot find module '../../src/lib/years'`

- [ ] **Step 3: Implement `src/lib/years.ts`**

```typescript
// src/lib/years.ts
export function extractYears(paths: string[]): number[] {
  // Path format: "../data/2026/road-gp/races.json" → split index 2 is the year
  const years = paths.map(p => parseInt(p.split('/')[2])).filter(n => !isNaN(n));
  return [...new Set(years)].sort((a, b) => b - a);
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
npm test
```

Expected: PASS — all tests passing

- [ ] **Step 5: Implement `src/lib/data.ts`**

This file uses Astro/Vite's `import.meta.glob` and is not unit tested directly — correctness is verified by the build.

```typescript
// src/lib/data.ts
import type { Race, Series, SiteConfig } from './types';
import { extractYears } from './years';
import configData from '../data/config.json';

const config = configData as SiteConfig;

const raceFiles = import.meta.glob<{ default: Race[] }>(
  '../data/*/*/races.json',
  { eager: true }
);

export function getCurrentYear(): number {
  return config.currentYear;
}

export function getAvailableYears(): number[] {
  return extractYears(Object.keys(raceFiles));
}

export function getRaces(year: number, series: Series): Race[] {
  const key = `../data/${year}/${series}/races.json`;
  return raceFiles[key]?.default ?? [];
}

export function getRace(year: number, series: Series, raceId: string): Race | undefined {
  return getRaces(year, series).find(r => r.id === raceId);
}
```

- [ ] **Step 6: Run full test suite**

```bash
npm test
```

Expected: All tests pass.

- [ ] **Step 7: Verify Astro build still works**

```bash
npm run build
```

Expected: No errors.

- [ ] **Step 8: Commit**

```bash
git add src/lib/years.ts src/lib/data.ts tests/lib/years.test.ts
git commit -m "feat: add data loading utilities with tests"
```

---

## Task 5: Layout component

**Files:**
- Create: `src/components/Layout.astro`

- [ ] **Step 1: Create `src/components/Layout.astro`**

```astro
---
// src/components/Layout.astro
interface Props {
  title: string;
}

const { title } = Astro.props;
const currentPath = Astro.url.pathname;

function isActive(base: string): boolean {
  return currentPath === base || currentPath.startsWith(base + '/');
}
---

<!doctype html>
<html lang="en" data-theme="light">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title} — Inter Club</title>
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  </head>
  <body class="min-h-screen bg-base-200 flex flex-col">
    <header class="bg-base-100 shadow-sm">
      <div class="navbar max-w-4xl mx-auto px-4">
        <div class="navbar-start">
          <a href="/" class="btn btn-ghost text-lg font-bold tracking-tight">Inter Club</a>
        </div>
        <div class="navbar-end gap-1">
          <a
            href="/road-gp/"
            class={`btn btn-ghost btn-sm ${isActive('/road-gp') ? 'btn-active' : ''}`}
          >Road GP</a>
          <a
            href="/fell/"
            class={`btn btn-ghost btn-sm ${isActive('/fell') ? 'btn-active' : ''}`}
          >Fell</a>
        </div>
      </div>
    </header>

    <main class="flex-1 max-w-4xl mx-auto w-full px-4 py-8">
      <slot />
    </main>

    <footer class="footer footer-center p-4 bg-base-100 text-base-content/60 text-sm mt-8">
      <p>Inter Club Running Competition · Lancashire</p>
    </footer>
  </body>
</html>
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/Layout.astro
git commit -m "feat: add Layout component with DaisyUI navbar"
```

---

## Task 6: RaceCard component

**Files:**
- Create: `src/components/RaceCard.astro`

- [ ] **Step 1: Create `src/components/RaceCard.astro`**

```astro
---
// src/components/RaceCard.astro
import type { Race, Series } from '../lib/types';
import { formatRaceDate } from '../lib/format';

interface Props {
  race: Race;
  year: number;
  series: Series;
}

const { race, year, series } = Astro.props;
const { id, name, date, time, location, distance, detailsUrl, image } = race;

const formattedDate = formatRaceDate(date, time);
const detailUrl = `/${series}/${year}/${id}/`;
---

<a href={detailUrl} class="card bg-base-100 shadow-sm border border-base-200 hover:shadow-md transition-shadow no-underline">
  {image && (
    <figure>
      <img src={`/images/${image}`} alt={name} class="w-full h-44 object-cover" loading="lazy" />
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
    {detailsUrl && (
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
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/RaceCard.astro
git commit -m "feat: add RaceCard component"
```

---

## Task 7: YearFilter and RaceList components

**Files:**
- Create: `src/components/YearFilter.astro`
- Create: `src/components/RaceList.astro`

- [ ] **Step 1: Create `src/components/YearFilter.astro`**

```astro
---
// src/components/YearFilter.astro
interface Props {
  years: number[];
  activeYear: number;
  seriesBasePath: string; // e.g. "/road-gp"
  currentYear: number;
}

const { years, activeYear, seriesBasePath, currentYear } = Astro.props;

function yearUrl(year: number): string {
  return year === currentYear ? `${seriesBasePath}/` : `${seriesBasePath}/${year}/`;
}
---

<div class="flex items-center gap-2">
  <span class="text-sm text-base-content/60">Season:</span>
  <select
    class="select select-bordered select-sm"
    onchange="window.location.href = this.value"
    aria-label="Select season year"
  >
    {years.map(year => (
      <option value={yearUrl(year)} selected={year === activeYear}>
        {year}
      </option>
    ))}
  </select>
</div>
```

- [ ] **Step 2: Create `src/components/RaceList.astro`**

```astro
---
// src/components/RaceList.astro
import type { Race, Series } from '../lib/types';
import RaceCard from './RaceCard.astro';
import YearFilter from './YearFilter.astro';

interface Props {
  races: Race[];
  year: number;
  series: Series;
  availableYears: number[];
  currentYear: number;
  seriesBasePath: string;
  seriesLabel: string;
}

const { races, year, series, availableYears, currentYear, seriesBasePath, seriesLabel } = Astro.props;
---

<div>
  <div class="flex items-center justify-between mb-6 flex-wrap gap-3">
    <h1 class="text-2xl font-bold">{seriesLabel} — {year}</h1>
    {availableYears.length > 1 && (
      <YearFilter
        years={availableYears}
        activeYear={year}
        seriesBasePath={seriesBasePath}
        currentYear={currentYear}
      />
    )}
  </div>

  {races.length === 0 ? (
    <p class="text-base-content/60">No races found for {year}.</p>
  ) : (
    <div class="flex flex-col gap-4">
      {races.map(race => (
        <RaceCard race={race} year={year} series={series} />
      ))}
    </div>
  )}
</div>
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add src/components/YearFilter.astro src/components/RaceList.astro
git commit -m "feat: add YearFilter and RaceList components"
```

---

## Task 8: Home page

**Files:**
- Modify: `src/pages/index.astro`

- [ ] **Step 1: Replace the default `src/pages/index.astro`**

```astro
---
// src/pages/index.astro
import Layout from '../components/Layout.astro';
import { getCurrentYear, getRaces } from '../lib/data';

const currentYear = getCurrentYear();
const roadRaces = getRaces(currentYear, 'road-gp');
const fellRaces = getRaces(currentYear, 'fell');
---

<Layout title="Home">
  <div class="mb-8">
    <h1 class="text-3xl font-bold mb-2">Inter Club {currentYear}</h1>
    <p class="text-base-content/70">
      Lancashire's annual running competition between seven clubs, contested across two series.
    </p>
  </div>

  <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
    <a href="/road-gp/" class="card bg-base-100 shadow-sm border border-base-200 hover:shadow-md transition-shadow">
      <div class="card-body">
        <h2 class="card-title">Road Grand Prix</h2>
        <p class="text-base-content/70 text-sm">
          {roadRaces.length} race{roadRaces.length !== 1 ? 's' : ''} · hosted by member clubs · free entry
        </p>
        <div class="card-actions justify-end mt-2">
          <span class="btn btn-primary btn-sm">View schedule →</span>
        </div>
      </div>
    </a>

    <a href="/fell/" class="card bg-base-100 shadow-sm border border-base-200 hover:shadow-md transition-shadow">
      <div class="card-body">
        <h2 class="card-title">Fell Championship</h2>
        <p class="text-base-content/70 text-sm">
          {fellRaces.length} race{fellRaces.length !== 1 ? 's' : ''} · external events · paid entry
        </p>
        <div class="card-actions justify-end mt-2">
          <span class="btn btn-primary btn-sm">View schedule →</span>
        </div>
      </div>
    </a>
  </div>
</Layout>
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: No errors. Check `dist/index.html` exists.

- [ ] **Step 3: Preview the site**

```bash
npm run preview
```

Open `http://localhost:4321` and verify the home page renders with both series cards.

- [ ] **Step 4: Commit**

```bash
git add src/pages/index.astro
git commit -m "feat: add home page with series summary cards"
```

---

## Task 9: Road GP schedule pages

**Files:**
- Create: `src/pages/road-gp/index.astro`
- Create: `src/pages/road-gp/[year]/index.astro`

- [ ] **Step 1: Create `src/pages/road-gp/index.astro`**

```astro
---
// src/pages/road-gp/index.astro
import Layout from '../../components/Layout.astro';
import RaceList from '../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears();
const races = getRaces(currentYear, 'road-gp');
---

<Layout title="Road Grand Prix">
  <RaceList
    races={races}
    year={currentYear}
    series="road-gp"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/road-gp"
    seriesLabel="Road Grand Prix"
  />
</Layout>
```

- [ ] **Step 2: Create `src/pages/road-gp/[year]/index.astro`**

```astro
---
// src/pages/road-gp/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';

export async function getStaticPaths() {
  const years = getAvailableYears();
  return years.map(year => ({ params: { year: String(year) } }));
}

const { year: yearParam } = Astro.params;
const year = parseInt(yearParam);
const currentYear = getCurrentYear();
const availableYears = getAvailableYears();
const races = getRaces(year, 'road-gp');
---

<Layout title={`Road Grand Prix ${year}`}>
  <RaceList
    races={races}
    year={year}
    series="road-gp"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/road-gp"
    seriesLabel="Road Grand Prix"
  />
</Layout>
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

Expected: `dist/road-gp/index.html` and `dist/road-gp/2026/index.html` both exist.

- [ ] **Step 4: Preview and check**

```bash
npm run preview
```

Navigate to `http://localhost:4321/road-gp/` — verify race cards appear. Check the year dropdown navigates to `/road-gp/2026/`.

- [ ] **Step 5: Commit**

```bash
git add src/pages/road-gp/
git commit -m "feat: add Road GP schedule pages with year navigation"
```

---

## Task 10: Fell schedule pages

**Files:**
- Create: `src/pages/fell/index.astro`
- Create: `src/pages/fell/[year]/index.astro`

- [ ] **Step 1: Create `src/pages/fell/index.astro`**

```astro
---
// src/pages/fell/index.astro
import Layout from '../../components/Layout.astro';
import RaceList from '../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears();
const races = getRaces(currentYear, 'fell');
---

<Layout title="Fell Championship">
  <RaceList
    races={races}
    year={currentYear}
    series="fell"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/fell"
    seriesLabel="Fell Championship"
  />
</Layout>
```

- [ ] **Step 2: Create `src/pages/fell/[year]/index.astro`**

```astro
---
// src/pages/fell/[year]/index.astro
import Layout from '../../../components/Layout.astro';
import RaceList from '../../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../../lib/data';

export async function getStaticPaths() {
  const years = getAvailableYears();
  return years.map(year => ({ params: { year: String(year) } }));
}

const { year: yearParam } = Astro.params;
const year = parseInt(yearParam);
const currentYear = getCurrentYear();
const availableYears = getAvailableYears();
const races = getRaces(year, 'fell');
---

<Layout title={`Fell Championship ${year}`}>
  <RaceList
    races={races}
    year={year}
    series="fell"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/fell"
    seriesLabel="Fell Championship"
  />
</Layout>
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

Expected: `dist/fell/index.html` and `dist/fell/2026/index.html` exist.

- [ ] **Step 4: Preview and check**

```bash
npm run preview
```

Navigate to `http://localhost:4321/fell/` — verify all four fell races appear as cards.

- [ ] **Step 5: Commit**

```bash
git add src/pages/fell/
git commit -m "feat: add Fell Championship schedule pages"
```

---

## Task 11: Race detail pages

**Files:**
- Create: `src/pages/road-gp/[year]/[raceId].astro`
- Create: `src/pages/fell/[year]/[raceId].astro`

Note: Race detail URLs are `/road-gp/[year]/[raceId]/` and `/fell/[year]/[raceId]/`. Year is always included so there is no ambiguity with the year filter URLs.

- [ ] **Step 1: Create `src/pages/road-gp/[year]/[raceId].astro`**

```astro
---
// src/pages/road-gp/[year]/[raceId].astro
import Layout from '../../../components/Layout.astro';
import { getAvailableYears, getRaces, getRace } from '../../../lib/data';
import { formatRaceDate } from '../../../lib/format';
import type { Race } from '../../../lib/types';

export async function getStaticPaths() {
  const years = getAvailableYears();
  return years.flatMap(year =>
    getRaces(year, 'road-gp').map(race => ({
      params: { year: String(year), raceId: race.id },
      props: { race, year },
    }))
  );
}

interface Props {
  race: Race;
  year: number;
}

const { race, year } = Astro.props;
const { name, date, time, location, distance, detailsUrl, image } = race;
const formattedDate = formatRaceDate(date, time);
---

<Layout title={name}>
  <div class="mb-4">
    <a href="/road-gp/" class="btn btn-ghost btn-sm gap-1 -ml-3">← Road Grand Prix</a>
  </div>

  <div class="card bg-base-100 shadow-sm border border-base-200">
    {image && (
      <figure>
        <img src={`/images/${image}`} alt={name} class="w-full h-56 object-cover" />
      </figure>
    )}
    <div class="card-body gap-3">
      <p class="text-sm text-base-content/50 uppercase tracking-wide font-medium">{formattedDate}</p>
      <h1 class="text-2xl font-bold">{name}</h1>

      <div class="divider my-1"></div>

      <dl class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {location && (
          <div>
            <dt class="text-xs text-base-content/50 uppercase tracking-wide">Location</dt>
            <dd class="font-medium">{location}</dd>
          </div>
        )}
        {distance && (
          <div>
            <dt class="text-xs text-base-content/50 uppercase tracking-wide">Distance</dt>
            <dd class="font-medium">{distance}</dd>
          </div>
        )}
      </dl>

      {detailsUrl && (
        <div class="card-actions mt-2">
          <a href={detailsUrl} target="_blank" rel="noopener noreferrer" class="btn btn-primary">
            View race details ↗
          </a>
        </div>
      )}
    </div>
  </div>
</Layout>
```

- [ ] **Step 2: Create `src/pages/fell/[year]/[raceId].astro`**

```astro
---
// src/pages/fell/[year]/[raceId].astro
import Layout from '../../../components/Layout.astro';
import { getAvailableYears, getRaces } from '../../../lib/data';
import { formatRaceDate } from '../../../lib/format';
import type { Race } from '../../../lib/types';

export async function getStaticPaths() {
  const years = getAvailableYears();
  return years.flatMap(year =>
    getRaces(year, 'fell').map(race => ({
      params: { year: String(year), raceId: race.id },
      props: { race, year },
    }))
  );
}

interface Props {
  race: Race;
  year: number;
}

const { race, year } = Astro.props;
const { name, date, time, location, distance, detailsUrl, image } = race;
const formattedDate = formatRaceDate(date, time);
---

<Layout title={name}>
  <div class="mb-4">
    <a href="/fell/" class="btn btn-ghost btn-sm gap-1 -ml-3">← Fell Championship</a>
  </div>

  <div class="card bg-base-100 shadow-sm border border-base-200">
    {image && (
      <figure>
        <img src={`/images/${image}`} alt={name} class="w-full h-56 object-cover" />
      </figure>
    )}
    <div class="card-body gap-3">
      <p class="text-sm text-base-content/50 uppercase tracking-wide font-medium">{formattedDate}</p>
      <h1 class="text-2xl font-bold">{name}</h1>

      <div class="divider my-1"></div>

      <dl class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        {location && (
          <div>
            <dt class="text-xs text-base-content/50 uppercase tracking-wide">Location</dt>
            <dd class="font-medium">{location}</dd>
          </div>
        )}
        {distance && (
          <div>
            <dt class="text-xs text-base-content/50 uppercase tracking-wide">Distance</dt>
            <dd class="font-medium">{distance}</dd>
          </div>
        )}
      </dl>

      {detailsUrl && (
        <div class="card-actions mt-2">
          <a href={detailsUrl} target="_blank" rel="noopener noreferrer" class="btn btn-primary">
            View race details ↗
          </a>
        </div>
      )}
    </div>
  </div>
</Layout>
```

- [ ] **Step 3: Verify build passes**

```bash
npm run build
```

Expected: Detail pages generated, e.g. `dist/road-gp/2026/bwf-5/index.html`.

- [ ] **Step 4: Preview and check the full site**

```bash
npm run preview
```

Verify:
- `/` — home shows both series cards
- `/road-gp/` — 7 race cards
- `/fell/` — 4 race cards
- `/road-gp/2026/bwf-5/` — race detail for BWF 5
- Race cards on the schedule pages link to the correct detail page
- Nav active state highlights correctly on each section

- [ ] **Step 5: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId].astro src/pages/fell/[year]/[raceId].astro
git commit -m "feat: add race detail pages for Road GP and Fell"
```

---

## Task 12: Final verification and mobile check

- [ ] **Step 1: Run full test suite**

```bash
npm test
```

Expected: All tests pass.

- [ ] **Step 2: Run production build**

```bash
npm run build
```

Expected: No errors or warnings about missing pages.

- [ ] **Step 3: Preview and check on mobile viewport**

```bash
npm run preview
```

Open browser dev tools, set viewport to 375px wide (iPhone SE). Verify:
- Nav does not overflow — if it does, adjust `navbar-end` to use `hidden sm:flex` and add a hamburger for small screens (out of scope for Phase 1, note as known gap)
- Race cards are single-column and fully readable
- Detail page fields stack vertically
- Buttons are large enough to tap

- [ ] **Step 4: Add `.gitignore` entries**

Verify `dist/` and `.superpowers/` are in `.gitignore`. Add if missing:

```
dist/
.superpowers/
```

- [ ] **Step 5: Final commit**

```bash
git add .gitignore
git commit -m "chore: ensure dist and superpowers dirs are gitignored"
```
