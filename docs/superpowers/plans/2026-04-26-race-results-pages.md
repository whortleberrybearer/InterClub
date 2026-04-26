# Race Results Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add individual race results pages to the InterClub site, with CSV-backed data, per-year club/category config, and client-side filtering.

**Architecture:** Results CSVs are loaded at build time via `import.meta.glob` with `?raw`, parsed into typed arrays, and serialised into JSON islands in the page HTML. Client-side vanilla JS handles filtering reactively. Clubs and age categories are driven by per-year config files, not inferred from results.

**Tech Stack:** Astro v6, TypeScript, Tailwind CSS v4 + DaisyUI v5, Vitest

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `src/lib/types.ts` | Modify | Add `RaceResult`, `Club`, `SeriesConfig` types |
| `src/lib/results.ts` | Create | CSV parsing + glob-based data loading |
| `tests/lib/results.test.ts` | Create | Unit tests for CSV parser |
| `src/data/2026/clubs.json` | Create | Competing clubs for 2026 |
| `src/data/2026/road-gp/config.json` | Create | Road GP series config (categories) |
| `src/data/2026/fell/config.json` | Create | Fell series config (categories) |
| `src/data/2026/road-gp/results/bwf-5-provisional.csv` | Create | Sample results CSV for development |
| `src/pages/road-gp/[year]/[raceId]/results.astro` | Create | Road GP individual results page |
| `src/pages/fell/[year]/[raceId]/results.astro` | Create | Fell individual results page |
| `src/pages/road-gp/[year]/[raceId].astro` | Modify | Add View Results link |
| `src/pages/fell/[year]/[raceId].astro` | Modify | Add View Results link |

---

### Task 1: Add types

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Add the new types**

Open `src/lib/types.ts` and append:

```typescript
export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;        // club id (e.g. 'blackpool') or 'Guest'
  category: string;   // e.g. 'SEN', 'V35', 'U17'
  sex: string;        // 'M' or 'F'
  time: string;       // 'MM:SS', may be empty
}

export interface Club {
  id: string;
  name: string;
  shortName: string;
  logo: string;        // filename in /public/images/clubs/, may not exist yet
}

export interface SeriesConfig {
  categories: string[];
}
```

- [ ] **Step 2: Verify TypeScript compiles**

```bash
npm run build 2>&1 | head -20
```

Expected: build succeeds (no new errors).

- [ ] **Step 3: Commit**

```bash
git add src/lib/types.ts
git commit -m "feat: add RaceResult, Club, SeriesConfig types"
```

---

### Task 2: Create per-year data config files

**Files:**
- Create: `src/data/2026/clubs.json`
- Create: `src/data/2026/road-gp/config.json`
- Create: `src/data/2026/fell/config.json`

- [ ] **Step 1: Create clubs.json for 2026**

```json
[
  { "id": "blackpool", "name": "Blackpool Wyre & Fylde AC", "shortName": "BWF", "logo": "blackpool.svg" },
  { "id": "chorley",   "name": "Chorley A&TC",              "shortName": "CAT", "logo": "chorley.svg"  },
  { "id": "lytham",    "name": "Lytham St Annes RR",        "shortName": "LSA", "logo": "lytham.svg"   },
  { "id": "preston",   "name": "Preston Harriers",           "shortName": "PH",  "logo": "preston.svg"  },
  { "id": "red-rose",  "name": "Red Rose RR",                "shortName": "RR",  "logo": "red-rose.svg" },
  { "id": "thornton",  "name": "Thornton Cleveleys RC",      "shortName": "TC",  "logo": "thornton.svg" },
  { "id": "wesham",    "name": "Wesham RR",                  "shortName": "WRR", "logo": "wesham.svg"   }
]
```

Write to `src/data/2026/clubs.json`.

- [ ] **Step 2: Create road-gp config**

Write to `src/data/2026/road-gp/config.json`:

```json
{
  "categories": ["U17", "U20", "U23", "SEN", "V35", "V40", "V45", "V50", "V55", "V60", "V65", "V70", "V75", "V80"]
}
```

- [ ] **Step 3: Create fell config**

Write to `src/data/2026/fell/config.json`:

```json
{
  "categories": ["SEN", "V40", "V50", "V60", "V70"]
}
```

