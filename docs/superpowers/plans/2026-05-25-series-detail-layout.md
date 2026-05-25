# Series Detail Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the plain stacked-card series index pages with a responsive, design-matched layout that includes a hero header, race schedule table with live states, 2×2 info grid, and an archive sidebar/picker.

**Architecture:** A new `SeriesDetailLayout.astro` shared component (following the existing `TeamStandingsLayout`/`IndividualResultsLayout` pattern) is consumed by both `road-gp/index.astro` and `fell/index.astro`. Minimal data-layer changes: one new helper in `results.ts` and an optional `eligibility` field on `TeamCategory`.

**Tech Stack:** Astro v6, Tailwind CSS v4 + custom tokens, TypeScript strict, Vitest (no new tests — glob-dependent helpers are validated by build per CLAUDE.md).

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `src/lib/types.ts` | Add `eligibility?: string` to `TeamCategory` |
| Modify | `src/lib/results.ts` | Add `isResultsProvisional()` — key-only check, no CSV parsing |
| Modify | `src/data/2026/road-gp/config.json` | Add `eligibility` to each team category |
| Modify | `src/data/2026/fell/config.json` | Add `eligibility` to each team category |
| **Create** | `src/components/SeriesDetailLayout.astro` | Full responsive layout component |
| Modify | `src/pages/road-gp/index.astro` | Replace current markup with `SeriesDetailLayout` usage |
| Modify | `src/pages/fell/index.astro` | Replace current markup with `SeriesDetailLayout` usage |

---

## Task 1: Extend TeamCategory type and update config files

**Files:**
- Modify: `src/lib/types.ts`
- Modify: `src/data/2026/road-gp/config.json`
- Modify: `src/data/2026/fell/config.json`

- [ ] **Step 1: Add `eligibility` to TeamCategory in `src/lib/types.ts`**

Find the `TeamCategory` interface (around line 126) and add the optional field:

```ts
export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
  eligibility?: string;   // e.g. "All finishers", "Women", "Men & Women 40+"
}
```

- [ ] **Step 2: Update `src/data/2026/road-gp/config.json`**

Replace the entire file with:

```json
{
  "ageCategories": ["U17", "U20", "U23", "SEN", "V35", "V40", "V45", "V50", "V55", "V60", "V65", "V70", "V75", "V80"],
  "teamCategories": [
    { "id": "open",   "name": "Open",    "scorerCount": 10, "eligibility": "All finishers" },
    { "id": "ladies", "name": "Ladies",  "scorerCount": 5,  "eligibility": "Women" },
    { "id": "fv40",   "name": "FV40",    "scorerCount": 5,  "eligibility": "Women 40+" },
    { "id": "vets",   "name": "Vets",    "scorerCount": 6,  "eligibility": "Men 40+, Women 35+" },
    { "id": "vet50s", "name": "Vet 50s", "scorerCount": 4,  "eligibility": "Men & Women 50+" },
    { "id": "vet60s", "name": "Vet 60s", "scorerCount": 3,  "eligibility": "Men & Women 60+" }
  ]
}
```

- [ ] **Step 3: Update `src/data/2026/fell/config.json`**

Replace the entire file with:

```json
{
  "ageCategories": ["SEN", "V40", "V50", "V60", "V70"],
  "teamCategories": [
    { "id": "open",   "name": "Open",   "scorerCount": 6, "eligibility": "Any age, any sex" },
    { "id": "ladies", "name": "Ladies", "scorerCount": 3, "eligibility": "Women" },
    { "id": "vets",   "name": "Vets",   "scorerCount": 4, "eligibility": "Men & Women 40+" }
  ]
}
```

- [ ] **Step 4: Verify build passes with the type change**

```bash
npm run build
```

Expected: build succeeds — `eligibility` is optional so all existing code continues to work.

- [ ] **Step 5: Commit**

```bash
git add src/lib/types.ts src/data/2026/road-gp/config.json src/data/2026/fell/config.json
git commit -m "feat: add eligibility field to TeamCategory type and 2026 configs"
```

---

## Task 2: Add `isResultsProvisional` to results.ts

**Files:**
- Modify: `src/lib/results.ts`

- [ ] **Step 1: Add the helper after `hasResults` in `src/lib/results.ts`**

Find the `hasResults` function (around line 233) and insert immediately after it:

