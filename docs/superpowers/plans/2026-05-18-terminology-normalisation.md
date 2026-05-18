# Terminology Normalisation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the overloaded `category` field across all TypeScript types, source code, JSON data files, and CSV files so that age bands use `ageCategory`/`age_category` and category ID references use `id`.

**Architecture:** Types-first approach — rename `types.ts` fields first, then follow TypeScript compiler errors through all source files, update unit tests, verify the build is clean, then bulk-update data files. Two build checkpoints: one after code changes (Task 13), one after data file changes (Task 19).

**Tech Stack:** TypeScript, Astro v6, Vitest, PowerShell for bulk file operations.

**Spec:** `docs/superpowers/specs/2026-05-18-terminology-normalisation-design.md`

---

## Task 1: Rename fields in types.ts

**Files:**
- Modify: `src/lib/types.ts`

After this task the TypeScript build will have errors — that is expected and intentional.

- [ ] **Step 1: Apply all eight field renames**

In `src/lib/types.ts`, make these changes (shown as find → replace):

```typescript
// RaceResult (line ~40) — age band
category: string;   // e.g. 'SEN', 'V35', 'U17'
// becomes:
ageCategory: string;   // e.g. 'SEN', 'V35', 'U17'

// GlobalRunner (line ~60) — age band
category: string;   // e.g. 'SEN', 'V40'
// becomes:
ageCategory: string;   // e.g. 'SEN', 'V40'

// SeriesRunner (line ~70) — age band
category: string;
// becomes:
ageCategory: string;

// TeamCategoryResult (line ~149) — category ID reference
category: string;   // id → TeamCategory lookup via config.teamCategories
// becomes:
id: string;   // id → TeamCategory lookup via config.teamCategories

// TeamStandingsCategory (line ~166) — category ID reference
category: string;
// becomes:
id: string;

// IndividualStandingsCategory (line ~193) — category ID reference
category: string;   // id → IndividualCategory lookup via config.individualCategories
// becomes:
id: string;   // id → IndividualCategory lookup via config.individualCategories

// TeamAward (line ~205) — category ID reference
category: string;  // references teamCategories[].id in config.json
// becomes:
id: string;  // references teamCategories[].id in config.json

// IndividualAward (line ~217) — category ID reference
category: string;  // references individualCategories[].id in config.json
// becomes:
id: string;  // references individualCategories[].id in config.json
```

- [ ] **Step 2: Commit**

```bash
git add src/lib/types.ts
git commit -m "refactor: rename category fields in types — ageCategory and id"
```

---

## Task 2: Fix results.ts CSV parser

**Files:**
- Modify: `src/lib/results.ts:20`

- [ ] **Step 1: Change the CSV column name read in `parseResultsCsv`**

Find line 20 in `src/lib/results.ts`:
```typescript
      category: get('category'),
```
Replace with:
```typescript
      ageCategory: get('age_category'),
```

- [ ] **Step 2: Commit**

```bash
git add src/lib/results.ts
git commit -m "refactor: read age_category column in CSV parser"
```

---

## Task 3: Fix runners.ts

**Files:**
- Modify: `src/lib/runners.ts:143`

- [ ] **Step 1: Update `ia.category` to `ia.id` in `getAwardsForRunner`**

Find in `src/lib/runners.ts` (inside `getAwardsForRunner`):
```typescript
      const categoryName = config.individualCategories?.find(c => c.id === ia.category)?.name ?? ia.category;
```
Replace with:
```typescript
      const categoryName = config.individualCategories?.find(c => c.id === ia.id)?.name ?? ia.id;
```

- [ ] **Step 2: Commit**

```bash
git add src/lib/runners.ts
git commit -m "refactor: use ia.id instead of ia.category in getAwardsForRunner"
```

---

## Task 4: Update unit tests in results.test.ts

**Files:**
- Modify: `tests/lib/results.test.ts`

All CSV strings in this file use `category` as a column name. The one field assertion also uses `.category`. Update them all.