- [ ] **Step 4: Commit**

```bash
git add src/data/2026/clubs.json src/data/2026/road-gp/config.json src/data/2026/fell/config.json
git commit -m "feat: add 2026 clubs and series category config"
```

---

### Task 3: Create a sample results CSV

**Files:**
- Create: `src/data/2026/road-gp/results/bwf-5-provisional.csv`

This gives the rest of the tasks real data to work with.

- [ ] **Step 1: Create the directory and CSV**

Write to `src/data/2026/road-gp/results/bwf-5-provisional.csv`:

```
position,ic_position,first_name,last_name,club,category,sex,time
1,1,Luke,Minns,blackpool,V35,M,19:35
2,2,Rob,Danson,preston,V35,M,19:38
3,3,Jude,Cowan,blackpool,SEN,M,20:33
4,4,Mike,Toft,lytham,V35,M,20:45
5,5,Max,Swarbrick,wesham,U23,M,21:09
6,6,Jake,Rodwell,lytham,U23,M,21:10
7,7,Simon,Croft,red-rose,V40,M,21:11
8,8,John,Townsend,wesham,V40,M,21:14
9,9,Adam,Wilding,wesham,SEN,M,21:19
10,10,Archie,Bellfield,blackpool,U17,M,21:37
11,,T.,Guest,Guest,SEN,M,21:44
12,11,Noah,Cox,blackpool,U23,M,21:40
13,12,Luke,Suffolk,preston,U23,M,21:42
14,13,Andy,Cottam,preston,V45,M,21:55
15,14,Emily,Simm,blackpool,V35,F,22:01
```

- [ ] **Step 2: Commit**

```bash
git add src/data/2026/road-gp/results/bwf-5-provisional.csv
git commit -m "feat: add provisional Blackpool results CSV for development"
```

---

### Task 4: Write failing tests for the CSV parser

**Files:**
- Create: `tests/lib/results.test.ts`

- [ ] **Step 1: Write the tests**

```typescript
import { describe, it, expect } from 'vitest';
import { parseResultsCsv } from '../../src/lib/results';

describe('parseResultsCsv', () => {
  const sample = [
    'position,ic_position,first_name,last_name,club,category,sex,time',
    '1,1,Luke,Minns,blackpool,V35,M,19:35',
    '2,2,Rob,Danson,preston,V35,M,19:38',
    '3,,T.,Guest,Guest,SEN,M,20:00',
  ].join('\n');

  it('returns one row per data line', () => {
    expect(parseResultsCsv(sample)).toHaveLength(3);
  });

  it('parses position and icPosition as numbers', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.position).toBe(1);
    expect(first.icPosition).toBe(1);
  });

  it('parses icPosition as null when empty (guest runner)', () => {
    const results = parseResultsCsv(sample);
    expect(results[2].icPosition).toBeNull();
  });

  it('parses position as null when empty', () => {
    const csv = 'position,ic_position,first_name,last_name,club,category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
    const [row] = parseResultsCsv(csv);
    expect(row.position).toBeNull();
  });

  it('maps all string fields correctly', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.firstName).toBe('Luke');
    expect(first.lastName).toBe('Minns');
    expect(first.club).toBe('blackpool');
    expect(first.category).toBe('V35');
    expect(first.sex).toBe('M');
    expect(first.time).toBe('19:35');
  });

  it('handles Windows line endings (CRLF)', () => {
    const crlf = sample.replace(/\n/g, '\r\n');
    expect(parseResultsCsv(crlf)).toHaveLength(3);
  });

  it('returns empty array for header-only CSV', () => {
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,category,sex,time')).toHaveLength(0);
  });

  it('returns empty array for empty string', () => {
    expect(parseResultsCsv('')).toHaveLength(0);
  });
});
```

- [ ] **Step 2: Run the tests — expect FAIL**

```bash
npm test
```

Expected: FAIL with `Cannot find module '../../src/lib/results'`

---

### Task 5: Implement the CSV parser

**Files:**
- Create: `src/lib/results.ts`

- [ ] **Step 1: Create the file with the pure parser**

