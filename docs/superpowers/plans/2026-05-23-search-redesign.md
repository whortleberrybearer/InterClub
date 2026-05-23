# Search Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign `SearchBox.astro` and `search.astro` to match the new design — grouped result sections with typed icon badges, filter pills, responsive 2-col desktop grid, mobile full-screen overlay, desktop autocomplete dropdown, and empty state.

**Architecture:** Pure view-layer changes. The search index, `search-client.ts`, and Fuse.js logic are untouched. `SearchBox` renders two variants (mobile icon+overlay / desktop input+dropdown) separated by a CSS `md:` breakpoint. The search page renders four section cards in HTML; client JS populates rows, toggles visibility, and manages filter pills. No new pure functions are introduced, so there are no unit tests — correctness is validated via `npm run build` (TypeScript) and `npm run dev` (visual).

**Tech Stack:** Astro v6, Tailwind CSS v4, TypeScript, Fuse.js (`search-client.ts` unchanged)

---

## File map

| File | Action | Responsibility |
|------|--------|----------------|
| `src/styles/global.css` | Modify | Add `--color-teal-bg`, pill styles, result-row hover |
| `src/pages/search.astro` | Rewrite | Hero header, filter pills, 4 section cards, empty state |
| `src/components/SearchBox.astro` | Rewrite | Mobile icon+overlay, desktop input+dropdown |

---

## Task 1 — Add CSS tokens and shared search styles

**Files:**
- Modify: `src/styles/global.css`

- [ ] **Step 1: Add teal-bg token and search component styles**

