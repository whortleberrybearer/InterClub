# Category Positions on Individual Results Page — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Surface per-runner team category positions (Open, Ladies, Vets, etc.) on the individual results page — as grouped columns on desktop, and as a repurposed IC column on mobile — driven by `cat_*` CSV columns that replace the retired `ic_position` column.

**Architecture:** The `RaceResult` type drops `icPosition` and gains `categoryPositions: Record<string, number | null>`, populated by detecting `cat_*`-prefixed headers in the CSV. `IndividualResultsLayout.astro` adds one `<th>`/`<td>` per team category (hidden on mobile via Tailwind), and the client script handles category chip filtering, mobile IC-column repurposing, and desktop column highlighting. A one-off migration script renames `ic_position` → `cat_open` in the 172 existing CSVs before the code change lands.

**Tech Stack:** Astro v6, TypeScript (strict), Tailwind CSS v4, Vitest, Node.js (migration script)

---

## File Map

| File | Change |
|------|--------|
| `src/lib/types.ts` | Remove `icPosition`, add `categoryPositions` to `RaceResult` |
| `src/lib/results.ts` | Update `parseResultsCsv` — drop `ic_position`, detect `cat_*` columns |
| `tests/lib/results.test.ts` | Replace `icPosition` assertions; add `categoryPositions` tests |
| `src/components/IndividualResultsLayout.astro` | Add category columns (server HTML + client script) |
| `scripts/migrate-ic-position.mjs` | One-off: rename `ic_position` → `cat_open` in all CSVs |

---

## Task 1: Update `RaceResult` type

**Files:**
- Modify: `src/lib/types.ts`

- [ ] **Step 1: Replace `icPosition` with `categoryPositions` in `RaceResult`**

In `src/lib/types.ts`, change the `RaceResult` interface from:

```typescript
export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;
  ageCategory: string;
  sex: string;
  time: string;
  raceNumber: number | null;
  seriesRunnerId: number | null;
}
```

To:

```typescript
export interface RaceResult {
  position: number | null;
  categoryPositions: Record<string, number | null>;
  firstName: string;
  lastName: string;
  club: string;
  ageCategory: string;
  sex: string;
  time: string;
  raceNumber: number | null;
  seriesRunnerId: number | null;
}
```

- [ ] **Step 2: Fix the compile error in `IndividualResultsLayout.astro`**

Find line 363 in `src/components/IndividualResultsLayout.astro`:

```typescript
const ic = r.club === 'Guest' ? '–' : (r.icPosition ?? '–');
```

Replace with:

```typescript
const ic = r.club === 'Guest' ? '–' : (r.categoryPositions['open'] ?? '–');
```

- [ ] **Step 3: Verify the build compiles cleanly**

```bash
npm run build
```

Expected: build succeeds (TypeScript errors in `.astro` pages surface here, not in `npm test`).

- [ ] **Step 4: Commit**

```bash
git add src/lib/types.ts src/components/IndividualResultsLayout.astro
git commit -m "types: replace icPosition with categoryPositions on RaceResult"
```

---

## Task 2: Write failing tests for the updated parser

**Files:**
- Modify: `tests/lib/results.test.ts`

Replace the entire `describe('parseResultsCsv', ...)` block with the version below. The tests now use `categoryPositions` throughout, add coverage for `cat_*` column detection, and drop the old `icPosition` assertions.

- [ ] **Step 1: Replace the `parseResultsCsv` describe block**

In `tests/lib/results.test.ts`, replace everything from `describe('parseResultsCsv', () => {` up to (but not including) `describe('parseTeamResultsPath', () => {` with:

