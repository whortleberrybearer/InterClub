# Search Design

**Date:** 2026-05-19  
**Status:** Approved

## Overview

Add client-side fuzzy search to the InterClub static site. Users can search for runners by name and navigate to historical or current-year race pages. A search box in the navbar provides instant results; a dedicated `/search` page shows the full result set.

## Approach

Build-time JSON index + Fuse.js client-side fuzzy matching. The index is generated as an Astro API endpoint from existing data-loading functions. Fuse.js is loaded lazily on first interaction. No server required; no post-build tooling.

`astro-fuse` was considered and rejected — it targets markdown/content-collection sites, not JSON/CSV data pipelines.

---

## Code change: restrict race detail pages to current year

`src/pages/road-gp/[year]/[raceId].astro` currently generates a detail page for every race in every year. Change `getStaticPaths()` to only generate pages for `currentYear`.

Rationale: historical race detail pages are not useful (outdated info); historical races are already accessible via their results pages. The index only needs current-year race details.

---

## 1. Search index endpoint

**File:** `src/pages/search-index.json.ts`

An Astro API endpoint (`GET` export) that outputs a static `search-index.json` file at build time. Uses `import.meta.glob` at module scope (Vite constraint) and the existing data-loading functions.

### Record schema

```ts
type SearchRecord = {
  type: 'runner' | 'race-detail' | 'race-results' | 'year' | 'standings'
  label: string
  url: string
}
```

### Record sources

| Type | Label format | URL | Condition |
|---|---|---|---|
| `runner` | `{firstName} {lastName}` | `/runners/{slug}/` | all global runners |
| `race-detail` | `{race.name}` | `/road-gp/{currentYear}/{raceId}/` | current year road-gp only |
| `race-results` | `{race.name} Results {year}` | `/{series}/{year}/{raceId}/results/` | `hasResults()` is true |
| `year` | `Road GP {year}` / `Fell Championship {year}` | `/{series}/{year}/` | past years only |
| `standings` | `Road GP {year} Individual Standings` etc | `/{series}/{year}/individual-standings/` | file exists |
| `standings` | `Road GP {year} Team Standings` etc | `/{series}/{year}/team-standings/` | file exists |

### Standings existence check

Standings files are checked via the same `import.meta.glob` patterns already used for standings pages (`individual-standings.json`, `team-standings.json`). Only years where the file exists produce a standings record.

### Estimated index size

~900 runners + ~600 race-results entries + year/standings pages ≈ ~1,500 records. At ~80 bytes each: ~120 KB raw, ~40 KB gzipped. Fetched once per session.

---

## 2. Navbar search box

**File:** `src/components/SearchBox.astro`  
**Change:** `Layout.astro` — replace the right-hand nav buttons area to include `<SearchBox />` alongside the existing nav links.

### Markup

```
[Road GP] [Fell] [Contact]  [ Search…  ▼ ]
                             ┌──────────────────┐
                             │ 🏃 Steve Smith    │
                             │ 📄 Preston 2026   │
                             │ …                 │
                             │ See all results → │
                             └──────────────────┘
```

### Behaviour

- **Min 3 characters** — fewer than 3 chars: dropdown hidden, no search performed
- **Lazy initialisation** — on first focus: `fetch('/search-index.json')`, then `const Fuse = (await import('fuse.js')).default`, create instance. Subsequent keystrokes reuse the instance.
- **Dropdown** — top 8 results rendered as `<li>` links; each shows a small type label and the record label; footer link "See all results →" navigates to `/search?q={query}`
- **Keyboard** — `Enter` → `/search?q={query}`; `Escape` → close; `ArrowDown`/`ArrowUp` → move focus within list
- **Click outside** → close dropdown

### Fuse.js config

```js
new Fuse(records, {
  keys: ['label'],
  threshold: 0.3,
  includeScore: false,
})
```

---

## 3. Search results page

**File:** `src/pages/search.astro`

A static Astro page. All search logic runs client-side.

### Behaviour

- On load: read `?q=` from `window.location.search`; pre-fill the input; run search
- Live update: as the user types, re-run search and update the result list; update URL with `history.replaceState` (bookmarkable, no page reload)
- Same Fuse instance and config as navbar component (index fetched fresh on this page load)

### Result display

Results grouped into three sections rendered in order:

1. **Runners** — `runner` records
2. **Races** — `race-detail` and `race-results` records together
3. **Pages** — `year` and `standings` records

Each result is a plain link showing the label. The type (`race-detail`, `race-results`, etc.) is shown as a small badge.

### States

| State | Display |
|---|---|
| Query < 3 chars | "Type at least 3 characters to search" |
| No results | "No results for '{query}'" |
| Results ≤ 50 | "{n} results for '{query}'" |
| Results > 50 | "Showing 50 of {n} results — try a more specific search" |

---

## 4. Dependency

Add `fuse.js` to `package.json` dependencies. No other new packages. `astro-fuse` is not used.

---

## Files changed / created

| File | Change |
|---|---|
| `src/pages/road-gp/[year]/[raceId].astro` | Restrict `getStaticPaths()` to `currentYear` only |
| `src/pages/search-index.json.ts` | New — build-time search index endpoint |
| `src/components/SearchBox.astro` | New — navbar search input + dropdown |
| `src/components/Layout.astro` | Add `<SearchBox />` to navbar |
| `src/pages/search.astro` | New — full search results page |
| `package.json` | Add `fuse.js` dependency |
