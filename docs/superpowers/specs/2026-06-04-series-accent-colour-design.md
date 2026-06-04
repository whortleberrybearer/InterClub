# Series Accent Colour Design

**Date:** 2026-06-04
**Status:** Approved

## Goal

The site accent colour changes based on the series being viewed:
- **Road GP** pages (`/road-gp/**`) — amber/orange (existing default)
- **Fell** pages (`/fell/**`) — teal
- **Non-series pages** (home, runners, search, contact) — amber/orange (no change)

## Approach

URL-based series detection in `Layout.astro` sets `data-series` on `<html>` at build time. A CSS override block remaps the `--color-amber` token to teal for fell pages. No prop threading required.

## Changes

### `src/components/Layout.astro`

Detect series from `Astro.url.pathname` and write `data-series` on `<html>`:

```astro
const path = Astro.url.pathname;
const series = path.includes('/fell') ? 'fell'
  : path.includes('/road-gp') ? 'road-gp'
  : undefined;
```

```html
<html lang="en" data-theme="light" data-series={series}>
```

The existing dark-mode JS only touches `data-theme`, so there is no conflict.

### `src/styles/global.css`

Add two override blocks after the existing `html[data-theme="dark"]` block:

```css
html[data-series="fell"] {
  --color-amber:    oklch(58% 0.14 195);   /* teal (= --color-teal) */
  --color-amber-bg: oklch(96% 0.04 195);   /* teal-bg (= --color-teal-bg) */
}
html[data-series="fell"][data-theme="dark"] {
  --color-amber:    oklch(70% 0.12 195);   /* dark teal */
  --color-amber-bg: oklch(31% 0.05 195);   /* dark teal-bg */
}
```

Also fix the hardcoded amber focus shadow on line 126 to use the variable:

```css
/* before */
box-shadow: 0 0 0 3px oklch(72% 0.18 60 / 0.15);
/* after */
box-shadow: 0 0 0 3px color-mix(in oklch, var(--color-amber) 20%, transparent);
```

### `src/components/PageHeader.astro`

The Provisional badge uses hardcoded amber `oklch` values. Replace with CSS variable-based colours so it shifts with the series:

```html
<!-- before -->
<span class="... bg-[oklch(88%_0.12_60)] text-[oklch(35%_0.12_60)] ...">
<!-- after -->
<span class="... bg-[var(--color-amber-bg)] text-[var(--color-amber)] ...">
```

## Coverage

Because every accent in the UI flows through `var(--color-amber)`, this override automatically shifts:

| Element | Mechanism |
|---|---|
| Navbar active tab | `bg-amber` → CSS var |
| PageHeader eyebrow | `text-amber` → CSS var |
| PageLabel | `text-amber`, `bg-amber` → CSS var |
| ChipBar active chips | `bg-amber border-amber` → CSS var |
| Sex-toggle active buttons | `bg-amber border-amber` → CSS var |
| `btn-primary` / `btn-active` | `background: var(--color-amber)` |
| `badge-primary` | `var(--color-amber-bg)` / `var(--color-amber)` |
| Input / select / textarea focus ring | CSS var (after fix above) |
| `link-primary` | `var(--color-amber)` |
| Tab active indicator | `var(--color-amber)` |
| `SeriesDetailLayout` eyebrow + rule bullets | `text-amber` → CSS var |
| `hover:border-amber` on archive cards | → CSS var |

## Files Changed

- `src/components/Layout.astro`
- `src/styles/global.css`
- `src/components/PageHeader.astro`

## Out of Scope

- Club logo colours (`src/lib/clubColors.ts`) — unrelated
- Dark-mode toggle behaviour — unchanged
- Any test changes — no pure functions affected