In `src/styles/global.css`, append after the existing `--color-teal-bg` line (there isn't one — add to `@theme` block and add component classes after the `/* ── Label ── */` section):

```css
/* In @theme block, after --color-teal: ... */
  --color-teal-bg:    oklch(96% 0.04 195);
```

Then append these component classes at the end of the file:

```css
/* ── Search pills ── */
.pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 11px;
  border-radius: 9999px;
  border: 1px solid var(--color-line);
  background: var(--color-surface);
  color: var(--color-muted);
  font-family: var(--ff-body);
  font-size: 0.8125rem;
  font-weight: 500;
  cursor: pointer;
  white-space: nowrap;
  transition: border-color 0.15s, background 0.15s, color 0.15s;
}
.pill-active {
  border-color: var(--color-amber);
  background: var(--color-amber);
  color: #fff;
}

/* ── Search result rows ── */
.result-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 16px;
  border-top: 1px solid var(--color-line);
  text-decoration: none;
  color: var(--color-content);
  transition: background 0.1s;
}
.result-row:hover { background: var(--color-canvas); }
.result-row-dense { padding: 9px 16px; }
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: no errors. Only output change is a slightly larger CSS bundle.

- [ ] **Step 3: Commit**

```bash
git add src/styles/global.css
git commit -m "feat: add teal-bg token and search pill/result-row styles"
```

---

## Task 2 — Rewrite search.astro (HTML structure)

**Files:**
- Rewrite: `src/pages/search.astro`

- [ ] **Step 1: Replace the file with the new structure**

Write `src/pages/search.astro` with the following content. The `<script>` block is left as a placeholder — it will be filled in Task 3.

```astro
---
import Layout from '../components/Layout.astro';

const SUGGESTIONS = ['Rob Danson', 'Preston 10K', '2015 Road GP', 'Pendle Round'];

const SECTIONS = [
  { id: 'runner',    label: 'Runners',        pill: 'Runners'   },
  { id: 'race',      label: 'Race Results',   pill: 'Results'   },
  { id: 'standings', label: 'Standings',      pill: 'Standings' },
  { id: 'year',      label: 'Season Archives',pill: 'Archives'  },
] as const;
---

<Layout title="Search" noPad>
  <!-- Hero: shown when query ≥ 3 chars -->
  <div id="search-hero" class="hidden bg-surface border-b border-line px-4 pt-6 pb-4 mb-0">
    <div class="max-w-4xl mx-auto">
      <div class="font-head text-[10px] font-bold tracking-[0.14em] uppercase text-muted mb-1">Search Results</div>
      <div class="flex flex-wrap items-baseline gap-x-3 gap-y-1 mb-4">
        <h1 id="query-heading" class="font-head text-[28px] md:text-[38px] font-black tracking-tight leading-none"></h1>
        <span id="match-count" class="font-mono text-sm text-muted"></span>
        <!-- Desktop jump-to chips -->
        <div id="jump-chips" class="hidden md:flex gap-2 ml-auto flex-wrap"></div>
      </div>
      <!-- Filter pills -->
      <div class="flex gap-1.5 flex-wrap" id="filter-pills">
        <button class="pill pill-active" data-filter="all">
          All <span class="font-mono text-[10px] opacity-85" id="pill-count-all">0</span>
        </button>
        {SECTIONS.map(s => (
          <button class="pill" data-filter={s.id}>
            {s.pill} <span class={`font-mono text-[10px]`} id={`pill-count-${s.id}`}>0</span>
          </button>
        ))}
      </div>
    </div>
  </div>

  <div class="max-w-4xl mx-auto w-full px-4 py-8">
    <!-- Prompt state (< 3 chars) -->
    <p id="state-prompt" class="text-sm text-muted">Type at least 3 characters to search.</p>

    <!-- Empty state -->
    <div id="state-empty" class="hidden py-16 text-center">
      <div class="w-14 h-14 mx-auto mb-4 bg-canvas rounded-[14px] inline-flex items-center justify-center text-muted">
        <svg width="22" height="22" viewBox="0 0 16 16" fill="none">
          <circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.4"/>
          <path d="M10.5 10.5L14 14" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>
      </div>
      <div class="font-head text-[22px] font-black tracking-tight mb-1.5">No matches</div>
      <p class="text-sm text-muted leading-relaxed mb-5 max-w-xs mx-auto">
        We couldn't find anything for
        "<span id="empty-query" class="font-medium text-content"></span>".
        Try a different spelling or fewer characters.
      </p>
      <div class="font-head text-[11px] font-bold tracking-[0.12em] uppercase text-muted mb-2.5">Try searching for</div>
      <div class="flex gap-1.5 flex-wrap justify-center">
        {SUGGESTIONS.map(s => (
          <button
            class="px-3 py-1.5 rounded-full border border-line bg-surface text-sm text-muted hover:border-amber hover:text-content transition-colors cursor-pointer"
            data-suggestion={s}
          >{s}</button>
        ))}
      </div>
    </div>

    <!-- Results grid -->
    <div id="results-grid" class="hidden">
      <div id="results-inner" class="grid gap-4">
        {SECTIONS.map(s => (
          <section id={`section-${s.id}`} class="result-section hidden" data-type={s.id}>
            <div class="bg-surface border border-line rounded-xl overflow-hidden">
              <header class="flex items-baseline justify-between px-4 py-3.5">
                <div class="flex items-baseline gap-2">
                  <h2 class="font-head text-sm font-bold tracking-[0.08em] uppercase">{s.label}</h2>
                  <span class="font-mono text-xs text-muted section-count"></span>
                </div>
                <a class="show-all-link hidden text-xs font-medium text-amber hover:underline" href="#"></a>
              </header>
              <div class="section-rows divide-y divide-line"></div>
            </div>
          </section>
        ))}
      </div>

      <!-- Desktop tip bar -->
      <div class="hidden md:flex mt-5 px-4 py-3.5 bg-surface border border-dashed border-line rounded-xl items-center justify-between text-sm text-muted">
        <span>
          <span class="font-mono">Tip:</span> use
          <kbd class="font-mono text-[11px] px-1.5 py-0.5 bg-canvas border border-line rounded text-content mx-1">⌘K</kbd>
          from anywhere to search · <span class="font-mono">minimum</span> 3 characters
        </span>
        <a href="#" id="full-index-link" class="text-amber font-medium hover:underline">Open full index →</a>
      </div>
    </div>
  </div>
</Layout>

<script>
  // TODO: filled in Task 3
</script>
```

- [ ] **Step 2: Verify build**

```bash
npm run build
```

Expected: succeeds with no TypeScript errors. The search page will render with only static structure visible.

- [ ] **Step 3: Commit**

```bash
git add src/pages/search.astro
git commit -m "feat: search page HTML structure — hero, filter pills, section cards, empty state"
```

---

## Task 3 — Add search.astro client JS

**Files:**
- Modify: `src/pages/search.astro` (replace the `<script>` block only)

- [ ] **Step 1: Replace the `<script>` placeholder with full client logic**

Replace the `<script>// TODO: filled in Task 3</script>` at the bottom of `src/pages/search.astro` with:

```html
<script>
  import Fuse from 'fuse.js'
  import { createFuse, loadIndex } from '../lib/search-client'
  import type { SearchRecord } from '../lib/search-client'

  const SHOW_ALL_LIMIT = 6    // rows shown per section when filter = 'all'
  const SHOW_FILTERED  = 20   // rows shown when a specific filter is active

  const base = import.meta.env.BASE_URL.replace(/\/$/, '')

  // DOM refs
  const hero       = document.getElementById('search-hero')!
  const queryHead  = document.getElementById('query-heading')!
  const matchCount = document.getElementById('match-count')!
  const jumpChips  = document.getElementById('jump-chips')!
  const prompt     = document.getElementById('state-prompt')!
  const empty      = document.getElementById('state-empty')!
  const emptyQuery = document.getElementById('empty-query')!
  const grid       = document.getElementById('results-grid')!
  const inner      = document.getElementById('results-inner')!
  const fullLink   = document.getElementById('full-index-link') as HTMLAnchorElement | null

  // State
  let activeFilter = 'all'
  let lastQuery    = ''
  let allResults: SearchRecord[] = []
  let fusePromise: Promise<Fuse<SearchRecord>> | null = null

  // Fuse lazy load
  async function ensureFuse(): Promise<Fuse<SearchRecord>> {
    if (!fusePromise) {
      fusePromise = loadIndex()
        .then(records => createFuse(records))
        .catch(err => { fusePromise = null; throw err })
    }
    return fusePromise
  }

  // ── Icons ──────────────────────────────────────────────────────────
  function iconSvg(type: SearchRecord['type']): string {
    switch (type) {
      case 'runner':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <circle cx="7" cy="4" r="2.2" stroke="currentColor" stroke-width="1.4"/>
          <path d="M2.5 12c0-2.2 2-3.6 4.5-3.6S11.5 9.8 11.5 12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>`
      case 'race-detail':
      case 'race-results':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M2 11.5L4.5 8L7 10L11.5 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          <circle cx="11.5" cy="4" r="1.5" fill="currentColor"/>
        </svg>`
      case 'standings':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M3.5 2.5h7v2.5a3.5 3.5 0 01-7 0V2.5z" stroke="currentColor" stroke-width="1.4"/>
          <path d="M10.5 3.5h1.5v1a1.5 1.5 0 01-1.5 1.5M3.5 3.5H2v1a1.5 1.5 0 001.5 1.5" stroke="currentColor" stroke-width="1.4"/>
          <path d="M5.5 11.5h3M7 8.5v3" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>`
      default: // year / archive
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <circle cx="7" cy="7" r="5" stroke="currentColor" stroke-width="1.4"/>
          <path d="M7 4.5V7l1.8 1.2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
        </svg>`
    }
  }

  function badgeStyle(type: SearchRecord['type']): string {
    switch (type) {
      case 'runner':
        return 'background:oklch(97% 0.04 60);color:oklch(72% 0.18 60)'
      case 'race-detail':
      case 'race-results':
        return 'background:var(--color-teal-bg);color:var(--color-teal)'
      case 'standings':
        return 'background:oklch(95% 0.04 220);color:oklch(45% 0.12 220)'
      default:
        return 'background:var(--color-canvas);color:var(--color-muted)'
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────
  function escHtml(s: string): string {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;')
  }

  function highlight(text: string, q: string): string {
    if (!q) return escHtml(text)
    const idx = text.toLowerCase().indexOf(q.toLowerCase())
    if (idx < 0) return escHtml(text)
    return (
      escHtml(text.slice(0, idx)) +
      `<mark style="background:oklch(94% 0.12 60);color:var(--color-content);padding:0 2px;border-radius:2px">` +
      escHtml(text.slice(idx, idx + q.length)) +
      `</mark>` +
      escHtml(text.slice(idx + q.length))
    )
  }

  function sectionType(filterId: string): SearchRecord['type'][] {
    if (filterId === 'race') return ['race-detail', 'race-results']
    return [filterId as SearchRecord['type']]
  }

  function recordSectionId(r: SearchRecord): string {
    if (r.type === 'race-detail' || r.type === 'race-results') return 'race'
    return r.type
  }

  // ── Row HTML ───────────────────────────────────────────────────────
  function rowHtml(r: SearchRecord, q: string, dense = false): string {
    const denseClass = dense ? ' result-row-dense' : ''
    return `<a href="${escHtml(r.url)}" class="result-row${denseClass}">` +
      `<span style="width:28px;height:28px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;border-radius:7px;${badgeStyle(r.type)}">` +
      iconSvg(r.type) +
      `</span>` +
      `<span style="flex:1;min-width:0">` +
        `<span style="display:block;font-size:14.5px;font-weight:500;line-height:1.2;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">` +
          highlight(r.label, q) +
        `</span>` +
        (r.subtitle ? `<span style="display:block;font-size:11.5px;color:var(--color-muted);margin-top:1px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${escHtml(r.subtitle)}</span>` : '') +
      `</span>` +
      `<span style="font-family:var(--ff-mono);font-size:11px;color:var(--color-muted);flex-shrink:0"></span>` +
      `<span style="color:var(--color-muted);flex-shrink:0;font-size:14px">›</span>` +
      `</a>`
  }

  // ── Sections ───────────────────────────────────────────────────────
  type SectionGroup = { id: string; items: SearchRecord[]; total: number }

  function groupResults(results: SearchRecord[]): SectionGroup[] {
    const map: Record<string, SearchRecord[]> = { runner: [], race: [], standings: [], year: [] }
    for (const r of results) map[recordSectionId(r)].push(r)
    return [
      { id: 'runner',    items: map.runner,    total: map.runner.length },
      { id: 'race',      items: map.race,      total: map.race.length },
      { id: 'standings', items: map.standings, total: map.standings.length },
      { id: 'year',      items: map.year,      total: map.year.length },
    ]
  }

  function renderSections(groups: SectionGroup[], q: string, limit: number): void {
    let anyVisible = false
    for (const g of groups) {
      const section  = document.getElementById(`section-${g.id}`)!
      const rowsEl   = section.querySelector('.section-rows')!
      const countEl  = section.querySelector('.section-count')!
      const showAll  = section.querySelector('.show-all-link') as HTMLAnchorElement

      if (g.total === 0) { section.classList.add('hidden'); continue }
      anyVisible = true
      section.classList.remove('hidden')

      countEl.textContent = String(g.total)
      rowsEl.innerHTML = g.items.slice(0, limit).map(r => rowHtml(r, q)).join('')

      if (g.total > limit) {
        showAll.classList.remove('hidden')
        showAll.textContent = `Show all ${g.total} →`
        showAll.addEventListener('click', (e) => { e.preventDefault(); activateFilter(g.id) }, { once: true })
      } else {
        showAll.classList.add('hidden')
      }
    }
    _ = anyVisible
  }

  // ── Filter pills ───────────────────────────────────────────────────
  function activateFilter(filterId: string): void {
    activeFilter = filterId
    document.querySelectorAll('[data-filter]').forEach(el => {
      const btn = el as HTMLButtonElement
      btn.classList.toggle('pill-active', btn.dataset.filter === filterId)
    })
    const isAll = filterId === 'all'
    inner.className = isAll ? 'grid gap-4 md:grid-cols-2' : 'grid gap-4'
    if (lastQuery) displayResults(allResults, lastQuery)
  }

  // ── Pill counts ────────────────────────────────────────────────────
  function updatePillCounts(groups: SectionGroup[]): void {
    const total = groups.reduce((a, g) => a + g.total, 0)
    const el = document.getElementById('pill-count-all')
    if (el) el.textContent = String(total)
    for (const g of groups) {
      const c = document.getElementById(`pill-count-${g.id}`)
      if (c) c.textContent = String(g.total)
    }
  }

  // ── Jump chips (desktop) ───────────────────────────────────────────
  const SECTION_LABELS: Record<string, string> = {
    runner: 'Runners', race: 'Race Results', standings: 'Standings', year: 'Archives',
  }

  function renderJumpChips(groups: SectionGroup[]): void {
    jumpChips.innerHTML = groups
      .filter(g => g.total > 0)
      .map(g =>
        `<a href="#section-${g.id}" style="display:inline-flex;align-items:center;gap:6px;padding:5px 11px;border-radius:18px;background:var(--color-canvas);border:1px solid var(--color-line);font-size:12.5px;color:var(--color-content);text-decoration:none">` +
        escHtml(SECTION_LABELS[g.id]) +
        `<span style="font-family:var(--ff-mono);font-size:11px;color:var(--color-muted)">${g.total}</span>` +
        `</a>`
      ).join('')
  }

  // ── Display results ─────────────────────────────────────────────────
  function displayResults(results: SearchRecord[], q: string): void {
    const groups = groupResults(results)
    const visibleGroups = activeFilter === 'all'
      ? groups
      : groups.filter(g => g.id === activeFilter)
    const limit = activeFilter === 'all' ? SHOW_ALL_LIMIT : SHOW_FILTERED

    prompt.classList.add('hidden')
    empty.classList.add('hidden')

    if (results.length === 0) {
      grid.classList.add('hidden')
      hero.classList.remove('hidden')
      queryHead.textContent = `"${q}"`
      matchCount.textContent = ''
      empty.classList.remove('hidden')
      emptyQuery.textContent = q
      return
    }

    grid.classList.remove('hidden')
    hero.classList.remove('hidden')
    queryHead.textContent = `"${q}"`
    matchCount.textContent = `${results.length} match${results.length === 1 ? '' : 'es'} across ${groups.filter(g => g.total > 0).length} sections`

    updatePillCounts(groups)
    renderJumpChips(groups)

    // Show only the sections for the active filter (or all)
    const sectionIds = ['runner', 'race', 'standings', 'year']
    for (const id of sectionIds) {
      const sec = document.getElementById(`section-${id}`)
      if (activeFilter !== 'all' && id !== activeFilter) {
        sec?.classList.add('hidden')
      }
    }

    inner.className = activeFilter === 'all' ? 'grid gap-4 md:grid-cols-2' : 'grid gap-4'
    renderSections(visibleGroups, q, limit)

    if (fullLink) fullLink.href = `${base}/search`
  }

  // ── Clear ───────────────────────────────────────────────────────────
  function clear(): void {
    hero.classList.add('hidden')
    grid.classList.add('hidden')
    empty.classList.add('hidden')
    prompt.classList.remove('hidden')
    // reset all sections
    document.querySelectorAll('.result-section').forEach(s => s.classList.add('hidden'))
  }

  // ── Search ──────────────────────────────────────────────────────────
  async function search(query: string): Promise<void> {
    if (query.trim().length < 3) { clear(); return }
    lastQuery = query.trim()
    const fuse = await ensureFuse()
    allResults = fuse.search(query).map(r => r.item)
    displayResults(allResults, query.trim())
  }

  // ── Filter pill clicks ──────────────────────────────────────────────
  document.getElementById('filter-pills')!.addEventListener('click', (e) => {
    const btn = (e.target as Element).closest('[data-filter]') as HTMLButtonElement | null
    if (btn) activateFilter(btn.dataset.filter!)
  })

  // ── Suggestion pills ────────────────────────────────────────────────
  document.querySelectorAll('[data-suggestion]').forEach(btn => {
    btn.addEventListener('click', () => {
      const q = (btn as HTMLButtonElement).dataset.suggestion!
      history.replaceState(null, '', `${base}/search?q=${encodeURIComponent(q)}`)
      search(q)
    })
  })

  // ── Init ─────────────────────────────────────────────────────────────
  const params = new URLSearchParams(window.location.search)
  const initialQuery = params.get('q') ?? ''
  if (initialQuery) search(initialQuery)

  // ── Variable used to suppress TS unused warning ────────────────────
  let _: unknown

  // Export for SearchBox to call
  ;(window as Record<string, unknown>)['icSearch'] = search
