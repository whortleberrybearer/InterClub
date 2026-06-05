# PageHeader Stacked Two-Colour Title — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional `titleAccent` prop to `PageHeader.astro` that renders a bold amber second line below the main title, matching the editorial style of the team winners history page, then update all layout components and direct `PageHeader` users to pass an appropriate accent value.

**Architecture:** `PageHeader.astro` gains a new optional prop and renders a second `<span class="block text-amber">` inside the `<h1>`. Font size increases to `clamp(2.2rem, 5vw, 3.8rem)` with `font-black leading-none`. Each layout component adds a `titleAccent` prop call with a value specific to its page type. No new files are created.

**Tech Stack:** Astro v6, Tailwind CSS v4, TypeScript (strict). Verification via `npm run build` (TypeScript errors in Astro pages only surface here). No unit tests apply — these are template-only changes.

---

### Task 1: Update PageHeader.astro — add `titleAccent` prop and new markup

**Files:**
- Modify: `src/components/PageHeader.astro`

The complete new file — replace in full:

- [ ] **Step 1: Replace PageHeader.astro with the updated version**

```astro
---
// src/components/PageHeader.astro
//
// Shared dark hero header used across all detail pages:
//   race results, team results, individual/team standings, runner profiles.
// Renders the full-bleed bg-hdr-dark band with:
//   - an optional amber eyebrow line (e.g. "Road GP 2026 · Race 1 of 7")
//   - a bold h1 with optional amber accent second line
//   - an optional Provisional badge below the title
//   - an optional muted mono subtitle row (items separated by 1px lines)
//   - an optional tab strip via the default slot (separator line is handled here)

export interface Props {
  /** Amber label rendered above the title, e.g. "Road GP 2026 · Race 1 of 7". */
  eyebrow?: string;
  /** Main page heading (first line, white). */
  title: string;
  /** Optional second line rendered in amber at the same large size. */
  titleAccent?: string;
  /** Optional metadata items rendered as a muted mono row with 1 px separators. */
  subtitleParts?: string[];
  /** When true, shows a "Provisional" badge below the title. */
  provisional?: boolean;
}

const { eyebrow, title, titleAccent, subtitleParts = [], provisional = false } = Astro.props;
const hasTabStrip = Astro.slots.has('default');
const hasActions = Astro.slots.has('actions');
---

<div class="bg-hdr-dark text-hdr-text">
  <div class="max-w-4xl xl:max-w-5xl mx-auto px-4 pt-4 pb-4">

    {eyebrow && (
      <p class="font-head text-[11px] font-bold tracking-[0.14em] uppercase text-amber mb-1.5">
        {eyebrow}
      </p>
    )}

    <div class="flex items-start justify-between gap-4 mb-1">
      <div>
        <h1 class="font-head font-black tracking-tight leading-none" style="font-size: clamp(2.2rem, 5vw, 3.8rem)">
          <span class="block">{title}</span>
          {titleAccent && <span class="block text-amber">{titleAccent}</span>}
        </h1>
        {provisional && (
          <span class="inline-block mt-2 font-head text-[10px] font-bold tracking-[0.08em] uppercase px-2 py-0.5 rounded-full" style="background: var(--color-amber-bg); color: var(--color-amber);">
            Provisional
          </span>
        )}
      </div>
      {hasActions && (
        <div class="flex items-center gap-2 shrink-0 mt-1">
          <slot name="actions" />
        </div>
      )}
    </div>

    <div class="flex items-center flex-wrap gap-x-2.5 gap-y-0.5 font-mono text-[12px] text-hdr-muted mt-2 min-h-[18px]">
      {subtitleParts.map((part, i) => (
        <>
          {i > 0 && <span class="w-px h-[11px] bg-white/20 self-center flex-shrink-0" />}
          <span>{part}</span>
        </>
      ))}
    </div>

  </div>

  {hasTabStrip && (
    <div class="border-t border-white/10">
      <div class="max-w-4xl xl:max-w-5xl mx-auto px-4">
        <slot />
      </div>
    </div>
  )}
</div>
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds (zero TypeScript errors). Existing callers without `titleAccent` are unaffected because the prop is optional.

- [ ] **Step 3: Commit**

```bash
git add src/components/PageHeader.astro
git commit -m "feat: add titleAccent prop and larger font to PageHeader"
```

---

### Task 2: Update SeriesDetailLayout.astro — add year as accent

**Files:**
- Modify: `src/components/SeriesDetailLayout.astro:55-69`

`seriesTitle` is already the bare series name ("Road Grand Prix" / "Fell Championship") — no splitting required. `year` is already available as a prop.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `SeriesDetailLayout.astro`, find the `<PageHeader` block (around line 55) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`${year} Season`}
    title={seriesTitle}
    titleAccent={String(year)}
    subtitleParts={subtitleParts}
  >
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/components/SeriesDetailLayout.astro
git commit -m "feat: add year accent to SeriesDetailLayout header"
```

---

### Task 3: Update IndividualResultsLayout.astro — add "Individual Results" accent

**Files:**
- Modify: `src/components/IndividualResultsLayout.astro:136-157`