- [ ] **Step 1: Replace `category` column name with `age_category` in all CSV test strings**

In `tests/lib/results.test.ts`, find every occurrence of the string `category` within CSV header strings and replace with `age_category`. These are:

Line 6:
```typescript
    'position,ic_position,first_name,last_name,club,category,sex,time',
```
→
```typescript
    'position,ic_position,first_name,last_name,club,age_category,sex,time',
```

Line 28 (inside the string in `'parses position as null when empty'`):
```typescript
    const csv = 'position,ic_position,first_name,last_name,club,category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
```
→
```typescript
    const csv = 'position,ic_position,first_name,last_name,club,age_category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
```

Line 49 (inside `'returns empty array for header-only CSV'`):
```typescript
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,category,sex,time')).toHaveLength(0);
```
→
```typescript
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,age_category,sex,time')).toHaveLength(0);
```

Line 57 (inside `'parses raceNumber as a number when present'`):
```typescript
    const csv = 'position,ic_position,race_number,first_name,last_name,club,category,sex,time\n1,1,42,Luke,Minns,blackpool,V35,M,19:35';
```
→
```typescript
    const csv = 'position,ic_position,race_number,first_name,last_name,club,age_category,sex,time\n1,1,42,Luke,Minns,blackpool,V35,M,19:35';
```

Line 63 (inside `'parses raceNumber as null when the column is empty'`):
```typescript
    const csv = 'position,ic_position,race_number,first_name,last_name,club,category,sex,time\n1,1,,Luke,Minns,blackpool,V35,M,19:35';
```
→
```typescript
    const csv = 'position,ic_position,race_number,first_name,last_name,club,age_category,sex,time\n1,1,,Luke,Minns,blackpool,V35,M,19:35';
```

Line 69 (inside `'parses raceNumber as null when the column is absent'`):
```typescript
    const csv = 'position,ic_position,first_name,last_name,club,category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
```
→
```typescript
    const csv = 'position,ic_position,first_name,last_name,club,age_category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
```

Line 76 (inside `'parses seriesRunnerId when column is present'`):
```typescript
      'position,ic_position,first_name,last_name,club,category,sex,time,series_runner_id',
```
→
```typescript
      'position,ic_position,first_name,last_name,club,age_category,sex,time,series_runner_id',
```

- [ ] **Step 2: Update the field assertion**

Line 38 (inside `'maps all string fields correctly'`):
```typescript
    expect(first.category).toBe('V35');
```
→
```typescript
    expect(first.ageCategory).toBe('V35');
```

- [ ] **Step 3: Commit**

```bash
git add tests/lib/results.test.ts
git commit -m "test: update parseResultsCsv tests for age_category column rename"
```

---

## Task 5: Verify tests pass

- [ ] **Step 1: Run the test suite**

```bash
npm test
```

Expected: all tests pass. If any fail, the failure message will point to the specific assertion; fix before continuing.

---

## Task 6: Fix results.astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId]/results.astro`
- Modify: `src/pages/fell/[year]/[raceId]/results.astro`

Both files are identical in structure. Apply the same four changes to each.

- [ ] **Step 1: Update the server-rendered table cell**

Find (line ~102):
```astro
            <td>{r.category}</td>
```
Replace with:
```astro
            <td>{r.ageCategory}</td>
```

- [ ] **Step 2: Update the inline type annotation in the client script**

Find (line ~133):
```typescript
    club: string; category: string; sex: string; time: string;
```
Replace with:
```typescript
    club: string; ageCategory: string; sex: string; time: string;
```

- [ ] **Step 3: Update the client-rendered table cell**

Find (line ~187):
```typescript
    <td>${esc(r.category)}</td>
```
Replace with:
```typescript
    <td>${esc(r.ageCategory)}</td>
```

- [ ] **Step 4: Update the filter predicate**