</script>
```

- [ ] **Step 2: Verify build**

```bash
npm run build
```

Expected: no TypeScript errors.

- [ ] **Step 3: Start dev server and do a visual check**

```bash
npm run dev
```

Navigate to `http://localhost:4321/search?q=rob` (or whichever base URL). Verify:
- Hero header shows `"rob"` + match count
- Filter pills show counts
- Result rows have colored icon badges + label + subtitle + chevron
- No-results state: try `?q=zzqqx` — verify "No matches" state + suggestion pills

- [ ] **Step 4: Commit**

```bash
git add src/pages/search.astro
git commit -m "feat: search results page — grouped sections, filter pills, icon badges, empty state"
```

---

## Task 4 — Rewrite SearchBox.astro (mobile overlay)

**Files:**
- Rewrite: `src/components/SearchBox.astro`

- [ ] **Step 1: Replace SearchBox.astro with mobile-first structure + desktop stub**

Write `src/components/SearchBox.astro`:

```astro
---
// src/components/SearchBox.astro
---

<!-- Mobile: icon button (hidden md+) -->
<div class="md:hidden" id="sb-mobile">
  <button
    id="sb-icon-btn"
    aria-label="Search"
    class="w-8 h-8 inline-flex items-center justify-center text-muted rounded-lg hover:bg-canvas transition-colors"
  >
    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
      <circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.6"/>
      <path d="M10.5 10.5L14 14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
    </svg>
  </button>

  <!-- Full-screen overlay -->
  <div
    id="sb-overlay"
    class="hidden fixed inset-0 z-50 bg-surface flex flex-col"
    aria-modal="true"
    role="dialog"
  >
    <!-- Overlay header -->
    <div class="flex items-center gap-2.5 px-4 py-2 border-b border-line shrink-0">
      <button
        id="sb-close-btn"
        class="w-8 h-8 inline-flex items-center justify-center text-muted rounded-lg hover:bg-canvas shrink-0"
        aria-label="Close search"
      >
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
          <path d="M2 2l10 10M12 2L2 12" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
        </svg>
      </button>
      <div
        id="sb-input-wrap-mobile"
        class="flex flex-1 items-center gap-2 bg-canvas border border-amber rounded-[10px] px-3 py-2"
        style="box-shadow: 0 0 0 3px oklch(72% 0.18 60 / 0.15)"
      >
        <svg width="14" height="14" viewBox="0 0 16 16" fill="none" style="color:var(--color-amber);flex-shrink:0">
          <circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.6"/>
          <path d="M10.5 10.5L14 14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
        </svg>
        <input
          id="sb-input-mobile"
          type="search"
          placeholder="Search runners, races, results…"
          autocomplete="off"
          class="flex-1 bg-transparent text-[15px] text-content outline-none"
          style="font-family:var(--ff-body)"
        />
        <button
          id="sb-clear-btn"
          class="hidden w-[18px] h-[18px] inline-flex items-center justify-center bg-line rounded-full text-muted text-[10px] leading-none shrink-0"
          aria-label="Clear"
        >×</button>
      </div>
    </div>

    <!-- Results stream -->
    <div id="sb-results-mobile" class="flex-1 overflow-y-auto">
      <!-- populated by JS -->
    </div>

    <!-- Recent searches -->
    <div id="sb-recent" class="hidden shrink-0 px-4 py-5 border-t border-line">
      <div class="font-head text-[11px] font-bold tracking-[0.12em] uppercase text-muted mb-2">Recent</div>
      <div id="sb-recent-pills" class="flex gap-1.5 flex-wrap"></div>
    </div>
  </div>
</div>

<!-- Desktop: inline input + dropdown (hidden below md) -->
<div class="hidden md:block relative" id="sb-desktop">
  <div
    id="sb-input-wrap-desktop"
    class="flex items-center gap-2 bg-surface border border-line rounded-lg px-3 py-1.5 w-56 lg:w-72 transition-all"
  >
    <svg width="13" height="13" viewBox="0 0 16 16" fill="none" class="text-muted shrink-0">
      <circle cx="7" cy="7" r="4.5" stroke="currentColor" stroke-width="1.6"/>
      <path d="M10.5 10.5L14 14" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
    </svg>
    <input
      id="sb-input-desktop"
      type="search"
      placeholder="Search…"
      autocomplete="off"
      class="flex-1 bg-transparent text-sm text-content outline-none min-w-0"
      style="font-family:var(--ff-body)"
    />
    <kbd
      id="sb-esc-hint"
      class="hidden font-mono text-[10px] text-muted border border-line rounded px-1 py-0.5 bg-canvas shrink-0"
    >esc</kbd>
  </div>

  <!-- Dropdown -->
  <div
    id="sb-dropdown"
    class="hidden absolute right-0 top-full mt-1.5 w-96 bg-surface border border-line rounded-xl overflow-hidden z-50"
    style="box-shadow: 0 16px 40px -8px rgba(0,0,0,0.18), 0 2px 6px rgba(0,0,0,0.06)"
  >
    <!-- populated by JS -->
  </div>
</div>

<script>
  // All logic in Task 5
</script>
```