```typescript
describe('parseResultsCsv', () => {
  // base sample uses cat_open instead of ic_position
  const sample = [
    'position,cat_open,first_name,last_name,club,age_category,sex,time',
    '1,1,Luke,Minns,blackpool,V35,M,19:35',
    '2,2,Rob,Danson,preston,V35,M,19:38',
    '3,,T.,Guest,Guest,SEN,M,20:00',
  ].join('\n');

  it('returns one row per data line', () => {
    expect(parseResultsCsv(sample)).toHaveLength(3);
  });

  it('parses position as a number', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.position).toBe(1);
  });

  it('parses cat_open into categoryPositions.open', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.categoryPositions['open']).toBe(1);
  });

  it('parses empty cat_open as null', () => {
    const results = parseResultsCsv(sample);
    expect(results[2].categoryPositions['open']).toBeNull();
  });

  it('parses position as null when empty', () => {
    const csv = 'position,cat_open,first_name,last_name,club,age_category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
    const [row] = parseResultsCsv(csv);
    expect(row.position).toBeNull();
  });

  it('maps all string fields correctly', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.firstName).toBe('Luke');
    expect(first.lastName).toBe('Minns');
    expect(first.club).toBe('blackpool');
    expect(first.ageCategory).toBe('V35');
    expect(first.sex).toBe('M');
    expect(first.time).toBe('19:35');
  });

  it('handles Windows line endings (CRLF)', () => {
    const crlf = sample.replace(/\n/g, '\r\n');
    expect(parseResultsCsv(crlf)).toHaveLength(3);
  });

  it('returns empty array for header-only CSV', () => {
    expect(parseResultsCsv('position,cat_open,first_name,last_name,club,age_category,sex,time')).toHaveLength(0);
  });

  it('returns empty array for empty string', () => {
    expect(parseResultsCsv('')).toHaveLength(0);
  });

  it('parses raceNumber as a number when present', () => {
    const csv = 'position,cat_open,race_number,first_name,last_name,club,age_category,sex,time\n1,1,42,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBe(42);
  });

  it('parses raceNumber as null when the column is empty', () => {
    const csv = 'position,cat_open,race_number,first_name,last_name,club,age_category,sex,time\n1,1,,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBeNull();
  });

  it('parses raceNumber as null when the column is absent (old CSV format)', () => {
    const csv = 'position,cat_open,first_name,last_name,club,age_category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBeNull();
  });

  it('parses seriesRunnerId when column is present', () => {
    const csv = [
      'position,cat_open,first_name,last_name,club,age_category,sex,time,series_runner_id',
      '1,1,Luke,Minns,blackpool,V35,M,19:35,2',
      '11,,T.,Guest,Guest,SEN,M,21:44,',
    ].join('\n');
    const results = parseResultsCsv(csv);
    expect(results[0].seriesRunnerId).toBe(2);
    expect(results[1].seriesRunnerId).toBeNull();
  });

  it('returns seriesRunnerId as null when column is absent', () => {
    const results = parseResultsCsv(sample);
    results.forEach(r => expect(r.seriesRunnerId).toBeNull());
  });

  it('parses multiple cat_* columns into categoryPositions', () => {
    const csv = [
      'position,cat_open,cat_ladies,cat_vets,first_name,last_name,club,age_category,sex,time',
      '5,5,,2,John,Townsend,wesham,V45,M,33:50',
      '24,14,1,4,Emily,Simm,blackpool,V35,F,35:42',
    ].join('\n');
    const [john, emily] = parseResultsCsv(csv);
    expect(john.categoryPositions['open']).toBe(5);
    expect(john.categoryPositions['ladies']).toBeNull();
    expect(john.categoryPositions['vets']).toBe(2);
    expect(emily.categoryPositions['open']).toBe(14);
    expect(emily.categoryPositions['ladies']).toBe(1);
    expect(emily.categoryPositions['vets']).toBe(4);
  });

  it('returns empty categoryPositions when no cat_* columns exist', () => {
    const csv = 'position,first_name,last_name,club,age_category,sex,time\n1,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.categoryPositions).toEqual({});
  });

  it('does not capture series_runner_id as a category position', () => {
    const csv = [
      'position,cat_open,first_name,last_name,club,age_category,sex,time,series_runner_id',
      '1,1,Luke,Minns,blackpool,V35,M,19:35,7',
    ].join('\n');
    const [row] = parseResultsCsv(csv);
    expect(Object.keys(row.categoryPositions)).toEqual(['open']);
    expect(row.seriesRunnerId).toBe(7);
  });

  it('ignores a legacy ic_position column if somehow present', () => {
    // ic_position is not a cat_* column — it should not appear in categoryPositions
    const csv = 'position,ic_position,first_name,last_name,club,age_category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.categoryPositions).toEqual({});
  });
});
```

- [ ] **Step 2: Run tests and confirm failures**

```bash
npm test
```

Expected: multiple failures in `parseResultsCsv` — `categoryPositions` does not exist on `RaceResult`, `icPosition` still read, etc.

---

## Task 3: Update `parseResultsCsv` implementation

**Files:**
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Replace the `parseResultsCsv` function body**