`title` is the race name (e.g. "Chorley 10k"). The accent identifies the page type.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `IndividualResultsLayout.astro`, find the `<PageHeader` block (around line 136) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`${seriesLabel} ${year}${raceNumber != null ? ` · Race ${raceNumber}${raceTotal > 1 ? ` of ${raceTotal}` : ''}` : ''}`}
    title={title}
    titleAccent="Individual Results"
    subtitleParts={raceMeta}
    provisional={provisional}
  >
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/components/IndividualResultsLayout.astro
git commit -m "feat: add Individual Results accent to results header"
```

---

### Task 4: Update TeamResultsLayout.astro — add "Team Results" accent

**Files:**
- Modify: `src/components/TeamResultsLayout.astro:53-70`

`title` is the race name. The accent identifies the page type.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `TeamResultsLayout.astro`, find the `<PageHeader` block (around line 53) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`${seriesLabel} ${year}${raceNumber != null ? ` · Race ${raceNumber}${raceTotal > 1 ? ` of ${raceTotal}` : ''}` : ''}`}
    title={title}
    titleAccent="Team Results"
    subtitleParts={raceMeta}
    provisional={provisional}
  >
```

All variables (`seriesLabel`, `year`, `raceNumber`, `raceTotal`, `raceMeta`, `title`, `provisional`) are defined in the frontmatter at lines 31–44 with the same names as in `IndividualResultsLayout`.

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 4: Commit**

```bash
git add src/components/TeamResultsLayout.astro
git commit -m "feat: add Team Results accent to team results header"
```

---

### Task 5: Update IndividualStandingsLayout.astro — add series + year accent

**Files:**
- Modify: `src/components/IndividualStandingsLayout.astro:144-160`

`seriesLabel` (e.g. "Road Grand Prix") and `year` are already defined in the frontmatter.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `IndividualStandingsLayout.astro`, find the `<PageHeader` block (around line 144) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`${seriesLabel} ${year} · Season Standings`}
    title="Individual Standings"
    titleAccent={`${seriesLabel} ${year}`}
    provisional={standings.provisional}
  >
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/components/IndividualStandingsLayout.astro
git commit -m "feat: add series/year accent to individual standings header"
```

---

### Task 6: Update TeamStandingsLayout.astro — add series + year accent

**Files:**
- Modify: `src/components/TeamStandingsLayout.astro:61-77`

`seriesLabel` and `year` are already defined in the frontmatter.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `TeamStandingsLayout.astro`, find the `<PageHeader` block (around line 61) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`${seriesLabel} ${year} · Season Standings`}
    title="Team Standings"
    titleAccent={`${seriesLabel} ${year}`}
    provisional={standings.provisional}
  >
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/components/TeamStandingsLayout.astro
git commit -m "feat: add series/year accent to team standings header"
```

---

### Task 7: Update runners/[slug].astro — add "Runner Profile" accent

**Files:**
- Modify: `src/pages/runners/[slug].astro:46-51`

`title` is the runner's full name. `currentClubName` is already the eyebrow.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `src/pages/runners/[slug].astro`, find the `<PageHeader` block (around line 46) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={currentClubName}
    title={title}
    titleAccent="Runner Profile"
    subtitleParts={[sexLabel, runner.ageCategory]}
  />
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/pages/runners/[slug].astro
git commit -m "feat: add Runner Profile accent to runner profile header"
```

---

### Task 8: Update road-gp/[year]/[raceId].astro — add year accent

**Files:**
- Modify: `src/pages/road-gp/[year]/[raceId].astro:56-61`

`title` is the race name, `year` is available as a prop. The eyebrow already contains "Road Grand Prix · Race X of Y" so the accent shows the year without repeating the series name.

- [ ] **Step 1: Add `titleAccent` to the PageHeader call**

In `src/pages/road-gp/[year]/[raceId].astro`, find the `<PageHeader` block (around line 56) and add `titleAccent`:

```astro
  <PageHeader
    slot="hero"
    eyebrow={`Road Grand Prix · Race ${raceIndex} of ${totalRaces}`}
    title={name}
    titleAccent={String(year)}
    subtitleParts={raceMeta}
  />
```

- [ ] **Step 2: Build to confirm no TypeScript errors**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/[year]/[raceId].astro
git commit -m "feat: add year accent to race detail header"
```

---

### Task 9: Visual verification

**Files:** None modified — verification only.

- [ ] **Step 1: Start the dev server**

```bash
npm run dev
```

Open `http://localhost:4321` in a browser.

- [ ] **Step 2: Check the series index page**

Navigate to `/road-gp/`. Confirm:
- Title shows "Road Grand Prix" (white, large) with "2026" in amber below
- Eyebrow "2026 Season" still shows small above
- Actions (year picker) aligns to the top of the title block

- [ ] **Step 3: Check an individual results page**

Navigate to a race results page (e.g. `/road-gp/2026/<race-id>/results`). Confirm:
- Title shows race name (white) with "Individual Results" in amber below
- Individual/Team tab strip still renders below the header band

- [ ] **Step 4: Check a team results page**

Navigate to a team results page. Confirm title shows race name / "Team Results".

- [ ] **Step 5: Check standings pages**

Navigate to `/road-gp/2026/individual-standings` and `/road-gp/2026/team-standings`. Confirm:
- Individual Standings / "Road Grand Prix 2026"
- Team Standings / "Road Grand Prix 2026"
- Provisional badge (if applicable) appears below the accent line, not inline

- [ ] **Step 6: Check a runner profile**

Navigate to `/runners/<slug>`. Confirm title shows runner name / "Runner Profile".

- [ ] **Step 7: Check race detail page**

Navigate to `/road-gp/2026/<race-id>`. Confirm title shows race name / "2026".

- [ ] **Step 8: Check Fell pages**

Navigate to `/fell/`. Fell uses the same layout components — confirm the accent appears correctly on fell series pages too (seriesLabel will be "Fell Championship").