```ts
export function isResultsProvisional(year: number, series: Series, raceId: string): boolean {
  const files = csvFilesForSeries(series);
  const hasFinal = Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}.csv`) && !k.includes('-provisional')
  );
  return !hasFinal && Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}-provisional.csv`)
  );
}
```

Note: this function checks file keys only — no CSV parsing, no unit test needed (follows the same pattern as `hasResults`). Validated by build.

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add src/lib/results.ts
git commit -m "feat: add isResultsProvisional helper to results.ts"
```

---

## Task 3: Create SeriesDetailLayout component

**Files:**
- Create: `src/components/SeriesDetailLayout.astro`

This is the main component. It renders three responsive views in a single file using Tailwind responsive prefixes.

- [ ] **Step 1: Create `src/components/SeriesDetailLayout.astro`**

```astro
---
// src/components/SeriesDetailLayout.astro
import Layout from './Layout.astro';
import { hasResults, hasTeamResults, isResultsProvisional } from '../lib/results';
import { siteUrl } from '../lib/url';
import { formatRaceDate } from '../lib/format';
import type { Race, Series, SeriesConfig } from '../lib/types';

export interface Props {
  series: Series;
  year: number;
  races: Race[];
  config: SeriesConfig;
  availableYears: number[];
  seriesTitle: string;
  subtitle: string;
  teamStandingsUrl?: string;
  individualStandingsUrl?: string;
}

const {
  series, year, races, config, availableYears,
  seriesTitle, subtitle, teamStandingsUrl, individualStandingsUrl,
} = Astro.props;

// Race states — determines past/next/upcoming highlight and result links
let nextFound = false;
const raceStates = races.map(race => {
  const past = hasResults(year, series, race.id);
  const hasTeam = hasTeamResults(year, series, race.id);
  const provisional = past && isResultsProvisional(year, series, race.id);
  const isNext = !past && !nextFound;
  if (isNext) nextFound = true;
  return { race, past, hasTeam, provisional, isNext };
});

const pastCount = raceStates.filter(s => s.past).length;
const nextRaceIndex = raceStates.findIndex(s => s.isNext);
const nextRaceNumber = nextRaceIndex >= 0 ? nextRaceIndex + 1 : null;

// Archive data
const pastYears = availableYears.filter(y => y < year).sort((a, b) => b - a);
const recentYears = pastYears.slice(0, 4);
const oldestYear = pastYears[pastYears.length - 1] ?? null;

const decadeGroups = [
  { label: '2020s',   years: pastYears.filter(y => y >= 2020) },
  { label: '2010s',   years: pastYears.filter(y => y >= 2010 && y < 2020) },
  { label: '2000s',   years: pastYears.filter(y => y >= 2000 && y < 2010) },
  { label: '1990s',   years: pastYears.filter(y => y >= 1990 && y < 2000) },
  { label: '1985–89', years: pastYears.filter(y => y < 1990) },
].filter(g => g.years.length > 0);

const teamCategories = config.teamCategories ?? [];
const hasEligibility = teamCategories.some(c => c.eligibility);

const scoringRules = [
  '1st team 7 points, 2nd team 6 points … 7th team 1 point',
  'Incomplete teams still score, ordered by finishers',
  'Tied finisher counts use normal scoring rules',
  'Clubs with no finishers score 0 points',
];
---