In `src/lib/results.ts`, replace the `parseResultsCsv` function with:

```typescript
export function parseResultsCsv(csv: string): RaceResult[] {
  const lines = csv.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trim().split('\n');
  if (lines.length < 2) return [];

  const headers = lines[0].split(',');
  const idx = (name: string) => headers.indexOf(name);

  // Identify all cat_* columns upfront
  const catColumns = headers.filter(h => h.startsWith('cat_'));

  return lines.slice(1).filter(l => l.trim()).map(line => {
    const cols = line.split(',');
    const get = (name: string) => cols[idx(name)]?.trim() ?? '';
    const num = (name: string) => { const v = get(name); return v ? parseInt(v, 10) : null; };

    const categoryPositions: Record<string, number | null> = {};
    for (const col of catColumns) {
      categoryPositions[col.slice(4)] = num(col); // strip 'cat_' prefix to get category id
    }

    return {
      position: num('position'),
      categoryPositions,
      firstName: get('first_name'),
      lastName: get('last_name'),
      club: get('club'),
      ageCategory: get('age_category'),
      sex: get('sex'),
      time: get('time'),
      raceNumber: num('race_number'),
      seriesRunnerId: num('series_runner_id'),
    };
  });
}
```

- [ ] **Step 2: Run tests and confirm all pass**

```bash
npm test
```

Expected: all tests pass, including the new `parseResultsCsv` suite.

- [ ] **Step 3: Commit**

```bash
git add src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat: replace ic_position with cat_* column detection in parseResultsCsv"
```

---

## Task 4: CSV migration script

**Files:**
- Create: `scripts/migrate-ic-position.mjs`

This script finds every `.csv` file under `src/data/`, checks the first non-BOM line for `ic_position` as a header token, and renames it to `cat_open` in-place.

- [ ] **Step 1: Create the migration script**

Create `scripts/migrate-ic-position.mjs` with this content:

```javascript
#!/usr/bin/env node
// One-off migration: renames `ic_position` → `cat_open` in all CSV headers.
// Safe to re-run: files without `ic_position` are left untouched.

import { readdirSync, readFileSync, writeFileSync, statSync } from 'fs';
import { join, extname } from 'path';

const dataDir = new URL('../src/data', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');

function walkCsvs(dir) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...walkCsvs(full));
    } else if (extname(entry) === '.csv') {
      results.push(full);
    }
  }
  return results;
}

let changed = 0;
let skipped = 0;

for (const file of walkCsvs(dataDir)) {
  const raw = readFileSync(file, 'utf8');
  // Strip BOM if present
  const content = raw.startsWith('﻿') ? raw.slice(1) : raw;
  const newline = content.includes('\r\n') ? '\r\n' : '\n';
  const lines = content.split(newline);
  const header = lines[0];

  // Only touch files that actually have ic_position as a header token
  const tokens = header.split(',');
  const colIdx = tokens.indexOf('ic_position');
  if (colIdx === -1) {
    skipped++;
    continue;
  }

  tokens[colIdx] = 'cat_open';
  lines[0] = tokens.join(',');
  // Preserve BOM if original had one
  const prefix = raw.startsWith('﻿') ? '﻿' : '';
  writeFileSync(file, prefix + lines.join(newline), 'utf8');
  changed++;
  console.log(`  updated: ${file}`);
}

console.log(`\nDone. ${changed} file(s) updated, ${skipped} file(s) skipped.`);
```

- [ ] **Step 2: Run the script**

```bash
node scripts/migrate-ic-position.mjs
```

Expected output ends with something like:
```
Done. 172 file(s) updated, 0 file(s) skipped.
```

- [ ] **Step 3: Spot-check a migrated CSV**

```bash
head -1 src/data/2026/road-gp/results/blackpool.csv
```

Expected:
```
position,cat_open,race_number,first_name,last_name,club,age_category,sex,time,series_runner_id
```

(The `ic_position` token is now `cat_open`. All data rows are unchanged.)

- [ ] **Step 4: Verify the build still works with migrated CSVs**

```bash
npm run build
```

Expected: build succeeds. The parser now reads `cat_open` correctly.

- [ ] **Step 5: Commit**

```bash
git add scripts/migrate-ic-position.mjs src/data/
git commit -m "migrate: rename ic_position → cat_open in all result CSVs"
```

---

## Task 5: Server-side HTML — add category columns

