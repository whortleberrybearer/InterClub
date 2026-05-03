# Series Info Pages Design

**Date:** 2026-05-03
**Scope:** Add informational content to the Road Grand Prix and Fell Championship landing pages.

## Problem

Both `/road-gp/` and `/fell/` index pages currently render nothing but a race list. There is no series description, no rules, and no context — the pages are blank to newcomers and uninformative to club runners checking eligibility or scoring rules.

## Approach

Add a static content block directly inline in each `index.astro` page, above the existing `<RaceList>` component. No new components are needed — the content is substantively different between the two series and changes rarely enough that inline HTML is simpler and easier to maintain independently.

## Content Structure

Both pages follow the same five-section structure:

1. **Intro paragraph** — brief description of the series
2. **Key Rules** — bullet list of participation rules with consequences where applicable
3. **Team Categories** — table of category names and scorer counts
4. **Team Scoring** — fixed points rules and incomplete-team rules
5. **Individual Awards** — how individual awards are determined, with the one-award-per-athlete note

---

## Road Grand Prix (`src/pages/road-gp/index.astro`)

### Intro

Seven Lancashire clubs compete across free 4–5 mile road races held midweek from April to September. Individual standings are based on your best 4 of 7 races.

### Key Rules

- No headphones or similar devices are permitted in IC Road races
- Minimum age is 15 on the day of competition
- Club members only — no guest runners
- Club vest or top must be worn; athletes not in club kit may be removed from official results
- Race number must be worn; athletes without a number will be shown as Non-Counter in the results

### Team Categories

| Category | Scorers |
|----------|---------|
| Open     | 10      |
| Ladies   | 5       |
| FV40     | 5       |
| Vets     | 6       |
| Vet 50s  | 4       |
| Vet 60s  | 3       |

### Team Scoring

- 1st team 7 points, 2nd team 6 points … 7th team 1 point
- Incomplete teams still score and are ordered by number of finishing runners
- Where multiple clubs have the same number of finishers, normal scoring rules apply
- Clubs with no finishers score 0 points

### Individual Awards

Awards are presented to the top 3 finishers per individual category, based on each athlete's best 4 of 7 races. Awards are presented at the following season's buffet. Only one award per athlete.

---

## Fell Championship (`src/pages/fell/index.astro`)

### Intro

Four fell races during summer, run under FRA/BOFRA rules. Unlike the Road Grand Prix, entry fees are required for all races. Individual standings are based on your best 3 of 4 races.

### Key Rules

- These races are not free — entry fees must be paid
- Competitors are responsible for their own safety on the fells and must obey all rules set by race organisers
- Additional mandatory kit and protective clothing may be required; failure to carry required kit risks disqualification

### Team Categories

| Category | Scorers |
|----------|---------|
| Open     | 6       |
| Ladies   | 3       |
| Vets     | 4       |

### Team Scoring

Same rules as Road Grand Prix:

- 1st team 7 points, 2nd team 6 points … 7th team 1 point
- Incomplete teams still score and are ordered by number of finishing runners
- Where multiple clubs have the same number of finishers, normal scoring rules apply
- Clubs with no finishers score 0 points

### Individual Awards

Awards are presented to the top 3 finishers per individual category, based on each athlete's best 3 of 4 races. Awards are presented at the following season's buffet. Only one award per athlete.

---

## Implementation Notes

- Content is added inline in `src/pages/road-gp/index.astro` and `src/pages/fell/index.astro`
- The info block sits between the `<Layout>` opening and the `<RaceList>` component
- Styling follows existing Tailwind/DaisyUI conventions (e.g. `card bg-base-100` for the container, `text-lg font-semibold` for section headings, `list-disc` for bullet lists)
- No new components, no new data loading, no tests required
- Team categories are hardcoded; if categories change in future, update the page directly