Find (line ~204):
```typescript
      if (cat && r.category !== cat) return false;
```
Replace with:
```typescript
      if (cat && r.ageCategory !== cat) return false;
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/results.astro src/pages/fell/[year]/[raceId]/results.astro
git commit -m "refactor: use ageCategory on RaceResult in results pages"
```

---

## Task 7: Fix team-results.astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId]/team-results.astro`
- Modify: `src/pages/fell/[year]/[raceId]/team-results.astro`

Both files are identical in structure. Apply the same changes to each.

- [ ] **Step 1: Update category tab label lookup**

Find (line ~48):
```typescript
        const label = categoryById[cat.category]?.name ?? cat.category;
```
Replace with:
```typescript
        const label = categoryById[cat.id]?.name ?? cat.id;
```

- [ ] **Step 2: Update category panel config lookup**

Find (line ~70):
```typescript
    const catConfig = categoryById[cat.category];
```
Replace with:
```typescript
    const catConfig = categoryById[cat.id];
```

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId]/team-results.astro src/pages/fell/[year]/[raceId]/team-results.astro
git commit -m "refactor: use cat.id on TeamCategoryResult in team-results pages"
```

---

## Task 8: Fix individual-standings.astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/[year]/individual-standings.astro`
- Modify: `src/pages/fell/[year]/individual-standings.astro`

- [ ] **Step 1: Update category tab label lookup**

Find (line ~56):
```typescript
        const label = categoryById[cat.category]?.name ?? cat.category;
```
Replace with:
```typescript
        const label = categoryById[cat.id]?.name ?? cat.id;
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/road-gp/[year]/individual-standings.astro src/pages/fell/[year]/individual-standings.astro
git commit -m "refactor: use cat.id on IndividualStandingsCategory in individual-standings pages"
```

---

## Task 9: Fix team-standings.astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/[year]/team-standings.astro`
- Modify: `src/pages/fell/[year]/team-standings.astro`

- [ ] **Step 1: Update category tab label lookup**

Find (line ~48):
```typescript
        const label = categoryById[cat.category]?.name ?? cat.category;
```
Replace with:
```typescript
        const label = categoryById[cat.id]?.name ?? cat.id;
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/road-gp/[year]/team-standings.astro src/pages/fell/[year]/team-standings.astro
git commit -m "refactor: use cat.id on TeamStandingsCategory in team-standings pages"
```

---

## Task 10: Fix [year]/index.astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/[year]/index.astro`
- Modify: `src/pages/fell/[year]/index.astro`

Both files are identical in structure. Three references to update in each.

- [ ] **Step 1: Update individual award category lookup**

Find (line ~44):
```typescript
    const cat = resolveIndividualCategory(ia.category);
```
Replace with:
```typescript
    const cat = resolveIndividualCategory(ia.id);
```

- [ ] **Step 2: Update fallback category name**

Find (line ~48):
```typescript
        categoryName: cat?.name ?? ia.category,
```
Replace with:
```typescript
        categoryName: cat?.name ?? ia.id,
```

- [ ] **Step 3: Update team award category name**

Find (line ~61):
```typescript
      categoryName: resolveTeamCategoryName(ta.category),
```
Replace with:
```typescript
      categoryName: resolveTeamCategoryName(ta.id),
```

- [ ] **Step 4: Commit**

```bash
git add "src/pages/road-gp/[year]/index.astro" "src/pages/fell/[year]/index.astro"
git commit -m "refactor: use .id on award types in year index pages"
```

---

## Task 11: Fix history/[type].astro pages (road-gp and fell)

**Files:**
- Modify: `src/pages/road-gp/history/[type].astro`
- Modify: `src/pages/fell/history/[type].astro`

Both files are identical in structure. Four references to update in each.

- [ ] **Step 1: Update team award lookup**

Find (line ~42):
```typescript
      const award = yearly.awards.teamAwards.find(ta => ta.category === cat.id);
```
Replace with:
```typescript
      const award = yearly.awards.teamAwards.find(ta => ta.id === cat.id);
```