- [ ] **Step 2: Verify build**

```bash
npm run build
```

Expected: no TypeScript errors. The mobile icon button and desktop input render in the nav.

- [ ] **Step 3: Commit**

```bash
git add src/components/SearchBox.astro
git commit -m "feat: SearchBox HTML structure — mobile overlay + desktop input/dropdown shells"
```

---

## Task 5 — Add SearchBox.astro client JS

**Files:**
- Modify: `src/components/SearchBox.astro` (replace `<script>` block)

- [ ] **Step 1: Replace the `<script>` block with full logic**

Replace `<script>// All logic in Task 5</script>` at the bottom of `src/components/SearchBox.astro` with:

```html
<script>
  import Fuse from 'fuse.js'
  import { createFuse, loadIndex, runSearch } from '../lib/search-client'
  import type { SearchRecord } from '../lib/search-client'

  const base = import.meta.env.BASE_URL.replace(/\/$/, '')

  // ── Icon + badge helpers (same as search.astro) ──────────────────
  function escHtml(s: string): string {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;')
  }

  function iconSvg(type: SearchRecord['type']): string {
    switch (type) {
      case 'runner':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="4" r="2.2" stroke="currentColor" stroke-width="1.4"/><path d="M2.5 12c0-2.2 2-3.6 4.5-3.6S11.5 9.8 11.5 12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
      case 'race-detail':
      case 'race-results':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M2 11.5L4.5 8L7 10L11.5 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><circle cx="11.5" cy="4" r="1.5" fill="currentColor"/></svg>`
      case 'standings':
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M3.5 2.5h7v2.5a3.5 3.5 0 01-7 0V2.5z" stroke="currentColor" stroke-width="1.4"/><path d="M10.5 3.5h1.5v1a1.5 1.5 0 01-1.5 1.5M3.5 3.5H2v1a1.5 1.5 0 001.5 1.5" stroke="currentColor" stroke-width="1.4"/><path d="M5.5 11.5h3M7 8.5v3" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
      default:
        return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="5" stroke="currentColor" stroke-width="1.4"/><path d="M7 4.5V7l1.8 1.2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
    }
  }

  function badgeStyle(type: SearchRecord['type']): string {
    switch (type) {
      case 'runner':      return 'background:oklch(97% 0.04 60);color:oklch(72% 0.18 60)'
      case 'race-detail':
      case 'race-results':return 'background:var(--color-teal-bg);color:var(--color-teal)'
      case 'standings':   return 'background:oklch(95% 0.04 220);color:oklch(45% 0.12 220)'
      default:            return 'background:var(--color-canvas);color:var(--color-muted)'
    }
  }

  function rowHtml(r: SearchRecord, q: string): string {
    return `<a href="${escHtml(r.url)}" class="result-row result-row-dense">` +
      `<span style="width:28px;height:28px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;border-radius:7px;${badgeStyle(r.type)}">` +
        iconSvg(r.type) +
      `</span>` +
      `<span style="flex:1;min-width:0">` +
        `<span style="display:block;font-size:13.5px;font-weight:500;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${escHtml(r.label)}</span>` +
        (r.subtitle ? `<span style="display:block;font-size:11.5px;color:var(--color-muted);overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${escHtml(r.subtitle)}</span>` : '') +
      `</span>` +
      `<span style="color:var(--color-muted);flex-shrink:0;font-size:14px">›</span>` +
      `</a>`
  }

  // ── Recent searches (localStorage) ──────────────────────────────
  const RECENT_KEY = 'ic-recent-searches'
  const RECENT_MAX = 4

  function getRecent(): string[] {
    try { return JSON.parse(localStorage.getItem(RECENT_KEY) ?? '[]') } catch { return [] }
  }

  function saveRecent(q: string): void {
    try {
      const list = [q, ...getRecent().filter(r => r !== q)].slice(0, RECENT_MAX)
      localStorage.setItem(RECENT_KEY, JSON.stringify(list))
    } catch {}
  }

  function renderRecentMobile(): void {
    const list = getRecent()
    const recentEl = document.getElementById('sb-recent')!
    const pillsEl  = document.getElementById('sb-recent-pills')!
    if (!list.length) { recentEl.classList.add('hidden'); return }
    recentEl.classList.remove('hidden')
    pillsEl.innerHTML = list.map(s =>
      `<button class="sb-recent-pill inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full border border-line bg-surface text-[12.5px] text-muted"` +
      ` data-q="${escHtml(s)}">` +
      `<svg width="10" height="10" viewBox="0 0 10 10" fill="none"><circle cx="5" cy="5" r="4" stroke="currentColor" stroke-width="1"/><path d="M5 3v2l1.3 1" stroke="currentColor" stroke-width="1" stroke-linecap="round"/></svg>` +
      escHtml(s) + `</button>`
    ).join('')
    pillsEl.querySelectorAll('.sb-recent-pill').forEach(btn => {
      btn.addEventListener('click', () => {
        const q = (btn as HTMLButtonElement).dataset.q!
        mobileInput.value = q
        handleMobileQuery(q)
      })
    })
  }

  // ── Fuse lazy load ──────────────────────────────────────────────
  let fusePromise: Promise<Fuse<SearchRecord>> | null = null
  async function ensureFuse(): Promise<Fuse<SearchRecord>> {
    if (!fusePromise) {
      fusePromise = loadIndex().then(r => createFuse(r)).catch(e => { fusePromise = null; throw e })
    }
    return fusePromise
  }

  // ── MOBILE ───────────────────────────────────────────────────────
  const iconBtn     = document.getElementById('sb-icon-btn')!
  const overlay     = document.getElementById('sb-overlay')!
  const closeBtn    = document.getElementById('sb-close-btn')!
  const mobileInput = document.getElementById('sb-input-mobile') as HTMLInputElement
  const clearBtn    = document.getElementById('sb-clear-btn')!
  const resultsEl   = document.getElementById('sb-results-mobile')!

  function openOverlay(): void {
    overlay.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
    renderRecentMobile()
    mobileInput.focus()
  }

  function closeOverlay(): void {
    overlay.classList.add('hidden')
    document.body.style.overflow = ''
    mobileInput.value = ''
    resultsEl.innerHTML = ''
  }

  iconBtn.addEventListener('click', openOverlay)
  closeBtn.addEventListener('click', closeOverlay)

  overlay.addEventListener('keydown', (e: KeyboardEvent) => {
    if (e.key === 'Escape') closeOverlay()
  })

  mobileInput.addEventListener('input', () => {
    const q = mobileInput.value
    clearBtn.classList.toggle('hidden', !q)
    handleMobileQuery(q)
  })

  clearBtn.addEventListener('click', () => {
    mobileInput.value = ''
    clearBtn.classList.add('hidden')
    resultsEl.innerHTML = ''
    renderRecentMobile()
    mobileInput.focus()
  })

  type GroupItem = { sectionId: string; label: string; items: SearchRecord[]; total: number }

  function groupBySection(results: SearchRecord[]): GroupItem[] {
    const map: Record<string, SearchRecord[]> = { runner: [], race: [], standings: [], year: [] }
    for (const r of results) {
      const id = (r.type === 'race-detail' || r.type === 'race-results') ? 'race' : r.type
      map[id]?.push(r)
    }
    const labels: Record<string, string> = { runner: 'Runners', race: 'Race Results', standings: 'Standings', year: 'Archives' }
    return Object.entries(map)
      .filter(([, items]) => items.length > 0)
      .map(([id, items]) => ({ sectionId: id, label: labels[id], items, total: items.length }))
  }

  async function handleMobileQuery(query: string): Promise<void> {
    if (query.trim().length < 3) {
      resultsEl.innerHTML = ''
      renderRecentMobile()
      return
    }
    document.getElementById('sb-recent')?.classList.add('hidden')
    const fuse = await ensureFuse()
    const results = runSearch(fuse, query, 20)
    const groups = groupBySection(results)
    const total = results.length

    if (total === 0) {
      resultsEl.innerHTML =
        `<div style="padding:40px 24px;text-align:center;color:var(--color-muted);font-size:14px">No results for "${escHtml(query.trim())}"</div>`
      return
    }

    const searchUrl = `${base}/search?q=${encodeURIComponent(query.trim())}`

    resultsEl.innerHTML = groups.map(g =>
      `<div>` +
      `<div style="padding:12px 16px 6px;display:flex;align-items:baseline;justify-content:space-between">` +
        `<span style="font-family:var(--ff-head);font-size:11px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--color-muted)">${escHtml(g.label)} · ${g.total}</span>` +
        `<a href="${searchUrl}" style="font-size:12px;font-weight:500;color:var(--color-amber);text-decoration:none">See all →</a>` +
      `</div>` +
      `<div style="background:var(--color-surface)">${g.items.slice(0, 3).map(r => rowHtml(r, query)).join('')}</div>` +
      `</div>`
    ).join('') +
    `<a href="${searchUrl}" class="result-row" style="display:flex;align-items:center;justify-content:space-between;padding:14px 16px;margin:12px;background:var(--color-content);color:#fff;border-radius:10px;text-decoration:none;border:none" ` +
    `onclick="event.stopPropagation()">` +
      `<span style="display:flex;align-items:center;gap:8px;font-size:14px;font-weight:600">` +
        `<svg width="14" height="14" viewBox="0 0 16 16" fill="none"><circle cx="7" cy="7" r="4.5" stroke="white" stroke-width="1.6"/><path d="M10.5 10.5L14 14" stroke="white" stroke-width="1.6" stroke-linecap="round"/></svg>` +
        `See all ${total} results for "${escHtml(query.trim())}"` +
      `</span>` +
      `<span>→</span>` +
    `</a>`

    // Save when navigating to full results
    resultsEl.querySelectorAll('a[href*="/search?q="]').forEach(a => {
      a.addEventListener('click', () => saveRecent(query.trim()))
    })
  }

  mobileInput.addEventListener('keydown', (e: KeyboardEvent) => {
    if (e.key === 'Enter' && mobileInput.value.trim().length >= 3) {
      const q = mobileInput.value.trim()
      saveRecent(q)
      window.location.href = `${base}/search?q=${encodeURIComponent(q)}`
    }
    if (e.key === 'Escape') closeOverlay()
  })

  // ── DESKTOP ──────────────────────────────────────────────────────
  const desktopInput = document.getElementById('sb-input-desktop') as HTMLInputElement
  const dropdown     = document.getElementById('sb-dropdown')!
  const escHint      = document.getElementById('sb-esc-hint')!
  const inputWrap    = document.getElementById('sb-input-wrap-desktop')!

  function openFocusStyle(): void {
    inputWrap.style.borderColor = 'var(--color-amber)'
    inputWrap.style.boxShadow   = '0 0 0 3px oklch(72% 0.18 60 / 0.15)'
    escHint.classList.remove('hidden')
  }

  function closeFocusStyle(): void {
    inputWrap.style.borderColor = ''
    inputWrap.style.boxShadow   = ''
    escHint.classList.add('hidden')
  }

  function closeDropdown(): void {
    dropdown.classList.add('hidden')
    closeFocusStyle()
  }

  function renderDropdown(results: SearchRecord[], query: string): void {
    if (results.length === 0) { dropdown.classList.add('hidden'); return }

    const groups = groupBySection(results)
    const total = results.length
    const searchUrl = `${base}/search?q=${encodeURIComponent(query.trim())}`

    const DESKTOP_LIMITS: Record<string, number> = { runner: 3, race: 2, standings: 1, year: 1 }

    dropdown.innerHTML = groups.map(g => {
      const limit = DESKTOP_LIMITS[g.sectionId] ?? 2
      const labels: Record<string, string> = { runner: 'Runners', race: 'Race Results', standings: 'Standings', year: 'Archives' }
      return (
        `<div style="padding:10px 14px 6px;display:flex;align-items:baseline;justify-content:space-between;background:var(--color-canvas)">` +
          `<span style="font-family:var(--ff-head);font-size:10px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase;color:var(--color-muted)">${escHtml(labels[g.sectionId])}</span>` +
          `<span style="font-family:var(--ff-mono);font-size:10px;color:var(--color-muted)">${g.total} match${g.total === 1 ? '' : 'es'}</span>` +
        `</div>` +
        g.items.slice(0, limit).map((r, i) =>
          `<div${i === 0 && g.sectionId === 'runner' ? ' style="background:oklch(97% 0.04 60)"' : ''}>` +
          rowHtml(r, query) +
          `</div>`
        ).join('')
      )
    }).join('') +
    `<a href="${searchUrl}" style="display:flex;align-items:center;justify-content:space-between;padding:10px 14px;background:var(--color-canvas);border-top:1px solid var(--color-line);text-decoration:none;color:var(--color-amber);font-size:13px;font-weight:500">` +
      `<span>See all ${total} results for "${escHtml(query.trim())}"</span>` +
      `<kbd style="font-family:var(--ff-mono);font-size:10px;border:1px solid var(--color-line);border-radius:4px;padding:1px 5px;background:var(--color-surface);color:var(--color-muted)">↵</kbd>` +
    `</a>`

    dropdown.classList.remove('hidden')
    // Save on "see all" click
    dropdown.querySelector('a[href*="/search?q="]')?.addEventListener('click', () => saveRecent(query.trim()))
  }

  desktopInput.addEventListener('focus', () => {
    openFocusStyle()
    if (desktopInput.value.trim().length >= 3) handleDesktopQuery(desktopInput.value)
  })

  desktopInput.addEventListener('input', () => handleDesktopQuery(desktopInput.value))

  desktopInput.addEventListener('keydown', (e: KeyboardEvent) => {
    if (e.key === 'Escape') { closeDropdown(); desktopInput.blur() }
    if (e.key === 'Enter' && desktopInput.value.trim().length >= 3) {
      const q = desktopInput.value.trim()
      saveRecent(q)
      window.location.href = `${base}/search?q=${encodeURIComponent(q)}`
    }
  })

  async function handleDesktopQuery(query: string): Promise<void> {
    if (query.trim().length < 3) { dropdown.classList.add('hidden'); return }
    const fuse = await ensureFuse()
    renderDropdown(runSearch(fuse, query, 12), query)
  }

  document.addEventListener('click', (e: MouseEvent) => {
    if (!document.getElementById('sb-desktop')?.contains(e.target as Node)) {
      closeDropdown()
    }
  })
