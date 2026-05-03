# Series Info Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add series descriptions, key rules, team categories, team scoring rules, and individual awards information to the Road Grand Prix and Fell Championship landing pages.

**Architecture:** Static HTML content blocks are added inline in `src/pages/road-gp/index.astro` and `src/pages/fell/index.astro`. The `<RaceList>` component stays in both files but is repositioned to sit between the intro/rules sections and the team/awards sections. No new components or data loading are introduced.

**Tech Stack:** Astro v6, Tailwind CSS v4, DaisyUI v5. Verification via `npm run build` (catches Astro/TypeScript errors) and `npm run dev` for visual inspection.

---

### Task 1: Update Road Grand Prix index page

**Files:**
- Modify: `src/pages/road-gp/index.astro`

- [ ] **Step 1: Replace the file contents**

Replace `src/pages/road-gp/index.astro` with the following. The frontmatter is unchanged; the template gains a description paragraph, a Key Rules card, then the existing `<RaceList>`, then Team Categories, Team Scoring, and Individual Awards cards.

```astro
---
// src/pages/road-gp/index.astro
import Layout from '../../components/Layout.astro';
import RaceList from '../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
import { hasTeamStandings } from '../../lib/results';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears('road-gp');
const races = getRaces(currentYear, 'road-gp');
const standingsUrl = hasTeamStandings(currentYear, 'road-gp')
  ? `/road-gp/${currentYear}/team-standings`
  : undefined;
---

<Layout title="Road Grand Prix">
  <p class="mb-6 text-base-content/80">
    The Inter Club Road Grand Prix is a series of seven races of between four and five miles, held
    midweek from April to September. Races are free to enter and run in a spirit of fun as well as
    being quite competitive. Each host club provides a complimentary buffet after their event. Race
    numbers are assigned before the season and remain valid throughout.
  </p>

  <div class="card bg-base-100 shadow-sm mb-6">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Key Rules</h2>
      <ul class="list-disc list-inside space-y-1 text-sm text-base-content/80">
        <li>No headphones or similar devices are permitted in IC Road races</li>
        <li>Minimum age is 15 on the day of competition</li>
        <li>Club members only — no guest runners</li>
        <li>Club vest or top must be worn; athletes not in club kit may be removed from official results</li>
        <li>Race number must be worn; athletes without a number will be shown as Non-Counter in the results</li>
      </ul>
    </div>
  </div>

  <RaceList
    races={races}
    year={currentYear}
    series="road-gp"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/road-gp"
    seriesLabel="Road Grand Prix"
    standingsUrl={standingsUrl}
  />

  <div class="card bg-base-100 shadow-sm mt-6">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Team Categories</h2>
      <div class="overflow-x-auto">
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Category</th>
              <th>Scorers</th>
              <th>Eligibility</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Open</td><td>10</td><td>All finishers</td></tr>
            <tr><td>Ladies</td><td>5</td><td>Women</td></tr>
            <tr><td>FV40</td><td>5</td><td>Women 40+</td></tr>
            <tr><td>Vets</td><td>6</td><td>Men 40+, Women 35+</td></tr>
            <tr><td>Vet 50s</td><td>4</td><td>Men &amp; Women 50+</td></tr>
            <tr><td>Vet 60s</td><td>3</td><td>Men &amp; Women 60+</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <div class="card bg-base-100 shadow-sm mt-4">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Team Scoring</h2>
      <ul class="list-disc list-inside space-y-1 text-sm text-base-content/80">
        <li>1st team 7 points, 2nd team 6 points … 7th team 1 point</li>
        <li>Incomplete teams still score and are ordered by number of finishing runners</li>
        <li>Where multiple clubs have the same number of finishers, normal scoring rules apply</li>
        <li>Clubs with no finishers score 0 points</li>
      </ul>
    </div>
  </div>

  <div class="card bg-base-100 shadow-sm mt-4">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Individual Awards</h2>
      <p class="text-sm text-base-content/80">
        Individual standings are based on the lowest total positions from your best 4 of 7 races.
        Awards are presented to the 1st, 2nd, and 3rd place finishers overall, and to the top 2 in
        each veteran category. Awards are presented at the following season's buffet. Only one award
        per athlete.
      </p>
    </div>
  </div>
</Layout>
```