- [ ] **Step 2: Update individual award config category lookup**

Find (line ~63):
```typescript
        const configCat = yearly.config.individualCategories?.find(c => c.id === ia.category);
```
Replace with:
```typescript
        const configCat = yearly.config.individualCategories?.find(c => c.id === ia.id);
```

- [ ] **Step 3: Update individual award id reference**

Find (line ~65):
```typescript
          id: ia.category,
```
Replace with:
```typescript
          id: ia.id,
```

- [ ] **Step 4: Update individual award name fallback**

Find (line ~66):
```typescript
          name: configCat?.name ?? ia.category,
```
Replace with:
```typescript
          name: configCat?.name ?? ia.id,
```

- [ ] **Step 5: Commit**

```bash
git add src/pages/road-gp/history/[type].astro src/pages/fell/history/[type].astro
git commit -m "refactor: use .id on award types in history pages"
```

---

## Task 12: Fix runners/[slug].astro

**Files:**
- Modify: `src/pages/runners/[slug].astro:41`

- [ ] **Step 1: Update the profile subtitle**

Find (line 41):
```astro
    {runner.sex === 'M' ? 'Men' : 'Women'} &middot; {runner.category}
```
Replace with:
```astro
    {runner.sex === 'M' ? 'Men' : 'Women'} &middot; {runner.ageCategory}
```

- [ ] **Step 2: Commit**

```bash
git add src/pages/runners/[slug].astro
git commit -m "refactor: use runner.ageCategory in runner profile page"
```

---

## Task 13: Verify TypeScript build is clean

- [ ] **Step 1: Run the build**

```bash
npm run build
```

Expected: build completes with no TypeScript errors. Any remaining errors point to a `category` reference that was missed — fix before continuing. Do not proceed to data file updates until this passes.

---

## Task 14: Bulk update runners.json files

**Files:** `src/data/runners.json` and `src/data/{year}/{series}/runners.json` (8 files total)

- [ ] **Step 1: Replace `"category":` with `"ageCategory":` in all runners.json files**

```powershell
Get-ChildItem -Recurse -Filter "runners.json" -Path src/data | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '"category":', '"ageCategory":'
    Set-Content $_.FullName $newContent -Encoding UTF8 -NoNewline
}
```

- [ ] **Step 2: Spot-check one file**

```powershell
Select-String -Path src/data/runners.json -Pattern '"ageCategory"'
```

Expected: matches found. Also verify no `"category":` remains:

```powershell
Select-String -Path src/data/runners.json -Pattern '"category":'
```

Expected: no matches.

- [ ] **Step 3: Commit**

```bash
git add src/data/runners.json src/data/2005/road-gp/runners.json src/data/2009/road-gp/runners.json src/data/2010/road-gp/runners.json src/data/2011/road-gp/runners.json src/data/2025/road-gp/runners.json src/data/2026/fell/runners.json src/data/2026/road-gp/runners.json
git commit -m "data: rename category to ageCategory in all runners.json files"
```

---

## Task 15: Bulk update awards.json files

**Files:** `src/data/{year}/{series}/awards.json` (~52 files)

- [ ] **Step 1: Replace `"category":` with `"id":` in all awards.json files**

```powershell
Get-ChildItem -Recurse -Filter "awards.json" -Path src/data | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '"category":', '"id":'
    Set-Content $_.FullName $newContent -Encoding UTF8 -NoNewline
}
```

- [ ] **Step 2: Spot-check one file**

```powershell
Select-String -Path src/data/2025/road-gp/awards.json -Pattern '"id":'
```

Expected: matches. Also:

```powershell
Select-String -Path src/data/2025/road-gp/awards.json -Pattern '"category":'
```

Expected: no matches.

- [ ] **Step 3: Commit**

```bash
git add src/data/
git commit -m "data: rename category to id in all awards.json files"
```

---

## Task 16: Bulk update team results and team standings JSON