**Files:**
- Modify: `src/components/IndividualResultsLayout.astro`

This task touches only the server-rendered markup and JSON data blobs. The client script is updated in Tasks 6 and 7.

- [ ] **Step 1: Add `hasCategoryData` computation to the frontmatter**

After the existing `const teamCategories = config.teamCategories ?? [];` line (around line 34), add:

```typescript
const hasCategoryData = results.some(r =>
  Object.values(r.categoryPositions).some(v => v !== null)
);
```

- [ ] **Step 2: Update the `<colgroup>` to include category columns**

Replace the existing `<colgroup>` block:

```html
<colgroup>
  <col class="w-10" />
  <col class="w-9" />
  <col class="w-11" />
  <col />
  <col class="w-12" />
  <col class="w-20" />
</colgroup>
```

With:

```astro
<colgroup>
  <col class="w-10" />
  {teamCategories.map(() => <col class="hidden lg:table-column w-9" />)}
  <col class="w-11" />
  <col />
  <col class="w-12" />
  <col class="w-20" />
</colgroup>
```

- [ ] **Step 3: Update `<thead>` — rename IC → Open, add category headers**

Replace the existing `<thead>` row:

```html
<thead>
  <tr>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 pl-4 pr-2 bg-surface border-b-2 border-content">Pos</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">IC</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">No.</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">Runner</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">Cat</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-right py-2.5 px-2 pr-4 bg-surface border-b-2 border-content">Time</th>
  </tr>
</thead>
```

With:

```astro
<thead>
  <tr>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 pl-4 pr-2 bg-surface border-b-2 border-content">Pos</th>
    {teamCategories.map(cat => (
      <th
        class="hidden lg:table-cell font-head text-[10px] font-bold tracking-[0.1em] uppercase text-amber/60 text-left py-2.5 px-2 bg-surface border-b-2 border-content"
        data-cat-id={cat.id}
      >{cat.name}</th>
    ))}
    <th id="ic-header" class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">Open</th>
    <th class="no-col font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">No.</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">Runner</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-left py-2.5 px-2 bg-surface border-b-2 border-content">Cat</th>
    <th class="font-head text-[10px] font-bold tracking-[0.1em] uppercase text-muted text-right py-2.5 px-2 pr-4 bg-surface border-b-2 border-content">Time</th>
  </tr>
</thead>
```

Note the changes:
- Each team category gets a `<th>` with `class="hidden lg:table-cell ..."` and `data-cat-id`
- The old "IC" `<th>` is renamed "Open" and given `id="ic-header"` 
- The "No." `<th>` gets class `no-col` (used by CSS to hide it on mobile when category is active)

- [ ] **Step 4: Update the `<tbody>` server-rendered rows**

Replace the existing `{results.map(r => { ... })}` block inside `<tbody id="results-tbody">`:

```astro
{results.map(r => {
  const url      = r.seriesRunnerId != null ? runnerUrlMap[r.seriesRunnerId] : undefined;
  const fullName = `${r.firstName ?? ''} ${r.lastName ?? ''}`.trim();
  const clubName = r.club === 'Guest' ? 'Guest' : (clubById[r.club]?.name ?? r.club);
  const openPos  = r.club === 'Guest' ? '–' : (r.categoryPositions['open'] ?? '–');
  return (
    <tr class="border-b border-line last:border-0">
      <td class="py-2.5 pl-4 pr-2 font-mono text-[13px] font-medium text-muted align-middle">{r.position ?? '–'}</td>
      {teamCategories.map(cat => (
        <td class="hidden lg:table-cell py-2.5 px-2 font-mono text-[12px] text-amber/80 font-medium align-middle">
          {r.categoryPositions[cat.id] ?? '–'}
        </td>
      ))}
      <td class="py-2.5 px-2 font-mono text-[12px] text-muted align-middle">{openPos}</td>
      <td class="no-col py-2.5 px-2 font-mono text-[12px] text-muted align-middle">{r.raceNumber ?? '–'}</td>
      <td class="py-2.5 px-2 align-middle max-w-0 overflow-hidden">
        <div class="font-semibold leading-tight truncate">
          {url
            ? <a href={url} class="link link-hover">{fullName}</a>
            : fullName
          }
        </div>
        <div class="text-xs text-muted mt-0.5 truncate">{clubName}</div>
      </td>
      <td class="py-2.5 px-2 font-mono text-[11px] text-muted align-middle">{(r.sex ?? '') + (r.ageCategory ?? '')}</td>
      <td class="py-2.5 px-2 pr-4 font-mono text-[13px] font-medium text-right tabular-nums align-middle">{formatTime(r.time)}</td>
    </tr>
  );
})}
```

