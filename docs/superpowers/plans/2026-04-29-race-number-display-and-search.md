# Race Number Display and Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional `race_number` CSV column that displays as a `Num` column in results tables (hidden on mobile) and is searchable via the existing name/number search input.

**Architecture:** Add `raceNumber: number | null` to the `RaceResult` type, parse it from the CSV, then update both results pages (Road GP and Fell) to display the column and extend the search filter to match on race number using `startsWith`.

**Tech Stack:** TypeScript, Astro v6, Tailwind CSS v4 / DaisyUI v5, Vitest

---

## File Map

| File | Change |
|---|---|
| `src/lib/types.ts` | Add `raceNumber: number \| null` to `RaceResult` |
| `src/lib/results.ts` | Read `race_number` column in `parseResultsCsv` |
| `tests/lib/results.test.ts` | New tests for `raceNumber` parsing |
| `src/pages/road-gp/[year]/[raceId]/results.astro` | Add Num column + update search |
| `src/pages/fell/[year]/[raceId]/results.astro` | Same changes as Road GP page |

---

### Task 1: Parse `race_number` from CSV

**Files:**
- Modify: `src/lib/types.ts`
- Modify: `src/lib/results.ts`
- Modify: `tests/lib/results.test.ts`

- [ ] **Step 1: Write failing tests**

Add these three test cases to the `describe('parseResultsCsv', ...)` block in `tests/lib/results.test.ts`:

```ts
it('parses raceNumber as a number when present', () => {
  const csv = 'position,ic_position,race_number,first_name,last_name,club,category,sex,time\n1,1,42,Luke,Minns,blackpool,V35,M,19:35';
  const [row] = parseResultsCsv(csv);
  expect(row.raceNumber).toBe(42);
});

it('parses raceNumber as null when the column is empty', () => {
  const csv = 'position,ic_position,race_number,first_name,last_name,club,category,sex,time\n1,1,,Luke,Minns,blackpool,V35,M,19:35';
  const [row] = parseResultsCsv(csv);
  expect(row.raceNumber).toBeNull();
});

it('parses raceNumber as null when the column is absent (old CSV format)', () => {
  const csv = 'position,ic_position,first_name,last_name,club,category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
  const [row] = parseResultsCsv(csv);
  expect(row.raceNumber).toBeNull();
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
npm test
```

Expected: 3 failures — `Property 'raceNumber' does not exist` or similar TypeScript error.

- [ ] **Step 3: Add `raceNumber` to `RaceResult` in `src/lib/types.ts`**

Locate the `RaceResult` interface (currently ends at `time: string`) and add the new field after `time`:

```ts
export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;        // club id (e.g. 'blackpool') or 'Guest'
  category: string;   // e.g. 'SEN', 'V35', 'U17'
  sex: string;        // 'M' or 'F'
  time: string;       // 'MM:SS', may be empty
  raceNumber: number | null;
}
```

- [ ] **Step 4: Read `race_number` in `parseResultsCsv` in `src/lib/results.ts`**

Locate the `return { ... }` object inside the `.map(line => ...)` call in `parseResultsCsv`. Add `raceNumber` after `time`:

```ts
return {
  position: num('position'),
  icPosition: num('ic_position'),
  firstName: get('first_name'),
  lastName: get('last_name'),
  club: get('club'),
  category: get('category'),
  sex: get('sex'),
  time: get('time'),
  raceNumber: num('race_number'),
};
```

The existing `num()` helper handles the absent-column case: `idx('race_number')` returns `-1` when the header is missing, `cols[-1]` is `undefined`, `get()` returns `''`, and `num()` returns `null` because of the `v ? ... : null` guard.

- [ ] **Step 5: Run tests to verify they pass**

```bash
npm test
```

Expected: all tests pass, including the 3 new ones.

- [ ] **Step 6: Commit**

```bash
git add src/lib/types.ts src/lib/results.ts tests/lib/results.test.ts
git commit -m "feat: add raceNumber field to RaceResult and parse from CSV"
```

---

### Task 2: Update Road GP results page

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId]/results.astro`

There are four changes in this file: the `<thead>`, the static `<tbody>` rows, the client-side `row()` function, and the search `render()` function. Also update the type annotation and the search input placeholder.

- [ ] **Step 1: Add `Num` column to `<thead>`**

Locate the `<thead>` block. Add the `Num` header between `IC` and `Name`:

```html
<thead>
  <tr>
    <th class="hidden sm:table-cell">Pos</th>
    <th>IC</th>
    <th class="hidden sm:table-cell">Num</th>
    <th>Name</th>
    <th>Cat</th>
    <th>Club</th>
    <th class="text-right">Time</th>
  </tr>