**Files:**
- `src/data/{year}/{series}/results/*-teams*.json` (~170 files)
- `src/data/{year}/{series}/team-standings.json` (~33 files)

- [ ] **Step 1: Replace `"category":` with `"id":` in all team results files**

```powershell
Get-ChildItem -Recurse -Path src/data -Filter "*-teams*.json" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '"category":', '"id":'
    Set-Content $_.FullName $newContent -Encoding UTF8 -NoNewline
}
```

- [ ] **Step 2: Replace `"category":` with `"id":` in all team standings files**

```powershell
Get-ChildItem -Recurse -Path src/data -Filter "team-standings.json" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '"category":', '"id":'
    Set-Content $_.FullName $newContent -Encoding UTF8 -NoNewline
}
```

- [ ] **Step 3: Spot-check**

```powershell
Select-String -Path src/data/2026/road-gp/team-standings.json -Pattern '"id":'
Select-String -Path src/data/2026/road-gp/team-standings.json -Pattern '"category":'
```

Expected: first has matches, second has none.

- [ ] **Step 4: Commit**

```bash
git add src/data/
git commit -m "data: rename category to id in team results and team standings JSON"
```

---

## Task 17: Bulk update individual standings JSON

**Files:** `src/data/{year}/{series}/individual-standings.json` (~20 files)

- [ ] **Step 1: Replace `"category":` with `"id":` in all individual standings files**

```powershell
Get-ChildItem -Recurse -Path src/data -Filter "individual-standings.json" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace '"category":', '"id":'
    Set-Content $_.FullName $newContent -Encoding UTF8 -NoNewline
}
```

- [ ] **Step 2: Spot-check**

```powershell
Select-String -Path src/data/2025/road-gp/individual-standings.json -Pattern '"id":'
Select-String -Path src/data/2025/road-gp/individual-standings.json -Pattern '"category":'
```

Expected: first has matches for category groupings; second has none. Note that runner entries inside each category use `"ageCategory"` (already correct, untouched by this replacement).

- [ ] **Step 3: Commit**

```bash
git add src/data/
git commit -m "data: rename category to id in individual standings JSON"
```

---

## Task 18: Bulk update CSV result files

**Files:** `src/data/{year}/{series}/results/*.csv` (~172 files)

Changes only the header row (line 1) of each CSV. The column value `category` only ever appears in the header — data values are things like `SEN`, `V35` — so a header-only replace is safe.

- [ ] **Step 1: Replace `category` with `age_category` in the header line of all CSV files**

```powershell
Get-ChildItem -Recurse -Path src/data -Filter "*.csv" | ForEach-Object {
    $lines = Get-Content $_.FullName
    if ($lines.Count -gt 0 -and $lines[0] -match '\bcategory\b') {
        $lines[0] = $lines[0] -replace '\bcategory\b', 'age_category'
        Set-Content $_.FullName $lines -Encoding UTF8
    }
}
```

- [ ] **Step 2: Spot-check one CSV**

```powershell
(Get-Content src/data/2025/road-gp/results/blackpool.csv)[0]
```

Expected: the header line contains `age_category` and no bare `category`.

- [ ] **Step 3: Verify no CSV header still has bare `category`**

```powershell
Get-ChildItem -Recurse -Path src/data -Filter "*.csv" | ForEach-Object {
    $first = (Get-Content $_.FullName)[0]
    if ($first -match '\bcategory\b') { Write-Output $_.FullName }
}
```

Expected: no output (all headers updated).

- [ ] **Step 4: Commit**

```bash
git add src/data/
git commit -m "data: rename category column to age_category in all result CSVs"
```

---

## Task 19: Final build verification

- [ ] **Step 1: Run the full build**

```bash
npm run build
```

Expected: completes with no errors. The build loads all CSV and JSON data eagerly via `import.meta.glob` — if any file was missed, Vite will flag a type mismatch at build time.

- [ ] **Step 2: Run the tests**

```bash
npm test
```

Expected: all tests pass.