- [ ] **Step 5: Add `teamCategories` and `hasCategoryData` JSON blobs**

After the existing three `<script type="application/json">` elements (around line 392), add:

```astro
<script type="application/json" id="team-categories-data" set:html={JSON.stringify(teamCategories).replace(/<\/script>/gi, '<\\/script>')}></script>
<script type="application/json" id="has-category-data" set:html={JSON.stringify(hasCategoryData).replace(/<\/script>/gi, '<\\/script>')}></script>
```

- [ ] **Step 6: Add CSS for mobile No.-column hiding**

Inside the component, before the closing `</Layout>` tag, add an inline `<style>`:

```html
<style>
  @media (max-width: 1023px) {
    table.cat-active .no-col { display: none; }
  }
</style>
```

- [ ] **Step 7: Verify build**

```bash
npm run build
```

Expected: build succeeds. The desktop results page now has category position columns. Mobile shows the same 6 columns as before (category columns are hidden via CSS).

- [ ] **Step 8: Commit**

```bash
git add src/components/IndividualResultsLayout.astro
git commit -m "feat: add category position columns to individual results table (server HTML)"
```

---

## Task 6: Client script — update types and `buildRow`

**Files:**
- Modify: `src/components/IndividualResultsLayout.astro` (the `<script>` block)

- [ ] **Step 1: Update the local `Result` type in the client script**

In the `<script>` block, replace the existing `type Result = { ... }` with:

```typescript
type Result = {
  position: number | null;
  categoryPositions: Record<string, number | null>;
  raceNumber: number | null;
  firstName: string;
  lastName: string;
  club: string;
  ageCategory: string;
  sex: string;
  time: string;
  seriesRunnerId: number | null;
};
```

- [ ] **Step 2: Parse the two new JSON blobs**

After the existing `const runnerUrlMap` parse line, add:

```typescript
type TeamCat = { id: string; name: string; scorerCount: number };
const teamCategories: TeamCat[] = JSON.parse(document.getElementById('team-categories-data')!.textContent!);
const hasCategoryData: boolean  = JSON.parse(document.getElementById('has-category-data')!.textContent!);
```

- [ ] **Step 3: Add the `activeCategoryId` state variable**

After the `hasCategoryData` line, add:

```typescript
// null = Full view; string = active category id
let activeCategoryId: string | null = null;
```

- [ ] **Step 4: Update `buildRow` to use `categoryPositions` and emit category cells**

Replace the existing `buildRow` function:

```typescript
function buildRow(r: Result): string {
  const url      = r.seriesRunnerId != null ? runnerUrlMap[r.seriesRunnerId] : null;
  const fullName = `${esc(r.firstName ?? '')} ${esc(r.lastName ?? '')}`.trim();
  const clubName = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.name ?? r.club);
  const displayCatId = activeCategoryId ?? 'open';
  const icVal    = r.club === 'Guest' ? '–' : String(r.categoryPositions[displayCatId] ?? '–');
  const nameCell = url ? `<a href="${url}" class="link link-hover">${fullName}</a>` : fullName;
  const cat      = esc((r.sex ?? '') + (r.ageCategory ?? ''));

  const catCells = teamCategories.map(tc => {
    const pos = r.categoryPositions[tc.id] ?? null;
    return `<td class="hidden lg:table-cell py-2.5 px-2 font-mono text-[12px] text-amber/80 font-medium align-middle">${pos ?? '–'}</td>`;
  }).join('');

  return `<tr class="border-b border-line last:border-0">
    <td class="py-2.5 pl-4 pr-2 font-mono text-[13px] font-medium text-muted align-middle">${r.position ?? '–'}</td>
    ${catCells}
    <td class="py-2.5 px-2 font-mono text-[12px] text-muted align-middle">${icVal}</td>
    <td class="no-col py-2.5 px-2 font-mono text-[12px] text-muted align-middle">${r.raceNumber ?? '–'}</td>
    <td class="py-2.5 px-2 align-middle max-w-0 overflow-hidden">
      <div class="font-semibold leading-tight truncate">${nameCell}</div>
      <div class="text-xs text-muted mt-0.5 truncate">${clubName}</div>
    </td>
    <td class="py-2.5 px-2 font-mono text-[11px] text-muted align-middle">${cat}</td>
    <td class="py-2.5 px-2 pr-4 font-mono text-[13px] font-medium text-right tabular-nums align-middle">${formatTime(r.time)}</td>
  </tr>`;
}
```