```typescript
import type { Club, RaceResult, Series, SeriesConfig } from './types';

export function parseResultsCsv(csv: string): RaceResult[] {
  const lines = csv.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trim().split('\n');
  if (lines.length < 2) return [];

  const headers = lines[0].split(',');
  const idx = (name: string) => headers.indexOf(name);

  return lines.slice(1).filter(l => l.trim()).map(line => {
    const cols = line.split(',');
    const get = (name: string) => cols[idx(name)]?.trim() ?? '';
    const num = (name: string) => { const v = get(name); return v ? parseInt(v) : null; };
    return {
      position: num('position'),
      icPosition: num('ic_position'),
      firstName: get('first_name'),
      lastName: get('last_name'),
      club: get('club'),
      category: get('category'),
      sex: get('sex'),
      time: get('time'),
    };
  });
}

const csvFiles = import.meta.glob<string>('../data/*/road-gp/results/*.csv', {
  query: '?raw', import: 'default', eager: true,
});
const fellCsvFiles = import.meta.glob<string>('../data/*/fell/results/*.csv', {
  query: '?raw', import: 'default', eager: true,
});
const clubFiles = import.meta.glob<{ default: Club[] }>('../data/*/clubs.json', { eager: true });
const roadConfigFiles = import.meta.glob<{ default: SeriesConfig }>('../data/*/road-gp/config.json', { eager: true });
const fellConfigFiles = import.meta.glob<{ default: SeriesConfig }>('../data/*/fell/config.json', { eager: true });

function csvFilesForSeries(series: Series) {
  return series === 'road-gp' ? csvFiles : fellCsvFiles;
}

interface ResultsInfo {
  results: RaceResult[];
  provisional: boolean;
}

function parseResultsPath(path: string): { year: number; raceId: string; provisional: boolean } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/results\/(.+)\.csv$/);
  if (!match) return null;
  const year = parseInt(match[1]);
  const filename = match[2];
  const provisional = filename.endsWith('-provisional');
  const raceId = provisional ? filename.slice(0, -'-provisional'.length) : filename;
  return { year, raceId, provisional };
}

export function getResultsInfo(year: number, series: Series, raceId: string): ResultsInfo | null {
  const files = csvFilesForSeries(series);
  const provisionalKey = Object.keys(files).find(k => k.includes(`/${year}/${series}/results/${raceId}-provisional.csv`));
  const finalKey = Object.keys(files).find(k => k.includes(`/${year}/${series}/results/${raceId}.csv`) && !k.includes('-provisional'));

  const key = finalKey ?? provisionalKey;
  if (!key) return null;

  return {
    results: parseResultsCsv(files[key]),
    provisional: !finalKey && !!provisionalKey,
  };
}

export function hasResults(year: number, series: Series, raceId: string): boolean {
  const files = csvFilesForSeries(series);
  return Object.keys(files).some(k => k.includes(`/${year}/${series}/results/${raceId}`));
}

export function getResultsStaticPaths(series: Series) {
  const files = csvFilesForSeries(series);
  const seen = new Map<string, { year: number; raceId: string; provisional: boolean }>();

  for (const path of Object.keys(files)) {
    const parsed = parseResultsPath(path);
    if (!parsed) continue;
    const { year, raceId, provisional } = parsed;
    const key = `${year}/${raceId}`;
    const existing = seen.get(key);
    // Final (non-provisional) takes precedence; otherwise first seen wins
    if (!existing || (!provisional && existing.provisional)) {
      seen.set(key, { year, raceId, provisional });
    }
  }

  return [...seen.values()].map(({ year, raceId, provisional }) => {
    const info = getResultsInfo(year, series, raceId)!;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    return {
      params: { year: String(year), raceId },
      props: { year, raceId, results: info.results, provisional, clubs, config },
    };
  });
}

export function getClubs(year: number): Club[] {
  return clubFiles[`../data/${year}/clubs.json`]?.default ?? [];
}

export function getSeriesConfig(year: number, series: Series): SeriesConfig {
  const files = series === 'road-gp' ? roadConfigFiles : fellConfigFiles;
  return files[`../data/${year}/${series}/config.json`]?.default ?? { categories: [] };
}
```

- [ ] **Step 2: Run the tests — expect PASS**

```bash
npm test
```

Expected: all 8 tests pass.

- [ ] **Step 3: Commit**

```bash
git add src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat: add CSV parser and results data loading utilities"
```