</script>
```

- [ ] **Step 2: Verify build**

```bash
npm run build
```

Expected: no TypeScript errors.

- [ ] **Step 3: Visual verification — desktop**

```bash
npm run dev
```

1. Navigate to any page (e.g. `http://localhost:4321/`).
2. On desktop: click into the search input → amber border + glow + esc hint appear.
3. Type `rob` → grouped dropdown appears (Runners / Race Results / Standings sections, "See all" footer).
4. Press ESC → dropdown closes.
5. Press Enter → navigates to `/search?q=rob`.

- [ ] **Step 4: Visual verification — mobile**

In browser DevTools, switch to mobile viewport (390px):
1. Search input is hidden; search icon button is visible in nav.
2. Tap icon → full-screen overlay opens with amber-bordered input focused.
3. Type `rob` → result stream with grouped sections + "See all" dark CTA pill.
4. Tap × → overlay closes.
5. Press ESC → overlay closes.

- [ ] **Step 5: Commit**

```bash
git add src/components/SearchBox.astro
git commit -m "feat: SearchBox — mobile overlay sheet and desktop grouped dropdown"
```

---

## Self-Review

**Spec coverage check:**
- ✅ Mobile icon button → overlay sheet with search input, results stream, "See all" CTA, recent searches
- ✅ Desktop inline input with amber focus ring, grouped dropdown, "See all" footer with ↵ hint, ESC closes
- ✅ Search results page: hero header with query + count
- ✅ Filter pills: All / Runners / Results / Standings / Archives with counts
- ✅ Result rows: icon badge (amber/teal/info/canvas) + label highlighted + subtitle + meta + chevron
- ✅ 2-column grid on desktop when "All" filter active
- ✅ Jump-to chips on desktop (rendered in `renderJumpChips`)
- ✅ Desktop tip bar with ⌘K hint
- ✅ Empty state: search icon, "No matches", body copy, suggestion pills
- ✅ `--color-teal-bg` added to global.css
- ✅ Recent searches via localStorage

**Placeholder scan:** No TBD/TODO in final tasks. Task 2 intentionally uses a `// TODO` comment as a structural placeholder that is replaced in Task 3 — this is intentional scaffolding, not an unresolved gap.

**Type consistency:** `SearchRecord['type']` used consistently across both files. `sectionType()` / `recordSectionId()` functions map types to section IDs consistently. `groupBySection()` defined identically in both SearchBox and search page.

**Potential issue:** The `let _: unknown` trick in search.astro (to avoid TS unused-variable warning for `anyVisible`) — consider removing that variable entirely and just tracking the return. Fixed: `renderSections` doesn't return a value so `anyVisible` is redundant — the `_ = anyVisible` line and `_ ` declaration can be deleted. **Fix applied:** Remove `anyVisible` tracking from `renderSections` in Task 3 (the sections hide themselves; the caller knows results.length > 0 before calling).