- [ ] **Step 5: Verify build**

```bash
npm run build
```

Expected: build succeeds. The page renders correctly; chips don't filter yet (that's Task 7).

---

## Task 7: Client script — category filtering, mobile repurposing, desktop highlighting

**Files:**
- Modify: `src/components/IndividualResultsLayout.astro` (the `<script>` block)

- [ ] **Step 1: Add helper functions for IC header renaming and column highlighting**

After the `activeCategoryId` declaration, add:

```typescript
const icHeader = document.getElementById('ic-header')!;
const resultsTable = document.querySelector<HTMLTableElement>('#results-tbody')!.closest('table')!;

function applyMobileCategoryState(catId: string | null) {
  if (catId === null) {
    // Full view: restore Open header, show No. column
    icHeader.textContent = 'Open';
    resultsTable.classList.remove('cat-active');
  } else {
    // Category view: rename IC header, hide No. column
    const cat = teamCategories.find(tc => tc.id === catId);
    icHeader.textContent = cat?.name ?? catId;
    resultsTable.classList.add('cat-active');
  }
}

function applyDesktopCategoryHighlight(catId: string | null) {
  document.querySelectorAll<HTMLElement>('th[data-cat-id]').forEach(th => {
    const isActive = th.dataset.catId === catId;
    const hasActiveFilter = catId !== null;
    th.classList.toggle('text-amber',    isActive);
    th.classList.toggle('text-amber/30', !isActive && hasActiveFilter);
    th.classList.toggle('text-amber/60', !isActive && !hasActiveFilter);
  });
}
```

- [ ] **Step 2: Update `render()` to filter rows by active category**

Replace the existing `render()` function with:

```typescript
function render() {
  const name = (nameM?.value ?? nameD?.value ?? '').toLowerCase();
  const club = clubM?.value ?? clubD?.value ?? '';
  const activeSexes   = [...sexFilterBtns].filter(b => b.classList.contains('active-filter')).map(b => b.dataset.sex ?? '');
  const activeAgeCats = [...ageFilterBtns].filter(b => b.classList.contains('active-filter')).map(b => b.dataset.age ?? '');

  const filtered = allResults.filter(r => {
    // Category filter (only when data exists)
    if (hasCategoryData && activeCategoryId !== null) {
      if ((r.categoryPositions[activeCategoryId] ?? null) === null) return false;
    }
    if (activeSexes.length   > 0 && !activeSexes.includes(r.sex ?? ''))           return false;
    if (activeAgeCats.length > 0 && !activeAgeCats.includes(r.ageCategory ?? '')) return false;
    if (name && !(`${r.firstName} ${r.lastName}`).toLowerCase().includes(name) &&
        !(r.raceNumber !== null && String(r.raceNumber).startsWith(name)))         return false;
    if (club && r.club !== club) return false;
    return true;
  });

  tbody.innerHTML = filtered.map(buildRow).join('');
}
```

- [ ] **Step 3: Update chip click handlers to set `activeCategoryId`**

Replace the existing chip event listeners section:

```typescript
chips.forEach(chip => {
  chip.addEventListener('click', () => {
    const target = chip.dataset.target!;
    syncChipBar(target);
    if (target === 'ind-full') {
      syncSidebar(-1);
      activeCategoryId = null;
    } else {
      const idx = parseInt(target.replace('ind-cat-', ''), 10);
      syncSidebar(idx);
      activeCategoryId = teamCategories[idx]?.id ?? null;
    }
    applyMobileCategoryState(activeCategoryId);
    applyDesktopCategoryHighlight(activeCategoryId);
    render();
  });
});
```

- [ ] **Step 4: Update sidebar button click handlers**

Replace the existing `teamCatBtns.forEach` block:

```typescript
teamCatBtns.forEach((btn, i) => {
  btn.addEventListener('click', () => {
    syncChipBar(`ind-cat-${i}`);
    syncSidebar(i);
    activeCategoryId = teamCategories[i]?.id ?? null;
    applyMobileCategoryState(activeCategoryId);
    applyDesktopCategoryHighlight(activeCategoryId);
    render();
  });
});
```