---

### Task 6: Create the road-gp results page

**Files:**
- Create: `src/pages/road-gp/[year]/[raceId]/results.astro`

Note: Astro supports having both `[raceId].astro` and `[raceId]/results.astro` in the same parent directory — they match different URL depths and do not conflict.

- [ ] **Step 1: Create the page**

```astro
---
// src/pages/road-gp/[year]/[raceId]/results.astro
import Layout from '../../../../components/Layout.astro';
import { getRace } from '../../../../lib/data';
import { getResultsStaticPaths } from '../../../../lib/results';
import type { Club, RaceResult, SeriesConfig } from '../../../../lib/types';

export async function getStaticPaths() {
  return getResultsStaticPaths('road-gp');
}

interface Props {
  year: number;
  raceId: string;
  results: RaceResult[];
  provisional: boolean;
  clubs: Club[];
  config: SeriesConfig;
}

const { year, raceId, results, provisional, clubs, config } = Astro.props;
const race = getRace(year, 'road-gp', raceId);
const title = race?.name ?? raceId;
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
---

<Layout title={`${title} — Results`}>
  <div class="mb-4 flex items-center gap-2">
    <a href={`/road-gp/${year}/${raceId}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← {title}</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">{title} Results</h1>
      {provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    {race && <p class="text-sm text-base-content/60 mt-1">{year}</p>}
  </div>

  <!-- Filter bar -->
  <div class="bg-base-100 border border-base-200 rounded-lg p-3 mb-4 flex flex-col sm:flex-row gap-2 sm:items-center flex-wrap">
    <input
      id="filter-name"
      type="search"
      placeholder="Search name…"
      class="input input-bordered input-sm w-full sm:w-40"
    />
    <select id="filter-club" class="select select-bordered select-sm w-full sm:w-auto">
      <option value="">All Clubs</option>
      {clubs.map(c => <option value={c.id}>{c.name}</option>)}
    </select>
    <select id="filter-cat" class="select select-bordered select-sm w-full sm:w-auto">
      <option value="">All Categories</option>
      {config.categories.map(cat => <option value={cat}>{cat}</option>)}
    </select>
    <div class="flex gap-1">
      <button class="btn btn-sm btn-active" data-sex="" id="sex-all">All</button>
      <button class="btn btn-sm btn-ghost" data-sex="M" id="sex-m">Men</button>
      <button class="btn btn-sm btn-ghost" data-sex="F" id="sex-f">Women</button>
    </div>
  </div>

  <!-- Results table -->
  <div class="overflow-x-auto">
    <table class="table table-sm w-full">
      <thead>
        <tr>
          <th class="hidden sm:table-cell">Pos</th>
          <th>IC</th>
          <th>Name</th>
          <th>Cat</th>
          <th>Club</th>
          <th class="text-right">Time</th>
        </tr>
      </thead>
      <tbody id="results-tbody">
        {results.map(r => (
          <tr>
            <td class="hidden sm:table-cell">{r.position ?? '–'}</td>
            <td>{r.icPosition ?? '–'}</td>
            <td>
              <span class="sm:hidden">{r.firstName[0] ?? ''}. {r.lastName}</span>
              <span class="hidden sm:inline">{r.firstName} {r.lastName}</span>
            </td>
            <td>{r.category}</td>
            <td>
              <span class="sm:hidden">{r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.shortName ?? r.club)}</span>
              <span class="hidden sm:inline">{r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.name ?? r.club)}</span>
            </td>
            <td class="text-right tabular-nums">{r.time || '–'}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>

  <!-- Footer links -->
  <div class="mt-6 flex gap-3 flex-wrap">
    <a href={`/road-gp/${year}/${raceId}/team-results`} class="btn btn-outline btn-sm">
      View Team Results
    </a>
  </div>

  <!-- Data island for client-side filtering -->
  <script type="application/json" id="results-data" set:html={JSON.stringify(results)}></script>
  <script type="application/json" id="clubs-data" set:html={JSON.stringify(clubs)}></script>
</Layout>

<script>
  const allResults: Array<{
    position: number | null; icPosition: number | null;
    firstName: string; lastName: string;
    club: string; category: string; sex: string; time: string;
  }> = JSON.parse(document.getElementById('results-data')!.textContent!);

  const clubs: Array<{ id: string; name: string; shortName: string }> =
    JSON.parse(document.getElementById('clubs-data')!.textContent!);
  const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));

  const nameInput = document.getElementById('filter-name') as HTMLInputElement;
  const clubSelect = document.getElementById('filter-club') as HTMLSelectElement;
  const catSelect = document.getElementById('filter-cat') as HTMLSelectElement;
  const tbody = document.getElementById('results-tbody')!;

  let activeSex = '';

  document.querySelectorAll<HTMLButtonElement>('[data-sex]').forEach(btn => {
    btn.addEventListener('click', () => {
      activeSex = btn.dataset.sex ?? '';
      document.querySelectorAll('[data-sex]').forEach(b =>
        b.classList.toggle('btn-active', (b as HTMLElement).dataset.sex === activeSex)
      );
      document.querySelectorAll('[data-sex]').forEach(b =>
        b.classList.toggle('btn-ghost', (b as HTMLElement).dataset.sex !== activeSex)
      );
      render();
    });
  });

  [nameInput, clubSelect, catSelect].forEach(el => el.addEventListener('input', render));

  function row(r: typeof allResults[0]): string {
    const name = r.firstName[0] ? `${r.firstName[0]}.` : '';
    const clubShort = r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.shortName ?? r.club);
    const clubFull = r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.name ?? r.club);
    return `<tr>
      <td class="hidden sm:table-cell">${r.position ?? '–'}</td>
      <td>${r.icPosition ?? '–'}</td>
      <td>
        <span class="sm:hidden">${name} ${r.lastName}</span>
        <span class="hidden sm:inline">${r.firstName} ${r.lastName}</span>
      </td>
      <td>${r.category}</td>
      <td>
        <span class="sm:hidden">${clubShort}</span>
        <span class="hidden sm:inline">${clubFull}</span>
      </td>
      <td class="text-right tabular-nums">${r.time || '–'}</td>
    </tr>`;
  }

  function render() {
    const name = nameInput.value.toLowerCase();
    const club = clubSelect.value;
    const cat = catSelect.value;

    const filtered = allResults.filter(r => {
      if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name)) return false;
      if (club && r.club !== club) return false;
      if (cat && r.category !== cat) return false;
      if (activeSex && r.sex !== activeSex) return false;
      return true;
    });

    tbody.innerHTML = filtered.map(row).join('');
  }