</thead>
```

- [ ] **Step 2: Add `Num` cell to static `<tbody>` rows**

Locate the `{results.map(r => (` block. Add the `Num` cell between the IC cell and the Name cell:

```astro
{results.map(r => (
  <tr>
    <td class="hidden sm:table-cell">{r.position ?? '–'}</td>
    <td>{r.club === 'Guest' ? '–' : (r.icPosition ?? '–')}</td>
    <td class="hidden sm:table-cell">{r.raceNumber ?? '–'}</td>
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
```

- [ ] **Step 3: Update the search input placeholder**

Locate the `<input id="filter-name" ...>` element and change its `placeholder`:

```html
<input
  id="filter-name"
  type="search"
  placeholder="Search name or number…"
  class="input input-bordered input-sm w-full sm:w-40"
/>
```

- [ ] **Step 4: Update the client-side type annotation**

Locate the `const allResults: Array<{ ... }>` declaration in the `<script>` block and add `raceNumber`:

```ts
const allResults: Array<{
  position: number | null; icPosition: number | null;
  raceNumber: number | null;
  firstName: string; lastName: string;
  club: string; category: string; sex: string; time: string;
}> = JSON.parse(document.getElementById('results-data')!.textContent!);
```

- [ ] **Step 5: Add `Num` cell to the client-side `row()` function**

Locate the `function row(r: typeof allResults[0]): string` and add the `Num` cell between the IC cell and the Name cell:

```ts
function row(r: typeof allResults[0]): string {
  const name = r.firstName[0] ? `${esc(r.firstName[0])}.` : '';
  const clubShort = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.shortName ?? r.club);
  const clubFull = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.name ?? r.club);
  return `<tr>
    <td class="hidden sm:table-cell">${r.position ?? '–'}</td>
    <td>${r.club === 'Guest' ? '–' : (r.icPosition ?? '–')}</td>
    <td class="hidden sm:table-cell">${r.raceNumber ?? '–'}</td>
    <td>
      <span class="sm:hidden">${name} ${esc(r.lastName)}</span>
      <span class="hidden sm:inline">${esc(r.firstName)} ${esc(r.lastName)}</span>
    </td>
    <td>${esc(r.category)}</td>
    <td>
      <span class="sm:hidden">${clubShort}</span>
      <span class="hidden sm:inline">${clubFull}</span>
    </td>
    <td class="text-right tabular-nums">${esc(r.time || '–')}</td>
  </tr>`;
}
```

- [ ] **Step 6: Extend the `render()` filter to match on race number**

Locate the `render()` function. Replace the name filter line:

```ts
if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name)) return false;
```

with:

```ts
if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name) && !(r.raceNumber !== null && String(r.raceNumber).startsWith(name))) return false;
```

- [ ] **Step 7: Build to verify no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 8: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/results.astro
git commit -m "feat: add Num column and name-or-number search to Road GP results page"
```

---

### Task 3: Update Fell results page

**Files:**
- Modify: `src/pages/fell/[year]/[raceId]/results.astro`

This page is structurally identical to the Road GP page. Apply the exact same six changes.

- [ ] **Step 1: Add `Num` column to `<thead>`**

```html
<thead>
  <tr>
    <th class="hidden sm:table-cell">Pos</th>
    <th>IC</th>
    <th class="hidden sm:table-cell">Num</th>
    <th>Name</th>
    <th>Cat</th>
    <th>Club</th>
    <th class="text-right">Time</th>
  </tr>
</thead>
```

- [ ] **Step 2: Add `Num` cell to static `<tbody>` rows**

```astro
{results.map(r => (
  <tr>
    <td class="hidden sm:table-cell">{r.position ?? '–'}</td>
    <td>{r.club === 'Guest' ? '–' : (r.icPosition ?? '–')}</td>
    <td class="hidden sm:table-cell">{r.raceNumber ?? '–'}</td>
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
```

- [ ] **Step 3: Update the search input placeholder**

```html
<input
  id="filter-name"
  type="search"
  placeholder="Search name or number…"
  class="input input-bordered input-sm w-full sm:w-40"
/>
```

- [ ] **Step 4: Update the client-side type annotation**

```ts
const allResults: Array<{
  position: number | null; icPosition: number | null;
  raceNumber: number | null;
  firstName: string; lastName: string;
  club: string; category: string; sex: string; time: string;
}> = JSON.parse(document.getElementById('results-data')!.textContent!);
```

- [ ] **Step 5: Add `Num` cell to the client-side `row()` function**

```ts
function row(r: typeof allResults[0]): string {
  const name = r.firstName[0] ? `${esc(r.firstName[0])}.` : '';
  const clubShort = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.shortName ?? r.club);
  const clubFull = r.club === 'Guest' ? 'Guest' : esc(clubById[r.club]?.name ?? r.club);
  return `<tr>
    <td class="hidden sm:table-cell">${r.position ?? '–'}</td>
    <td>${r.club === 'Guest' ? '–' : (r.icPosition ?? '–')}</td>
    <td class="hidden sm:table-cell">${r.raceNumber ?? '–'}</td>
    <td>
      <span class="sm:hidden">${name} ${esc(r.lastName)}</span>
      <span class="hidden sm:inline">${esc(r.firstName)} ${esc(r.lastName)}</span>
    </td>
    <td>${esc(r.category)}</td>
    <td>
      <span class="sm:hidden">${clubShort}</span>
      <span class="hidden sm:inline">${clubFull}</span>
    </td>
    <td class="text-right tabular-nums">${esc(r.time || '–')}</td>
  </tr>`;
}
```

- [ ] **Step 6: Extend the `render()` filter to match on race number**

Replace:

```ts
if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name)) return false;
```

with:

```ts
if (name && !r.firstName.toLowerCase().includes(name) && !r.lastName.toLowerCase().includes(name) && !(r.raceNumber !== null && String(r.raceNumber).startsWith(name))) return false;
```

- [ ] **Step 7: Build to verify no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds with no errors.

- [ ] **Step 8: Commit**

```bash
git add "src/pages/fell/[year]/[raceId]/results.astro"
git commit -m "feat: add Num column and name-or-number search to Fell results page"
```