<Layout title={seriesTitle}>

  <!-- ════ HERO ════ -->
  <div slot="hero" class="bg-surface border-b border-line">
    <div class="max-w-4xl mx-auto px-4">

      <!-- Mobile / Tablet -->
      <div class="lg:hidden py-5 md:py-6">
        <div class="flex items-start justify-between gap-3">
          <div>
            <div class="font-head text-[10px] font-bold tracking-[0.16em] uppercase text-amber">{year} Season</div>
            <h1 class="font-head text-[28px] md:text-[36px] font-extrabold tracking-tight leading-[1.05] mt-1">{seriesTitle}</h1>
            <div class="font-mono text-[13px] text-muted mt-1">{subtitle}</div>
          </div>
          {pastYears.length > 0 && (
            <details class="relative shrink-0 mt-0.5">
              <summary class="list-none cursor-pointer flex items-center gap-1.5 border border-dashed border-line rounded-lg px-3 py-1.5 font-head text-[11px] font-bold tracking-[0.1em] uppercase text-muted hover:text-content transition-colors select-none">
                Past seasons <span class="font-mono text-[10px]">▾</span>
              </summary>
              <div class="absolute right-0 top-[calc(100%+6px)] z-10 bg-surface border border-line rounded-xl shadow-lg p-2.5 w-60 max-h-72 overflow-y-auto">
                <div class="font-head text-[10px] font-bold tracking-[0.12em] uppercase text-muted px-1.5 pb-2 border-b border-line mb-1.5">Browse archive</div>
                <div class="grid grid-cols-4 gap-1">
                  {pastYears.map(y => (
                    <a
                      href={siteUrl(`/${series}/${y}/`)}
                      class="text-center py-1.5 font-mono text-[12px] text-content bg-canvas rounded-md hover:text-amber transition-colors no-underline"
                    >
                      {String(y).slice(2)}
                    </a>
                  ))}
                </div>
              </div>
            </details>
          )}
        </div>
        {(teamStandingsUrl || individualStandingsUrl) && (
          <div class="flex gap-2 mt-3">
            {teamStandingsUrl && (
              <a href={teamStandingsUrl} class="btn btn-primary btn-sm flex-1 justify-center">Team Standings →</a>
            )}
            {individualStandingsUrl && (
              <a href={individualStandingsUrl} class="btn btn-sm flex-1 justify-center" style="color: var(--color-amber); border: 1px solid var(--color-amber);">Individual →</a>
            )}
          </div>
        )}
      </div>

      <!-- Desktop -->
      <div class="hidden lg:block py-9 pb-7">
        <div class="flex items-center gap-3 mb-2">
          <span class="font-head text-[11px] font-bold tracking-[0.16em] uppercase text-amber">{year} Season</span>
          <span class="w-6 h-px bg-line"></span>
          {nextRaceNumber && (
            <span class="font-mono text-[12px] text-muted">Round {nextRaceNumber} of {races.length} next</span>
          )}
        </div>
        <h1 class="font-head text-[52px] font-extrabold tracking-[-0.025em] leading-[0.95]">{seriesTitle}</h1>
        <div class="flex items-end justify-between mt-5 gap-8">
          <div class="text-base leading-[1.55] text-content max-w-[600px]">
            <slot name="description" />
          </div>
          {(teamStandingsUrl || individualStandingsUrl) && (
            <div class="flex gap-2.5 shrink-0">
              {teamStandingsUrl && (
                <a href={teamStandingsUrl} class="btn btn-primary">Team Standings →</a>
              )}
              {individualStandingsUrl && (
                <a href={individualStandingsUrl} class="btn" style="color: var(--color-amber); border: 1px solid var(--color-amber); padding: 0.5rem 1.375rem;">Individual →</a>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  </div>

  <!-- ════ MAIN ════ -->

  <!-- Description: mobile/tablet only (desktop gets it in hero) -->
  <div class="lg:hidden mb-6">
    <slot name="description" />
  </div>

  <!-- Two-column on desktop: main + sticky sidebar -->
  <div class="lg:grid lg:grid-cols-[1fr_220px] lg:gap-8 lg:items-start">

    <!-- ── Main column ── -->
    <div>

      <!-- Schedule -->
      <div class="card overflow-hidden">
        <div class="flex items-baseline justify-between px-4 py-3.5 border-b border-line">
          <span class="font-head text-[14px] font-bold tracking-[0.05em] uppercase">Schedule</span>
          <span class="font-mono text-[11px] text-muted">{pastCount} of {races.length} run</span>
        </div>
        <table class="table">
          <thead>
            <tr>
              <th class="hidden sm:table-cell w-10 text-center">#</th>
              <th>Date</th>
              <th>Race</th>
              <th class="hidden md:table-cell">Location</th>
              <th class="text-right pr-4">Results</th>
            </tr>
          </thead>
          <tbody>
            {raceStates.map(({ race, past, hasTeam, provisional, isNext }, i) => (
              <tr class:list={[
                'border-b border-line last:border-0',
                isNext && 'bg-amber-bg',
                past && 'opacity-70',
              ]}>
                <td class="hidden sm:table-cell py-3 px-2 text-center font-mono text-xs text-muted">{i + 1}</td>
                <td class="py-3 pl-4 sm:pl-2 pr-2">
                  <div class="font-mono text-[13px]">{formatRaceDate(race.date)}</div>
                  {race.time && <div class="font-mono text-[11px] text-muted">{race.time}</div>}
                </td>
                <td class="py-3 px-2">
                  <div class:list={['text-[14px]', isNext ? 'font-semibold' : 'font-medium']}>{race.name}</div>
                  {isNext && (
                    <span class="badge badge-warning mt-1 text-[9px]">Next</span>
                  )}
                  {provisional && (
                    <span class="badge badge-warning mt-1 ml-1 text-[9px]">Provisional</span>
                  )}
                </td>
                <td class="hidden md:table-cell py-3 px-2 text-[13px] text-muted">{race.location ?? ''}</td>
                <td class="py-3 pr-4 pl-2 text-right">
                  {past ? (
                    <div class="flex flex-col gap-1 items-end sm:flex-row sm:justify-end sm:gap-3">
                      <a href={siteUrl(`/${series}/${year}/${race.id}/results`)} class="text-[12px] font-semibold text-amber hover:underline no-underline">Results →</a>
                      {hasTeam && (
                        <a href={siteUrl(`/${series}/${year}/${race.id}/team-results`)} class="text-[12px] text-muted hover:underline no-underline">Team →</a>
                      )}
                    </div>
                  ) : (
                    <span class="font-mono text-[12px] text-muted/50">—</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <!-- 2×2 info cards -->
      <div class="grid md:grid-cols-2 gap-5 mt-5">

        <!-- Key Rules -->
        <div class="card p-5">
          <div class="font-head text-[13px] font-bold tracking-[0.05em] uppercase mb-3">Key Rules</div>
          <ul class="space-y-0">
            <slot name="rules" />
          </ul>
        </div>

        <!-- Team Categories -->
        <div class="card overflow-hidden">
          <div class="font-head text-[13px] font-bold tracking-[0.05em] uppercase px-5 py-3.5 border-b border-line">Team Categories</div>
          <table class="table table-sm">
            <thead>
              <tr>
                <th>Category</th>
                <th class="w-16">Scorers</th>
                {hasEligibility && <th>Eligibility</th>}
              </tr>
            </thead>
            <tbody>
              {teamCategories.map(cat => (
                <tr>
                  <td class="font-medium">{cat.name}</td>
                  <td class="font-mono">{cat.scorerCount}</td>
                  {hasEligibility && <td class="text-muted text-xs">{cat.eligibility ?? ''}</td>}
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <!-- Team Scoring -->
        <div class="card p-5">
          <div class="font-head text-[13px] font-bold tracking-[0.05em] uppercase mb-3">Team Scoring</div>
          <ul class="space-y-1">
            {scoringRules.map(rule => (
              <li class="relative pl-4 text-[13px] leading-relaxed">
                <span class="absolute left-0 top-0.5 font-mono text-[11px] text-muted">›</span>
                {rule}
              </li>
            ))}
          </ul>
        </div>

        <!-- Individual Awards -->
        <div class="card p-5">
          <div class="font-head text-[13px] font-bold tracking-[0.05em] uppercase mb-3">Individual Awards</div>
          <div class="text-[13px] leading-relaxed">
            <slot name="individual-awards" />
          </div>
        </div>

      </div>
    </div>

    <!-- ── Desktop sidebar ── -->
    <aside class="hidden lg:block sticky top-6 self-start">
      <div class="card p-5">
        <div class="font-head text-[10px] font-bold tracking-[0.16em] uppercase text-muted mb-1">The Archive</div>
        <div class="font-head text-[20px] font-extrabold tracking-tight mb-2">Past seasons</div>
        <p class="text-[12px] text-muted leading-relaxed mb-4 pb-4 border-b border-line">
          Race lists, results and standings for every season{oldestYear ? ` since ${oldestYear}` : ''}. Selecting a year opens its own archive page.
        </p>
        {decadeGroups.map((group, gi) => (
          <div class:list={[gi < decadeGroups.length - 1 && 'mb-4']}>
            <div class="font-mono text-[10px] tracking-[0.1em] uppercase text-muted mb-1.5">{group.label}</div>
            <div class="grid grid-cols-4 gap-1">
              {group.years.map(y => (
                <a
                  href={siteUrl(`/${series}/${y}/`)}
                  class="text-center py-1.5 font-mono text-[11px] text-content bg-canvas rounded-md hover:text-amber transition-colors no-underline"
                >
                  {String(y).slice(2)}
                </a>
              ))}
            </div>
          </div>
        ))}
      </div>
      {oldestYear && (
        <div class="mt-3.5 p-3.5 bg-canvas border border-dashed border-line rounded-xl text-[12px] text-muted leading-relaxed">
          <strong class="text-content">Series founded {oldestYear}.</strong> {pastYears.length} seasons of results.
        </div>
      )}
    </aside>

  </div>

  <!-- Recent seasons: mobile/tablet only -->
  {recentYears.length > 0 && (
    <div class="lg:hidden mt-8 pt-6 border-t border-line">
      <div class="font-head text-[10px] font-bold tracking-[0.16em] uppercase text-muted mb-3">Recent seasons</div>
      <div class="grid grid-cols-4 gap-2">
        {recentYears.map((y, i) => (
          <a
            href={siteUrl(`/${series}/${y}/`)}
            class="card p-3 no-underline flex flex-col justify-between min-h-[72px] hover:border-amber transition-colors"
          >
            <div class="font-head text-[20px] font-extrabold tracking-tight leading-none">{y}</div>
            <div class="font-mono text-[10px] text-muted mt-2">
              {i === 0 ? 'Last season' : `${recentYears[0] - y} yr ago`}
            </div>
          </a>
        ))}
      </div>
    </div>
  )}

</Layout>
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: build succeeds. If you see TypeScript errors about `isResultsProvisional` not being exported, check Task 2 was completed.

- [ ] **Step 3: Commit**

```bash
git add src/components/SeriesDetailLayout.astro
git commit -m "feat: add SeriesDetailLayout shared component"
```

---

## Task 4: Update road-gp/index.astro

**Files:**
- Modify: `src/pages/road-gp/index.astro`

- [ ] **Step 1: Replace `src/pages/road-gp/index.astro` entirely**

```astro
---
// src/pages/road-gp/index.astro
import SeriesDetailLayout from '../../components/SeriesDetailLayout.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
import { hasTeamStandings, hasIndividualStandings, getSeriesConfig } from '../../lib/results';
import { siteUrl } from '../../lib/url';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears('road-gp');
const races = getRaces(currentYear, 'road-gp');
const config = getSeriesConfig(currentYear, 'road-gp');
const teamStandingsUrl = hasTeamStandings(currentYear, 'road-gp')
  ? siteUrl(`/road-gp/${currentYear}/team-standings`)
  : undefined;
const individualStandingsUrl = hasIndividualStandings(currentYear, 'road-gp')
  ? siteUrl(`/road-gp/${currentYear}/individual-standings`)
  : undefined;
---

<SeriesDetailLayout
  series="road-gp"
  year={currentYear}
  races={races}
  config={config}
  availableYears={availableYears}
  seriesTitle="Road Grand Prix"
  subtitle="7 races · April – September · Lancashire"
  teamStandingsUrl={teamStandingsUrl}
  individualStandingsUrl={individualStandingsUrl}
>
  <Fragment slot="description">
    <p>
      A series of seven road races of between four and five miles, held midweek from April to September.
      Each host club provides a complimentary buffet after their event. Race numbers are assigned before the season
      and remain valid throughout.
    </p>
    <div class="mt-3 bg-canvas border border-line rounded-xl px-3 py-2.5 text-[13px] text-muted italic">
      Renamed <strong class="text-content not-italic">The David Wood Inter Club Series</strong> in 2020 in his memory.
    </div>
  </Fragment>

  <Fragment slot="rules">
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      No headphones or similar devices are permitted in IC Road races
    </li>
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Minimum age is 15 on the day of competition
    </li>
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Club members only — no guest runners
    </li>
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Club vest or top must be worn; athletes not in kit may be removed from official results
    </li>
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Race number must be worn; athletes without a number will be shown as Non-Counter
    </li>
  </Fragment>

  <Fragment slot="individual-awards">
    Individual standings are based on the lowest total positions from your <strong>best 4 of 7</strong> races.
    Awards go to 1st, 2nd and 3rd overall, plus the top 2 in each veteran category.
    Awards are presented at the following season's buffet. One award per athlete.
  </Fragment>
</SeriesDetailLayout>
```

- [ ] **Step 2: Verify build passes**

```bash
npm run build
```

Expected: build succeeds. The Road GP index page is now served by `SeriesDetailLayout`.

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/index.astro
git commit -m "feat: migrate road-gp index to SeriesDetailLayout"
```

---

## Task 5: Update fell/index.astro

**Files:**
- Modify: `src/pages/fell/index.astro`

- [ ] **Step 1: Replace `src/pages/fell/index.astro` entirely**

```astro
---
// src/pages/fell/index.astro
import SeriesDetailLayout from '../../components/SeriesDetailLayout.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
import { hasTeamStandings, hasIndividualStandings, getSeriesConfig } from '../../lib/results';
import { siteUrl } from '../../lib/url';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears('fell');
const races = getRaces(currentYear, 'fell');
const config = getSeriesConfig(currentYear, 'fell');
const teamStandingsUrl = hasTeamStandings(currentYear, 'fell')
  ? siteUrl(`/fell/${currentYear}/team-standings`)
  : undefined;
const individualStandingsUrl = hasIndividualStandings(currentYear, 'fell')
  ? siteUrl(`/fell/${currentYear}/individual-standings`)
  : undefined;
---

<SeriesDetailLayout
  series="fell"
  year={currentYear}
  races={races}
  config={config}
  availableYears={availableYears}
  seriesTitle="Fell Championship"
  subtitle="4 races · March – September · Lancashire"
  teamStandingsUrl={teamStandingsUrl}
  individualStandingsUrl={individualStandingsUrl}
>
  <Fragment slot="description">
    <p>
      Four fell races held during the summer, run within pre-existing open events governed by FRA or BOFRA regulations,
      across varied fell terrain. Unlike the Road Grand Prix, races are not free — entry fees must be paid by each competitor.
    </p>
  </Fragment>

  <Fragment slot="rules">
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Competitors are responsible for their own safety on the fells and must obey all rules set by race organisers
    </li>
    <li class="relative pl-5 py-1.5 text-[13px] leading-snug border-b border-line last:border-0">
      <span class="absolute left-0 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-amber"></span>
      Additional mandatory kit and protective clothing may be required; failure to carry required kit risks disqualification
    </li>
  </Fragment>

  <Fragment slot="individual-awards">
    Individual standings are based on the lowest total positions from your <strong>best 3 of 4</strong> races.
    Awards go to 1st, 2nd and 3rd overall, plus the top 2 in each veteran category.
    Awards are presented at the following season's buffet. One award per athlete.
  </Fragment>
</SeriesDetailLayout>
```

- [ ] **Step 2: Verify final build**

```bash
npm run build
```

Expected: build succeeds with no warnings or errors.

- [ ] **Step 3: Run unit tests to confirm no regressions**

```bash
npm test
```

Expected: all tests pass (no new tests were added; existing pure-function tests still pass).

- [ ] **Step 4: Commit**

```bash
git add src/pages/fell/index.astro
git commit -m "feat: migrate fell index to SeriesDetailLayout"
```

---

## Self-Review Checklist

**Spec coverage:**
- ✅ Hero section (mobile/tablet + desktop) — Task 3 component
- ✅ Archive picker popover (mobile/tablet `<details>`) — Task 3
- ✅ Standings buttons — Task 3 (conditional on URL props)
- ✅ Schedule table with past/next/upcoming states — Task 3
- ✅ `isResultsProvisional` for Provisional badge — Task 2 + Task 3
- ✅ 2×2 info card grid (rules, categories, scoring, awards) — Task 3
- ✅ Team Categories from `config.teamCategories` with `eligibility` — Task 1 + Task 3
- ✅ `eligibility` field on `TeamCategory` — Task 1
- ✅ Desktop sticky archive sidebar with decade groups — Task 3
- ✅ Recent seasons strip (mobile/tablet only) — Task 3
- ✅ Road GP page using the new layout — Task 4
- ✅ Fell page using the new layout — Task 5
- ✅ Tailwind token mapping (amber/surface/canvas/line/muted) — Task 3

**No placeholders:** All steps contain complete, runnable code.

**Type consistency:** `TeamCategory.eligibility?: string` defined in Task 1, read as `cat.eligibility` in Task 3. `isResultsProvisional` defined in Task 2, imported and used in Task 3. `SeriesDetailLayout.Props` defined once in Task 3, consumed in Tasks 4 and 5.
