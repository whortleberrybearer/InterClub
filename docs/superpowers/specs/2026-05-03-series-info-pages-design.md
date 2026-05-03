# Series Info Pages Design

**Date:** 2026-05-03
**Scope:** Add informational content to the Road Grand Prix and Fell Championship landing pages.

## Problem

Both `/road-gp/` and `/fell/` index pages currently render nothing but a race list. There is no series description, no rules, and no context — the pages are blank to newcomers and uninformative to club runners checking eligibility or scoring rules.

## Approach

Add static content blocks directly inline in each `index.astro` page. The `<RaceList>` component moves to sit between the intro/rules content and the team/scoring/awards sections — so runners see the race schedule in context, before the more detailed team and award information.

No new components are needed — the content is substantively different between the two series and changes rarely enough that inline HTML is simpler and easier to maintain independently.

## Page Layout (both series)

```
<Layout>
  1. Intro / description
  2. Key Rules
  3. <RaceList> (race schedule)
  4. Team Categories
  5. Team Scoring
  6. Individual Awards
</Layout>
```

---

## Road Grand Prix (`src/pages/road-gp/index.astro`)

### 1. Intro

The Inter Club Road Grand Prix is a series of seven races of between four and five miles, held midweek from April to September. Races are free to enter and run in a spirit of fun as well as being quite competitive. Each host club provides a complimentary buffet after their event. Race numbers are assigned before the season and remain valid throughout.

### 2. Key Rules

- No headphones or similar devices are permitted in IC Road races
- Minimum age is 15 on the day of competition
- Club members only — no guest runners
- Club vest or top must be worn; athletes not in club kit may be removed from official results
- Race number must be worn; athletes without a number will be shown as Non-Counter in the results

### 3. Race List

`<RaceList>` rendered here (current position in the component).

### 4. Team Categories

| Category | Scorers | Eligibility        |
|----------|---------|--------------------|
| Open     | 10      | All finishers      |
| Ladies   | 5       | Women              |
| FV40     | 5       | Women 40+          |
| Vets     | 6       | Men 40+, Women 35+ |
| Vet 50s  | 4       | Men & Women 50+    |
| Vet 60s  | 3       | Men & Women 60+    |

### 5. Team Scoring

- 1st team 7 points, 2nd team 6 points … 7th team 1 point
- Incomplete teams still score and are ordered by number of finishing runners
- Where multiple clubs have the same number of finishers, normal scoring rules apply
- Clubs with no finishers score 0 points

### 6. Individual Awards

Individual standings are based on the lowest total positions from your best 4 of 7 races. Awards are presented to the 1st, 2nd, and 3rd place finishers overall, and to the top 2 in each veteran category. Awards are presented at the following season's buffet. Only one award per athlete.

---

## Fell Championship (`src/pages/fell/index.astro`)

### 1. Intro

The Inter Club Fell Championship is a series of four fell races held during the summer. Races run within pre-existing open events governed by FRA or BOFRA regulations, across varied fell terrain. Unlike the Road Grand Prix, races are not free — entry fees must be paid by each competitor.

### 2. Key Rules

- Entry fees must be paid — these are not free races
- Competitors are responsible for their own safety on the fells and must obey all rules set by race organisers
- Additional mandatory kit and protective clothing may be required; failure to carry required kit risks disqualification

### 3. Race List

`<RaceList>` rendered here (current position in the component).

### 4. Team Categories

| Category | Scorers | Eligibility     |
|----------|---------|-----------------|
| Open     | 6       | All finishers   |
| Ladies   | 3       | Women           |
| Vets     | 4       | Men & Women 40+ |

### 5. Team Scoring

- 1st team 7 points, 2nd team 6 points … 7th team 1 point
- Incomplete teams still score and are ordered by number of finishing runners
- Where multiple clubs have the same number of finishers, normal scoring rules apply
- Clubs with no finishers score 0 points

### 6. Individual Awards

Individual standings are based on the lowest total positions from your best 3 of 4 races. Awards are presented to the 1st, 2nd, and 3rd place finishers overall, and to the top 2 in each veteran category. Awards are presented at the following season's buffet. Only one award per athlete.

---

## Implementation Notes

- Content is added inline in `src/pages/road-gp/index.astro` and `src/pages/fell/index.astro`
- The `<RaceList>` component moves from the bottom of the page to sit between Key Rules and Team Categories
- Styling follows existing Tailwind/DaisyUI conventions (`card bg-base-100` for grouped sections, `text-lg font-semibold` for section headings, `list-disc` for bullet lists)
- No new components, no new data loading, no tests required
- Team categories are hardcoded; if categories change in a future season, update the page directly