</script>
```

- [ ] **Step 2: Verify the build**

```bash
npm run build 2>&1 | head -30
```

Expected: build succeeds and outputs a `/road-gp/2026/bwf-5/results` page.

- [ ] **Step 3: Check the page in dev**

```bash
npm run dev
```

Open `http://localhost:4321/road-gp/2026/bwf-5/results` and verify:
- Table renders with 15 rows
- "Provisional" badge is visible
- Name search filters rows as you type
- Club dropdown filters to a single club's runners
- Category dropdown filters by age group
- Sex buttons toggle between All / Men / Women
- On narrow viewport (< 640px): Pos column hidden, abbreviated names and club codes shown

- [ ] **Step 4: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/results.astro
git commit -m "feat: add road-gp results page with client-side filtering"
```

---

### Task 7: Create the fell results page

**Files:**
- Create: `src/pages/fell/[year]/[raceId]/results.astro`

- [ ] **Step 1: Create the page**

This is identical to the road-gp results page with two differences: the series label and the import paths (one extra `../` level deeper is not needed — both are at the same depth).

```astro
---
// src/pages/fell/[year]/[raceId]/results.astro
import Layout from '../../../../components/Layout.astro';
import { getRace } from '../../../../lib/data';
import { getResultsStaticPaths } from '../../../../lib/results';
import type { Club, RaceResult, SeriesConfig } from '../../../../lib/types';

export async function getStaticPaths() {
  return getResultsStaticPaths('fell');
}

interface Props {
  year: number;
  raceId: string;
  results: RaceResult[];
  provisional: boolean;
  clubs: Club[];
  config: SeriesConfig;
}

const { year, raceId, results, provisional, clubs, config } = Astro.props;
const race = getRace(year, 'fell', raceId);
const title = race?.name ?? raceId;
const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));
---