- [ ] **Step 2: Run the build to verify no errors**

```bash
npm run build
```

Expected: build completes with no errors. TypeScript errors in Astro pages only surface here, not via `npm test`.

- [ ] **Step 3: Commit**

```bash
git add src/pages/road-gp/index.astro
git commit -m "feat: add series info content to Road GP index page"
```

---

### Task 2: Update Fell Championship index page

**Files:**
- Modify: `src/pages/fell/index.astro`

- [ ] **Step 1: Replace the file contents**

Replace `src/pages/fell/index.astro` with the following. Same structure as the Road GP page with fell-specific content — two key rules, three fewer team categories, and "best 3 of 4" in the awards section.

```astro
---
// src/pages/fell/index.astro
import Layout from '../../components/Layout.astro';
import RaceList from '../../components/RaceList.astro';
import { getCurrentYear, getAvailableYears, getRaces } from '../../lib/data';
import { hasTeamStandings } from '../../lib/results';

const currentYear = getCurrentYear();
const availableYears = getAvailableYears('fell');
const races = getRaces(currentYear, 'fell');
const standingsUrl = hasTeamStandings(currentYear, 'fell')
  ? `/fell/${currentYear}/team-standings`
  : undefined;
---

<Layout title="Fell Championship">
  <p class="mb-6 text-base-content/80">
    The Inter Club Fell Championship is a series of four fell races held during the summer. Races
    run within pre-existing open events governed by FRA or BOFRA regulations, across varied fell
    terrain. Unlike the Road Grand Prix, races are not free — entry fees must be paid by each
    competitor.
  </p>

  <div class="card bg-base-100 shadow-sm mb-6">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Key Rules</h2>
      <ul class="list-disc list-inside space-y-1 text-sm text-base-content/80">
        <li>Competitors are responsible for their own safety on the fells and must obey all rules set by race organisers</li>
        <li>Additional mandatory kit and protective clothing may be required; failure to carry required kit risks disqualification</li>
      </ul>
    </div>
  </div>

  <RaceList
    races={races}
    year={currentYear}
    series="fell"
    availableYears={availableYears}
    currentYear={currentYear}
    seriesBasePath="/fell"
    seriesLabel="Fell Championship"
    standingsUrl={standingsUrl}
  />

  <div class="card bg-base-100 shadow-sm mt-6">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Team Categories</h2>
      <div class="overflow-x-auto">
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Category</th>
              <th>Scorers</th>
              <th>Eligibility</th>
            </tr>
          </thead>
          <tbody>
            <tr><td>Open</td><td>5</td><td>Any age, any sex</td></tr>
            <tr><td>Ladies</td><td>3</td><td>Women</td></tr>
            <tr><td>Vets</td><td>4</td><td>Men &amp; Women 40+</td></tr>
            <tr><td>Vet 50</td><td>3</td><td>Men &amp; Women 50+</td></tr>
            <tr><td>Vet 60</td><td>2</td><td>Men &amp; Women 60+</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <div class="card bg-base-100 shadow-sm mt-4">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Team Scoring</h2>
      <ul class="list-disc list-inside space-y-1 text-sm text-base-content/80">
        <li>1st team 7 points, 2nd team 6 points … 7th team 1 point</li>
        <li>Incomplete teams still score and are ordered by number of finishing runners</li>
        <li>Where multiple clubs have the same number of finishers, normal scoring rules apply</li>
        <li>Clubs with no finishers score 0 points</li>
      </ul>
    </div>
  </div>

  <div class="card bg-base-100 shadow-sm mt-4">
    <div class="card-body gap-2 py-4">
      <h2 class="text-lg font-semibold">Individual Awards</h2>
      <p class="text-sm text-base-content/80">
        Individual standings are based on the lowest total positions from your best 3 of 4 races.
        Awards are presented to the 1st, 2nd, and 3rd place finishers overall, and to the top 2 in
        each veteran category. Awards are presented at the following season's buffet. Only one award
        per athlete.
      </p>
    </div>
  </div>
</Layout>
```

- [ ] **Step 2: Run the build to verify no errors**

```bash
npm run build
```

Expected: build completes with no errors.

- [ ] **Step 3: Commit**

```bash
git add src/pages/fell/index.astro
git commit -m "feat: add series info content to Fell Championship index page"
```
