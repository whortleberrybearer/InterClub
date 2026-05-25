# xl Breakpoint Layout Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Introduce the `xl` (1280px) breakpoint so the sidebar+content layout widens from 896px (`max-w-4xl`) to 1024px (`max-w-5xl`) at xl, and sidebar columns grow from 220px to 260px at xl.

**Architecture:** Every page-level container currently uses `max-w-4xl mx-auto` as the universal width cap. Hero slots, chip-bars, and filter bars use the same class outside of `<main>` so they align. All sidebar grids are `lg:grid-cols-[220px_1fr]` (or the reversed variant for SeriesDetailLayout). Adding `xl:max-w-5xl` to each container and `xl:grid-cols-[260px_1fr]` to each sidebar grid is the full change — no JS, no new components, no new CSS custom properties.

**Tech Stack:** Astro v6, Tailwind CSS v4 (utility classes only — no config changes needed)

---

## File map

| File | Change |
|---|---|
| `src/components/Layout.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (nav + main, 2 places) |
| `src/components/ChipBar.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (chip row wrapper) |
| `src/components/StandingsHeader.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (back-link div + tab nav div, 2 places) |
| `src/components/IndividualResultsLayout.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (3 places); add `xl:grid-cols-[260px_1fr]` to sidebar grid |
| `src/components/IndividualStandingsLayout.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (filter bar); add `xl:grid-cols-[260px_1fr]` to sidebar grid |
| `src/components/SeriesDetailLayout.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (hero div); add `xl:grid-cols-[1fr_260px]` to sidebar grid |
| `src/components/TeamResultsLayout.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (hero div + tab nav div, 2 places); add `xl:grid-cols-[260px_1fr]` to sidebar grid |
| `src/components/TeamStandingsLayout.astro` | Fix `200px` → `220px`; add `xl:grid-cols-[260px_1fr]` to sidebar grid |
| `src/pages/runners/[slug].astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` (hero div only; sidebar already uses 260px at lg) |
| `src/pages/road-gp/[year]/[raceId].astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` |
| `src/pages/search.astro` | `max-w-4xl` → `max-w-4xl xl:max-w-5xl` |

---

## Task 1: Widen Layout.astro universal container

**Files:**
- Modify: `src/components/Layout.astro:36` and `:59`

- [ ] **Step 1: Update nav container width**

In `src/components/Layout.astro` line 36, change:
```html
<div class="flex items-center justify-between max-w-4xl mx-auto px-4 h-14">
```
to:
```html
<div class="flex items-center justify-between max-w-4xl xl:max-w-5xl mx-auto px-4 h-14">
```

- [ ] **Step 2: Update main container width**

In `src/components/Layout.astro` line 59, change:
```astro
<main class={`flex-1 max-w-4xl mx-auto w-full px-4${noPad ? '' : hasHero ? ' pt-6 pb-8' : ' py-8'}`}>
```
to:
```astro
<main class={`flex-1 max-w-4xl xl:max-w-5xl mx-auto w-full px-4${noPad ? '' : hasHero ? ' pt-6 pb-8' : ' py-8'}`}>
```

- [ ] **Step 3: Commit**
```bash
git add src/components/Layout.astro
git commit -m "feat: widen Layout container to max-w-5xl at xl breakpoint"
```

---

## Task 2: Widen ChipBar and StandingsHeader containers

These components render outside `<main>` via named slots, so they have their own `max-w-4xl` constraints that must match Layout's width.

**Files:**
- Modify: `src/components/ChipBar.astro:68`
- Modify: `src/components/StandingsHeader.astro:24` and `:37`

- [ ] **Step 1: Update ChipBar chip-row wrapper**

In `src/components/ChipBar.astro` line 68, change:
```html
<div class="max-w-4xl mx-auto sm:flex sm:items-stretch">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto sm:flex sm:items-stretch">
```

- [ ] **Step 2: Update StandingsHeader back-link container**

In `src/components/StandingsHeader.astro` line 24, change:
```html
<div class="max-w-4xl mx-auto px-4 pt-8 pb-5">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-8 pb-5">
```

- [ ] **Step 3: Update StandingsHeader tab-nav container**

In `src/components/StandingsHeader.astro` line 37, change:
```html
<div class="max-w-4xl mx-auto px-4">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4">
```

- [ ] **Step 4: Commit**
```bash
git add src/components/ChipBar.astro src/components/StandingsHeader.astro
git commit -m "feat: widen ChipBar and StandingsHeader containers at xl breakpoint"
```

---

## Task 3: Update IndividualResultsLayout

**Files:**
- Modify: `src/components/IndividualResultsLayout.astro:104`, `:147`, `:181`, `:197`

- [ ] **Step 1: Update hero section container (line 104)**

Change:
```html
<div class="max-w-4xl mx-auto px-4 pt-4 pb-4">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-4 pb-4">
```

- [ ] **Step 2: Update tab-nav container (line 147)**

Change:
```html
<div class="max-w-4xl mx-auto px-4 flex">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 flex">
```

- [ ] **Step 3: Update filter-bar container (line 181)**

Change:
```html
<div class="flex gap-2 max-w-4xl mx-auto px-4 py-2.5">
```
to:
```html
<div class="flex gap-2 max-w-4xl xl:max-w-5xl mx-auto px-4 py-2.5">
```

- [ ] **Step 4: Add xl sidebar width (line 197)**

Change:
```html
<div class="lg:grid lg:grid-cols-[220px_1fr] lg:gap-8 lg:items-start">
```
to:
```html
<div class="lg:grid lg:grid-cols-[220px_1fr] xl:grid-cols-[260px_1fr] lg:gap-8 lg:items-start">
```

- [ ] **Step 5: Commit**
```bash
git add src/components/IndividualResultsLayout.astro
git commit -m "feat: widen IndividualResultsLayout containers and sidebar at xl breakpoint"
```

---

## Task 4: Update IndividualStandingsLayout

**Files:**
- Modify: `src/components/IndividualStandingsLayout.astro:147`, `:169`

- [ ] **Step 1: Update filter-bar container (line 147)**

Change:
```html
<div class="flex gap-2 max-w-4xl mx-auto px-4 py-2.5">
```
to:
```html
<div class="flex gap-2 max-w-4xl xl:max-w-5xl mx-auto px-4 py-2.5">
```

- [ ] **Step 2: Add xl sidebar width (line 169)**

Change:
```html
<div class="lg:grid lg:grid-cols-[220px_1fr] lg:gap-8 lg:items-start">
```
to:
```html
<div class="lg:grid lg:grid-cols-[220px_1fr] xl:grid-cols-[260px_1fr] lg:gap-8 lg:items-start">
```

- [ ] **Step 3: Commit**
```bash
git add src/components/IndividualStandingsLayout.astro
git commit -m "feat: widen IndividualStandingsLayout filter bar and sidebar at xl breakpoint"
```

---

## Task 5: Update SeriesDetailLayout

**Files:**
- Modify: `src/components/SeriesDetailLayout.astro:68`, `:148`

- [ ] **Step 1: Update hero container (line 68)**

Change:
```html
<div class="max-w-4xl mx-auto px-4">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4">
```

- [ ] **Step 2: Add xl sidebar width — note sidebar is on the right in SeriesDetailLayout (line 148)**

Change:
```html
<div class="lg:grid lg:grid-cols-[1fr_220px] lg:gap-8 lg:items-start">
```
to:
```html
<div class="lg:grid lg:grid-cols-[1fr_220px] xl:grid-cols-[1fr_260px] lg:gap-8 lg:items-start">
```

- [ ] **Step 3: Commit**
```bash
git add src/components/SeriesDetailLayout.astro
git commit -m "feat: widen SeriesDetailLayout container and sidebar at xl breakpoint"
```

---

## Task 6: Update TeamResultsLayout

**Files:**
- Modify: `src/components/TeamResultsLayout.astro:43`, `:61`, `:89`

- [ ] **Step 1: Update hero back-link container (line 43)**

Change:
```html
<div class="max-w-4xl mx-auto px-4 pt-8 pb-5">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-8 pb-5">
```

- [ ] **Step 2: Update tab-nav container (line 61)**

Change:
```html
<div class="max-w-4xl mx-auto px-4">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4">
```

- [ ] **Step 3: Add xl sidebar width (line 89)**

Change:
```html
<div class="hidden lg:grid grid-cols-[220px_1fr] gap-8 items-start">
```
to:
```html
<div class="hidden lg:grid grid-cols-[220px_1fr] xl:grid-cols-[260px_1fr] gap-8 items-start">
```

- [ ] **Step 4: Commit**
```bash
git add src/components/TeamResultsLayout.astro
git commit -m "feat: widen TeamResultsLayout containers and sidebar at xl breakpoint"
```

---

## Task 7: Update TeamStandingsLayout (fix 200px inconsistency + add xl)

**Files:**
- Modify: `src/components/TeamStandingsLayout.astro:100`

- [ ] **Step 1: Fix sidebar width from 200px to 220px and add xl width (line 100)**

Change:
```html
<div class="hidden lg:grid grid-cols-[200px_1fr] gap-8 items-start">
```
to:
```html
<div class="hidden lg:grid grid-cols-[220px_1fr] xl:grid-cols-[260px_1fr] gap-8 items-start">
```

- [ ] **Step 2: Commit**
```bash
git add src/components/TeamStandingsLayout.astro
git commit -m "fix: correct TeamStandingsLayout sidebar from 200px to 220px; add xl:260px"
```

---

## Task 8: Update standalone page containers

**Files:**
- Modify: `src/pages/runners/[slug].astro:47`
- Modify: `src/pages/road-gp/[year]/[raceId].astro:56`
- Modify: `src/pages/search.astro:16`

- [ ] **Step 1: Update runners hero container (line 47)**

In `src/pages/runners/[slug].astro` line 47, change:
```html
<div class="max-w-4xl mx-auto px-4 pt-4 pb-6">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-4 pb-6">
```

Note: The runner page sidebar grid at line 79 already uses `lg:grid-cols-[260px_1fr]`, so no sidebar grid change is needed there.

- [ ] **Step 2: Update road-gp race detail page container (line 56)**

In `src/pages/road-gp/[year]/[raceId].astro` line 56, change:
```html
<div class="max-w-4xl mx-auto px-4 py-5 md:py-7">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 py-5 md:py-7">
```

- [ ] **Step 3: Update search page container (line 16)**

In `src/pages/search.astro` line 16, change:
```html
<div class="max-w-4xl mx-auto px-4 pt-5 pb-7">
```
to:
```html
<div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-5 pb-7">
```

- [ ] **Step 4: Commit**
```bash
git add src/pages/runners/[slug].astro src/pages/road-gp/[year]/[raceId].astro src/pages/search.astro
git commit -m "feat: widen standalone page containers at xl breakpoint"
```

---

## Task 9: Verify build passes

- [ ] **Step 1: Run the build**
```bash
npm run build
```
Expected: build completes with no TypeScript or Astro errors, output written to `dist/`.

- [ ] **Step 2: Smoke-check at 1280px width**

Start the preview server and open in a browser at 1280px viewport width:
```bash
npm run preview
```
Check:
- Nav bar and footer widen to ~1024px content area
- Sidebar on results/standings pages is visibly wider (260px vs 220px)
- No horizontal scroll at 1280px
- Layout at 1023px (just below lg) still shows mobile/chip-bar view correctly
- Layout at 1279px (just below xl) still shows 220px sidebar

- [ ] **Step 3: Commit if any last fixes were needed, otherwise done**
