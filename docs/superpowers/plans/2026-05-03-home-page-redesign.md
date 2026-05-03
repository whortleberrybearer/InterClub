# Home Page Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bland two-card home page with an action-oriented layout showing a Road GP hero card (next race or recent results) and full race schedule tables for both series.

**Architecture:** All changes are contained in a single file — `src/pages/index.astro`. The page uses existing data utilities (`getRaces`, `hasResults`, `hasTeamStandings`, `hasIndividualStandings`) and renders everything inline without new components. The hero card logic runs at build time using the build date.

**Tech Stack:** Astro v6, Tailwind CSS v4, DaisyUI v5. TypeScript in `.astro` frontmatter; no unit tests apply (validated by build only per project conventions).

---

### Task 1: Rewrite `src/pages/index.astro`

**Files:**
- Modify: `src/pages/index.astro`

- [ ] **Step 1: Replace `src/pages/index.astro` with the new implementation**

```astro
---
// src/pages/index.astro
import Layout from '../components/Layout.astro';
import { getCurrentYear, getRaces } from '../lib/data';
import { hasResults, hasTeamStandings, hasIndividualStandings } from '../lib/results';
import { formatRaceDate } from '../lib/format';
import type { Race } from '../lib/types';

const currentYear = getCurrentYear();
const roadRaces = getRaces(currentYear, 'road-gp');
const fellRaces = getRaces(currentYear, 'fell');

// Parse an ISO date string as a local midnight Date (avoids timezone shifts)
function toLocalDate(dateStr: string): Date {
  const [y, m, d] = dateStr.split('-').map(Number);
  return new Date(y, m - 1, d);
}

const today = new Date();
today.setHours(0, 0, 0, 0);

const sevenDaysAgo = new Date(today);
sevenDaysAgo.setDate(today.getDate() - 7);

// Identify hero race: most recent Road GP race with results within 7 days,
// otherwise the next upcoming Road GP race.
const recentRace = roadRaces
  .filter(r => {
    const d = toLocalDate(r.date);
    return d >= sevenDaysAgo && d < today && hasResults(currentYear, 'road-gp', r.id);
  })
  .at(-1) ?? null;

const nextRoadRace = roadRaces.find(r => toLocalDate(r.date) >= today) ?? null;
const heroRace: Race | null = recentRace ?? nextRoadRace;
const heroMode: 'recent' | 'next' | null = recentRace ? 'recent' : nextRoadRace ? 'next' : null;

const heroIndex = heroRace ? roadRaces.indexOf(heroRace) + 1 : null;
const heroLabel = heroMode === 'recent'
  ? `Recent Results · Race ${heroIndex} of ${roadRaces.length}`
  : `Next Race · Race ${heroIndex} of ${roadRaces.length}`;

// Standings links: prefer individual standings, fall back to team standings
function getStandingsUrl(series: 'road-gp' | 'fell'): string | undefined {
  if (hasIndividualStandings(currentYear, series))
    return `/${series}/${currentYear}/individual-standings`;
  if (hasTeamStandings(currentYear, series))
    return `/${series}/${currentYear}/team-standings`;
  return undefined;
}

const roadStandingsUrl = getStandingsUrl('road-gp');
const fellStandingsUrl = getStandingsUrl('fell');

// Race row state helpers
function isPast(race: Race): boolean {
  return toLocalDate(race.date) < today;
}
function isNext(races: Race[], race: Race): boolean {
  return races.find(r => toLocalDate(r.date) >= today)?.id === race.id;
}
---

<Layout title="Home">
  <!-- ── Road Grand Prix ──────────────────────────────── -->
  <div class="mb-10">
    <div class="flex items-center justify-between mb-4">
      <h2 class="text-xl font-bold">Road Grand Prix</h2>
      {roadStandingsUrl && (
        <a href={roadStandingsUrl} class="text-sm text-primary hover:underline">Standings →</a>
      )}
    </div>

    {heroRace && heroMode && (
      <div class={`card shadow mb-4 ${heroMode === 'recent' ? 'bg-success text-success-content' : 'bg-primary text-primary-content'}`}>
        <div class="card-body flex-row items-center justify-between flex-wrap gap-4 py-4">
          <div>
            <div class="text-xs uppercase tracking-wide opacity-70 mb-1">{heroLabel}</div>
            <h3 class="text-lg font-bold">{heroRace.name}</h3>
            <p class="opacity-80 text-sm mt-0.5">
              {formatRaceDate(heroRace.date, heroMode === 'recent' ? undefined : heroRace.time)}
              {heroRace.location && ` · ${heroRace.location}`}
            </p>
          </div>
          {heroMode === 'recent' ? (
            <a href={`/road-gp/${currentYear}/${heroRace.id}/results`} class={`btn btn-sm border-0 shrink-0 bg-white text-success hover:bg-base-200`}>
              View results →
            </a>
          ) : (
            <a href={`/road-gp/${currentYear}/${heroRace.id}`} class={`btn btn-sm border-0 shrink-0 bg-white text-primary hover:bg-base-200`}>
              Race info →
            </a>
          )}
        </div>
      </div>
    )}

    <div class="overflow-x-auto">
      <table class="table table-sm bg-base-100 rounded-box shadow-sm w-full">
        <tbody>
          {roadRaces.map(race => {
            const past = isPast(race);
            const next = isNext(roadRaces, race);
            return (
              <tr class:list={[{ 'opacity-40': past, 'bg-primary/5': next }]}>
                <td class:list={['text-sm w-28', { 'text-base-content/70': past }]}>
                  {formatRaceDate(race.date)}
                </td>
                <td class:list={['text-sm', { 'font-bold': next }]}>
                  {race.name}
                  {next && <span class="badge badge-primary badge-xs ml-2">Next</span>}
                </td>
                <td class="text-right">
                  {past && hasResults(currentYear, 'road-gp', race.id) && (
                    <a href={`/road-gp/${currentYear}/${race.id}/results`} class="link link-primary text-sm">Results</a>
                  )}
                  {next && (
                    <a href={`/road-gp/${currentYear}/${race.id}`} class="link link-primary text-sm">Info</a>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  </div>

  <!-- ── Fell Championship ────────────────────────────── -->
  <div>
    <div class="flex items-center justify-between mb-4">
      <h2 class="text-xl font-bold">Fell Championship</h2>
      {fellStandingsUrl && (
        <a href={fellStandingsUrl} class="text-sm text-primary hover:underline">Standings →</a>
      )}
    </div>

    <div class="overflow-x-auto">
      <table class="table table-sm bg-base-100 rounded-box shadow-sm w-full">
        <tbody>
          {fellRaces.map(race => {
            const past = isPast(race);
            const next = isNext(fellRaces, race);
            return (
              <tr class:list={[{ 'opacity-40': past, 'bg-primary/5': next }]}>
                <td class:list={['text-sm w-28', { 'text-base-content/70': past }]}>
                  {formatRaceDate(race.date)}
                </td>
                <td class:list={['text-sm', { 'font-bold': next }]}>
                  {race.name}
                  {next && <span class="badge badge-primary badge-xs ml-2">Next</span>}
                </td>
                <td class="text-right">
                  {past && hasResults(currentYear, 'fell', race.id) && (
                    <a href={`/fell/${currentYear}/${race.id}/results`} class="link link-primary text-sm">Results</a>
                  )}
                  {next && (
                    <a href={`/fell/${currentYear}/${race.id}`} class="link link-primary text-sm">Info</a>
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  </div>
</Layout>
```

- [ ] **Step 2: Run build to verify no TypeScript errors**

```bash
npm run build
```

Expected: Build completes with no errors. The `/index.html` page is listed in the output.

- [ ] **Step 3: Check the home page renders correctly**

Open `http://localhost:4321` (dev server) or inspect the built `dist/index.html`.

Verify:
- Road GP section heading with optional Standings link
- Hero card shown (primary/blue for "Next Race" since today is 2026-05-03 and next race is Lytham 2026-05-05; OR success/green if Blackpool results published and within 7 days)
- All 7 Road GP races listed; Blackpool row dimmed; Lytham row highlighted with "Next" badge
- All 4 Fell Championship races listed; Pendle row dimmed; Mearly Clough highlighted with "Next" badge
- No intro paragraph, no series overview cards

- [ ] **Step 4: Commit**

```bash
git add src/pages/index.astro
git commit -m "feat: redesign home page with race schedule and hero card"
```
