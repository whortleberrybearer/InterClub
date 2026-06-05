# PageHeader — Stacked Two-Colour Title

**Date:** 2026-06-05
**Status:** Approved

## Overview

Apply the bold editorial header style from the team winners history page (`AwardsHistoryTeams.astro`) to `PageHeader.astro` — the dark-band header used across race results, standings, and runner profile pages.

The change introduces an optional `titleAccent` prop that renders a second line below the main title in amber, matching the history page's pattern (e.g. "Team Winners" / "2024–2025"). Each layout component is updated to pass appropriate values.

## PageHeader Changes

**New prop:** `titleAccent?: string`

**Font size:** Scale up from `text-[28px] lg:text-[38px]` to `clamp(2.2rem, 5vw, 3.8rem)` with `font-black` and `leading-none`, matching the editorial weight of the history page header.

**Rendering:** When `titleAccent` is provided, render it as a `<span class="block text-amber">` immediately below the main title text, at the same font size.

The `eyebrow`, `subtitleParts`, `provisional`, tab strip slot, and actions slot are unchanged.

## Layout Component Updates

Each component that uses `PageHeader` gains a `titleAccent` value:

| Component / Page | `title` | `titleAccent` |
|---|---|---|
| `SeriesDetailLayout.astro` | series name (e.g. `"Road Grand Prix"`) | `year` (string) |
| `TeamStandingsLayout.astro` | `"Team Standings"` | series label + year (e.g. `"Road Grand Prix 2026"`) |
| `IndividualStandingsLayout.astro` | `"Individual Standings"` | series label + year |
| `IndividualResultsLayout.astro` | race name | `"Individual Results"` |
| `TeamResultsLayout.astro` | race name | `"Team Results"` |
| `runners/[slug].astro` | runner full name | `"Runner Profile"` |
| `road-gp/[year]/[raceId].astro` | race name | `"Road Grand Prix"` |

`SeriesDetailLayout` currently passes the combined `seriesTitle` (e.g. `"Road Grand Prix 2026"`) as `title`. This will be split: the layout receives `seriesLabel` and `year` separately (both are already available in the layout) so `title` becomes the series name alone and `titleAccent` becomes the year.

## Scope

- Modify: `src/components/PageHeader.astro`
- Modify: `src/components/SeriesDetailLayout.astro`
- Modify: `src/components/TeamStandingsLayout.astro`
- Modify: `src/components/IndividualStandingsLayout.astro`
- Modify: `src/components/IndividualResultsLayout.astro`
- Modify: `src/components/TeamResultsLayout.astro`
- Modify: `src/pages/runners/[slug].astro`
- Modify: `src/pages/road-gp/[year]/[raceId].astro` (race detail page — uses PageHeader directly; no fell equivalent)

## Out of Scope

- `PageHero.astro` — light editorial hero (contact page only), not changed
- `AwardsHistoryTeams.astro` — already has the editorial style inline, not changed
- `AwardsHistoryIndividuals.astro` — not changed

## Risks

- `SeriesDetailLayout` split of `seriesTitle` → `title` + `titleAccent` requires checking what `seriesTitle` contains and ensuring the prop rename doesn't break the browser `<title>` tag (which can keep the combined form).
- Some pages (e.g. runner profile) may look better with or without the accent — easy to tune after trial.