<Layout title={`${title} — Results`}>
  <div class="mb-4 flex items-center gap-2">
    <a href={`/fell/${year}/${raceId}`} class="btn btn-ghost btn-sm gap-1 -ml-3">← {title}</a>
  </div>

  <div class="mb-6">
    <div class="flex items-center gap-3 flex-wrap">
      <h1 class="text-2xl font-bold">{title} Results</h1>
      {provisional && (
        <span class="badge badge-warning badge-lg">Provisional</span>
      )}
    </div>
    {race && <p class="text-sm text-base-content/60 mt-1">{year}</p>}
  </div>

  <div class="bg-base-100 border border-base-200 rounded-lg p-3 mb-4 flex flex-col sm:flex-row gap-2 sm:items-center flex-wrap">
    <input
      id="filter-name"
      type="search"
      placeholder="Search name…"
      class="input input-bordered input-sm w-full sm:w-40"
    />
    <select id="filter-club" class="select select-bordered select-sm w-full sm:w-auto">
      <option value="">All Clubs</option>
      {clubs.map(c => <option value={c.id}>{c.name}</option>)}
    </select>
    <select id="filter-cat" class="select select-bordered select-sm w-full sm:w-auto">
      <option value="">All Categories</option>
      {config.categories.map(cat => <option value={cat}>{cat}</option>)}
    </select>
    <div class="flex gap-1">
      <button class="btn btn-sm btn-active" data-sex="">All</button>
      <button class="btn btn-sm btn-ghost" data-sex="M">Men</button>
      <button class="btn btn-sm btn-ghost" data-sex="F">Women</button>
    </div>
  </div>

  <div class="overflow-x-auto">
    <table class="table table-sm w-full">
      <thead>
        <tr>
          <th class="hidden sm:table-cell">Pos</th>
          <th>IC</th>
          <th>Name</th>
          <th>Cat</th>
          <th>Club</th>
          <th class="text-right">Time</th>
        </tr>
      </thead>
      <tbody id="results-tbody">
        {results.map(r => (
          <tr>
            <td class="hidden sm:table-cell">{r.position ?? '–'}</td>
            <td>{r.icPosition ?? '–'}</td>
            <td>
              <span class="sm:hidden">{r.firstName[0] ?? ''}. {r.lastName}</span>
              <span class="hidden sm:inline">{r.firstName} {r.lastName}</span>
            </td>
            <td>{r.category}</td>
            <td>
              <span class="sm:hidden">{r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.shortName ?? r.club)}</span>
              <span class="hidden sm:inline">{r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.name ?? r.club)}</span>
            </td>
            <td class="text-right tabular-nums">{r.time || '–'}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>

  <div class="mt-6 flex gap-3 flex-wrap">
    <a href={`/fell/${year}/${raceId}/team-results`} class="btn btn-outline btn-sm">
      View Team Results
    </a>
  </div>

  <script type="application/json" id="results-data" set:html={JSON.stringify(results)}></script>
  <script type="application/json" id="clubs-data" set:html={JSON.stringify(clubs)}></script>
</Layout>

<script>
  const allResults: Array<{
    position: number | null; icPosition: number | null;
    firstName: string; lastName: string;
    club: string; category: string; sex: string; time: string;
  }> = JSON.parse(document.getElementById('results-data')!.textContent!);

  const clubs: Array<{ id: string; name: string; shortName: string }> =
    JSON.parse(document.getElementById('clubs-data')!.textContent!);
  const clubById = Object.fromEntries(clubs.map(c => [c.id, c]));

  const nameInput = document.getElementById('filter-name') as HTMLInputElement;
  const clubSelect = document.getElementById('filter-club') as HTMLSelectElement;
  const catSelect = document.getElementById('filter-cat') as HTMLSelectElement;
  const tbody = document.getElementById('results-tbody')!;

  let activeSex = '';

  document.querySelectorAll<HTMLButtonElement>('[data-sex]').forEach(btn => {
    btn.addEventListener('click', () => {
      activeSex = btn.dataset.sex ?? '';
      document.querySelectorAll('[data-sex]').forEach(b =>
        b.classList.toggle('btn-active', (b as HTMLElement).dataset.sex === activeSex)
      );
      document.querySelectorAll('[data-sex]').forEach(b =>
        b.classList.toggle('btn-ghost', (b as HTMLElement).dataset.sex !== activeSex)
      );
      render();
    });
  });

  [nameInput, clubSelect, catSelect].forEach(el => el.addEventListener('input', render));

  function row(r: typeof allResults[0]): string {
    const name = r.firstName[0] ? `${r.firstName[0]}.` : '';
    const clubShort = r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.shortName ?? r.club);
    const clubFull = r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.name ?? r.club);
    return `<tr>
      <td class="hidden sm:table-cell">${r.position ?? '–'}</td>
      <td>${r.icPosition ?? '–'}</td>
      <td>
        <span class="sm:hidden">${name} ${r.lastName}</span>
        <span class="hidden sm:inline">${r.firstName} ${r.lastName}</span>
      </td>
      <td>${r.category}</td>
      <td>
        <span class="sm:hidden">${clubShort}</span>
        <span class="hidden sm:inline">${clubFull}</span>
      </td>
      <td class="text-right tabular-nums">${r.time || '–'}</td>
    </tr>`;
  }

  function render() {
    const name = nameInput.value.toLowerCase();
    const club = clubSelect.value;
    const cat = catSelect.value;

    const filtered = allResults.filter(r => {
      if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name)) return false;
      if (club && r.club !== club) return false;
      if (cat && r.category !== cat) return false;
      if (activeSex && r.sex !== activeSex) return false;
      return true;
    });

    tbody.innerHTML = filtered.map(row).join('');
  }