- [ ] **Step 5: Update the Full sidebar button click handler**

Replace the existing `fullSidebarBtn?.addEventListener` block:

```typescript
fullSidebarBtn?.addEventListener('click', () => {
  syncChipBar('ind-full');
  syncSidebar(-1);
  activeCategoryId = null;
  applyMobileCategoryState(null);
  applyDesktopCategoryHighlight(null);
  render();
});
```

- [ ] **Step 6: Apply the initial desktop highlight state on page load**

At the very end of the `<script>` block, after all event listeners, add:

```typescript
// Apply initial desktop highlight for the pre-selected category (when no Full chip)
applyDesktopCategoryHighlight(activeCategoryId);
```

And update the `activeCategoryId` initialisation (from Task 6 Step 3) to set it correctly when the first category chip is pre-selected:

Replace:
```typescript
let activeCategoryId: string | null = null;
```

With:

```typescript
// When there is no Full chip (no guests), the first category chip is pre-selected
const showFullChip = !!document.querySelector('.full-sidebar-btn');
let activeCategoryId: string | null =
  !showFullChip && teamCategories.length > 0 ? (teamCategories[0]?.id ?? null) : null;
```

- [ ] **Step 7: Final build verification**

```bash
npm run build
```

Expected: build succeeds with no TypeScript errors.

- [ ] **Step 8: Run all tests**

```bash
npm test
```

Expected: all tests pass.

- [ ] **Step 9: Commit**

```bash
git add src/components/IndividualResultsLayout.astro
git commit -m "feat: implement category position filtering and display on individual results page"
```

---

## Task 8: Smoke test in the browser

- [ ] **Step 1: Start the dev server**

```bash
npm run dev
```

- [ ] **Step 2: Open a results page that has team data**

Navigate to the 2026 Blackpool Road GP results page (or whichever race has a `*-teams.json` and a fully-populated CSV with `cat_*` columns).

- [ ] **Step 3: Verify desktop Full view**

At `lg` breakpoint (≥1024px):
- Category columns (Open, Ladies, FV40, Vets, Vet50s, Vet60s) appear between Pos and No.
- Category column headers are muted amber
- Runners with positions show numbers; others show `—`
- Runners like Emily Simm should show values in multiple category columns

- [ ] **Step 4: Verify desktop category chip**

Click "Ladies" in the sidebar:
- Table filters to ladies scorers only
- Ladies column header turns full amber; other category headers dim
- The IC/Open column still shows the Open position for each scorer

- [ ] **Step 5: Verify mobile Full view**

At `<768px` width:
- Category columns are hidden
- IC column header reads "Open"
- Existing 6-column layout intact

- [ ] **Step 6: Verify mobile category chip**

Tap "Ladies" chip on mobile:
- IC column header renames to "Ladies"
- IC column values show ladies positions (1, 2, 3…)
- No. column disappears; table remains within viewport without scrolling
- Only ladies scorers shown

- [ ] **Step 7: Verify historical race (no cat_* columns)**

Navigate to a pre-migration results page (e.g. any 2005–2025 race). Click a category chip:
- Rows are not filtered (all runners still shown — `hasCategoryData` is false)
- Category columns on desktop all show `—`
- IC/Open column shows `—` for everyone (no `cat_open` data either)

---

## Self-Review Notes

- **Spec coverage:** All sections covered — CSV schema (Task 3/4), type change (Task 1), parser update (Task 3), migration script (Task 4), desktop columns (Task 5), mobile repurposing (Task 6/7), category filtering (Task 7), backward compat (Task 7 Step 2).
- **No placeholders:** All steps include complete code.
- **Type consistency:** `categoryPositions: Record<string, number | null>` used throughout Tasks 1–7. `teamCategories` typed as `TeamCat[]` in client script matching the `TeamCategory` shape from `config`. `activeCategoryId: string | null` set and read consistently.
- **`buildRow` and server-rendered rows match:** Both emit category cells with `hidden lg:table-cell` and `no-col` on the No. cell.
- **One gap addressed:** The `applyMobileCategoryState` initial call is not needed on load since the initial state is always Full (or first category, but mobile starts in Full view regardless of chip state — the mobile chip state is handled client-side the first time a chip is tapped).
