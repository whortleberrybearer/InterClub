# Series Accent Colour Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Road GP pages use the existing amber accent; Fell pages automatically switch to teal by overriding `--color-amber` via a `data-series` attribute on `<html>`.

**Architecture:** `Layout.astro` derives the series from the build-time URL and writes `data-series="fell"` or `data-series="road-gp"` onto `<html>`. Two CSS override blocks in `global.css` remap `--color-amber` / `--color-amber-bg` to teal values for fell. Every component that already uses `text-amber`, `bg-amber`, `border-amber`, or `var(--color-amber)` picks up the correct colour automatically — no per-component changes are needed except one hardcoded colour in `PageHeader.astro`.

**Tech Stack:** Astro v6, Tailwind CSS v4 (custom CSS tokens, not DaisyUI themes), TypeScript strict.

---

### Task 1: Fix hardcoded amber in the focus ring and add the fell CSS overrides

**Files:**
- Modify: `src/styles/global.css:126` (focus shadow)
- Modify: `src/styles/global.css:195` (append fell overrides after dark-mode block)

- [ ] **Step 1: Fix the hardcoded focus shadow**

In `src/styles/global.css`, replace line 126:

```css
/* BEFORE (line 122–127) */
.input:focus,
.select:focus,
.textarea:focus {
  border-color: var(--color-amber);
  box-shadow: 0 0 0 3px oklch(72% 0.18 60 / 0.15);
}
```

```css
/* AFTER */
.input:focus,
.select:focus,
.textarea:focus {
  border-color: var(--color-amber);
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--color-amber) 20%, transparent);
}
```

- [ ] **Step 2: Append the fell accent override block**

At the end of `src/styles/global.css` (after the `html[data-theme="dark"]` block that ends at line 195), add:

```css

/* ── Series accent overrides ── */
html[data-series="fell"] {
  --color-amber:    oklch(58% 0.14 195);
  --color-amber-bg: oklch(96% 0.04 195);
}
html[data-series="fell"][data-theme="dark"] {
  --color-amber:    oklch(70% 0.12 195);
  --color-amber-bg: oklch(31% 0.05 195);
}
```

- [ ] **Step 3: Commit**

```bash
git add src/styles/global.css
git commit -m "style: remap amber token to teal for fell series pages"
```

---

### Task 2: Detect series in Layout and set data-series on html

**Files:**
- Modify: `src/components/Layout.astro:10–24`

- [ ] **Step 1: Add series detection in the frontmatter**

In `src/components/Layout.astro`, add after the existing `const base = ...` line (currently line 14):

```astro
---
import '../styles/global.css';
import SearchBox from './SearchBox.astro';

interface Props {
  title: string;
  noPad?: boolean;
}

const { title, noPad = false } = Astro.props;
const hasHero = Astro.slots.has('hero');
const base = import.meta.env.BASE_URL.replace(/\/$/, '');
const currentPath = Astro.url.pathname;

const seriesAccent = currentPath.includes('/fell')
  ? 'fell'
  : currentPath.includes('/road-gp')
  ? 'road-gp'
  : undefined;

function isActive(path: string): boolean {
  const fullPath = base + path;
  return currentPath === fullPath || currentPath.startsWith(fullPath + '/');
}
---
```

- [ ] **Step 2: Write seriesAccent to the html element**

Still in `src/components/Layout.astro`, update the `<html>` opening tag (currently line 24):

```html
<!-- BEFORE -->
<html lang="en" data-theme="light">

<!-- AFTER -->
<html lang="en" data-theme="light" data-series={seriesAccent}>
```

When `seriesAccent` is `undefined`, Astro omits the attribute entirely — non-series pages get no `data-series`, so they keep the default amber.

- [ ] **Step 3: Verify the build passes**

```bash
npm run build
```

Expected: build completes with no TypeScript errors. Check the output HTML for a fell page (e.g. `dist/fell/2026/index.html`) and confirm `data-series="fell"` is present on `<html>`. Check a road page (e.g. `dist/road-gp/2026/index.html`) and confirm `data-series="road-gp"`. Check the home page (`dist/index.html`) and confirm no `data-series` attribute.

- [ ] **Step 4: Commit**

```bash
git add src/components/Layout.astro
git commit -m "feat: set data-series on html for series-aware accent colour"
```

---

### Task 3: Fix hardcoded amber in the Provisional badge

**Files:**
- Modify: `src/components/PageHeader.astro:41`

The Provisional badge on results/standings page headers uses hardcoded oklch amber values. These won't shift when `--color-amber` is overridden, so a fell page would show an amber Provisional badge even though everything else is teal.

- [ ] **Step 1: Replace hardcoded colours with CSS variables**

In `src/components/PageHeader.astro`, replace line 41:

```html
<!-- BEFORE -->
<span class="font-head text-[10px] font-bold tracking-[0.08em] uppercase bg-[oklch(88%_0.12_60)] text-[oklch(35%_0.12_60)] px-2 py-0.5 rounded-full">
  Provisional
</span>

<!-- AFTER -->
<span class="font-head text-[10px] font-bold tracking-[0.08em] uppercase px-2 py-0.5 rounded-full" style="background: var(--color-amber-bg); color: var(--color-amber);">
  Provisional
</span>
```

- [ ] **Step 2: Verify the build passes**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/PageHeader.astro
git commit -m "fix: provisional badge uses accent token instead of hardcoded amber"
```