</script>
```

- [ ] **Step 2: Build to verify**

```bash
npm run build 2>&1 | head -20
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/pages/fell/[year]/[raceId]/results.astro
git commit -m "feat: add fell results page with client-side filtering"
```

---

### Task 8: Add View Results link to race detail pages

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId].astro`
- Modify: `src/pages/fell/[year]/[raceId].astro`

- [ ] **Step 1: Update road-gp race detail page**

Add the import at the top of the frontmatter in `src/pages/road-gp/[year]/[raceId].astro`:

```typescript
import { hasResults } from '../../../lib/results';
```

Add after the existing `const formattedDate = ...` line:

```typescript
const resultsExist = hasResults(year, 'road-gp', race.id);
```

Add inside the `<div class="card-actions mt-2">` block (create the block if `detailsUrl` is absent — wrap both in one `card-actions` div):

Replace the existing `card-actions` section:

```astro
{(detailsUrl || resultsExist) && (
  <div class="card-actions mt-2 flex-wrap">
    {detailsUrl && (
      <a href={detailsUrl} target="_blank" rel="noopener noreferrer" class="btn btn-primary">
        View race details ↗
      </a>
    )}
    {resultsExist && (
      <a href={`/road-gp/${year}/${race.id}/results`} class="btn btn-outline">
        View Results
      </a>
    )}
  </div>
)}
```

- [ ] **Step 2: Update fell race detail page**

Apply the same change to `src/pages/fell/[year]/[raceId].astro`:

```typescript
import { hasResults } from '../../../lib/results';
```

```typescript
const resultsExist = hasResults(year, 'fell', race.id);
```

```astro
{(detailsUrl || resultsExist) && (
  <div class="card-actions mt-2 flex-wrap">
    {detailsUrl && (
      <a href={detailsUrl} target="_blank" rel="noopener noreferrer" class="btn btn-primary">
        View race details ↗
      </a>
    )}
    {resultsExist && (
      <a href={`/fell/${year}/${race.id}/results`} class="btn btn-outline">
        View Results
      </a>
    )}
  </div>
)}
```

- [ ] **Step 3: Build and verify**

```bash
npm run build 2>&1 | head -20
```

Expected: build succeeds.

- [ ] **Step 4: Check in dev**

```bash
npm run dev
```

Open `http://localhost:4321/road-gp/2026/bwf-5` and verify:
- "View Results" button is visible and links to `/road-gp/2026/bwf-5/results`
- Open any other race detail page (e.g. `/road-gp/2026/chorley-4`) and verify the "View Results" button is NOT shown (no results CSV exists for that race)

- [ ] **Step 5: Run full test suite**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId].astro src/pages/fell/[year]/[raceId].astro
git commit -m "feat: show View Results link on race detail pages when results exist"
```
