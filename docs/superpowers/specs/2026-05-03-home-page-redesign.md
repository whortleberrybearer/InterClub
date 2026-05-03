# Home Page Redesign

**Date:** 2026-05-03

## Goal

Replace the current bland home page (series overview cards + vague intro text) with an action-oriented page that surfaces upcoming races and recent results without requiring the user to navigate into a series first.

## Layout

The page has no page-level introduction text. It consists of two stacked sections: Road Grand Prix followed by Fell Championship.

### Road Grand Prix Section

**Heading row:** "Road Grand Prix" on the left; "Standings →" link on the right (only rendered if a team-standings or individual-standings file exists for the current year's Road GP).

**Hero card:** Displayed directly below the heading. Shows one Road GP race — either the most recent completed race (within 7 days) or the next upcoming race. See Hero Logic below.

**Race table:** Below the hero. Lists all Road GP races for the current year.

### Fell Championship Section

**Heading row:** "Fell Championship" on the left; "Standings →" link on the right (same conditional as Road GP).

**Race table:** Lists all Fell Championship races for the current year. No hero card.

---

## Race Table

Each series table has three columns:

| Date | Race name | Link |
|------|-----------|------|

- **Past races:** Rendered at reduced opacity (dimmed). The link column shows "Results" if a results file exists for that race, otherwise empty.
- **Next race row:** Highlighted with a subtle tinted background. Race name includes a small "Next" badge. The link column shows "Info" linking to the series race detail page (when it exists).
- **Future races (beyond next):** Normal text, no link.

Races are ordered chronologically (earliest first, matching `races.json` order).

---

## Hero Card Logic

The hero card appears inside the Road Grand Prix section only.

**Condition — show Recent Results card:**
A Road GP race has a results file (final or provisional) AND the race date is within the past 7 calendar days (inclusive of race day, exclusive of 8+ days ago).

- Card colour: success (green)
- Label: "Recent Results · Race N of {total}" (e.g. "Race 1 of 7")
- Content: race name, formatted date, location
- Button: "View results →" linking to the race results page

**Condition — show Next Race card:**
No recent race qualifies above, AND at least one Road GP race has not yet taken place.

- Card colour: primary (blue)
- Label: "Next Race · Race N of {total}" (e.g. "Race 2 of 7")
- Content: race name, formatted date + time, location
- Button: "Race info →" linking to the series race detail page (when it exists; button omitted if no detail page)

**Condition — no hero:**
All Road GP races are in the past and none falls within 7 days. Hero is hidden. The race table still renders.

The "Race N of 7" label uses the race's 1-based index in `races.json` and the total count of races.

---

## Standings Link

The "Standings →" link in each section heading links to `/{series}/{year}/individual-standings/` if an `individual-standings.json` exists, otherwise to `/{series}/{year}/team-standings/` if a `team-standings.json` exists, otherwise the link is omitted entirely.

---

## Removed

- The intro paragraph: "Lancashire's annual running competition between seven clubs, contested across two series."
- The two series overview cards (Road GP card and Fell Championship card).

---

## Data Dependencies

All data already available via existing `getRaces()` and file-existence checks used elsewhere in the codebase. No new data files or schema changes required.

The 7-day recency check compares the race date against today's date at build time (static site — the page reflects the date of the last build). This is acceptable for a low-traffic competition site that is rebuilt when results are published.
