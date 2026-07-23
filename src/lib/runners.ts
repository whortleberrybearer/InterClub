import type {
  Club, GlobalRunner, RunnerClubHistory, RunnerAwardSummary, RunnerAwardSummaryEntry,
  RunnerProfileAward, RunnerProfileRace,
  RunnerYearBlock, RunnerYearSeries, Series, SeriesAwards, SeriesRunner,
} from './types';
import { parseResultsCsv, hasResults, resolveIndividualCategoryName } from './results';
import { getRaces } from './data';
import { siteUrl } from './url';

// All import.meta.glob calls MUST be at module level (Vite constraint)
const globalRunnerFile = import.meta.glob<{ default: GlobalRunner[] }>(
  '../data/runners.json', { eager: true }
);
const roadSeriesRunnerFiles = import.meta.glob<{ default: SeriesRunner[] }>(
  '../data/*/road-gp/runners.json', { eager: true }
);
const fellSeriesRunnerFiles = import.meta.glob<{ default: SeriesRunner[] }>(
  '../data/*/fell/runners.json', { eager: true }
);
const roadCsvFiles = import.meta.glob<string>(
  '../data/*/road-gp/results/*.csv', { query: '?raw', import: 'default', eager: true }
);
const fellCsvFiles = import.meta.glob<string>(
  '../data/*/fell/results/*.csv', { query: '?raw', import: 'default', eager: true }
);
const roadAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/road-gp/awards.json', { eager: true }
);
const fellAwardsFiles = import.meta.glob<{ default: SeriesAwards }>(
  '../data/*/fell/awards.json', { eager: true }
);
const allClubFiles = import.meta.glob<{ default: Club[] }>(
  '../data/*/clubs.json', { eager: true }
);

export function formatYearRanges(years: number[]): string {
  if (years.length === 0) return '';
  const sorted = [...years].sort((a, b) => a - b);
  const ranges: string[] = [];
  let start = sorted[0];
  let end = sorted[0];
  for (let i = 1; i < sorted.length; i++) {
    if (sorted[i] === end + 1) {
      end = sorted[i];
    } else {
      ranges.push(start === end ? `${start}` : `${start}–${end}`);
      start = sorted[i];
      end = sorted[i];
    }
  }
  ranges.push(start === end ? `${start}` : `${start}–${end}`);
  return ranges.join(', ');
}

export function runnerSlug(runner: GlobalRunner): string {
  const name = `${runner.firstName} ${runner.lastName}`
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  return `${runner.id}-${name}`;
}

export function parseSeriesRunnerPath(path: string): { year: number; series: Series } | null {
  const match = path.match(/\/data\/(\d+)\/(road-gp|fell)\/runners\.json$/);
  if (!match) return null;
  return { year: parseInt(match[1], 10), series: match[2] as Series };
}

export function getGlobalRunners(): GlobalRunner[] {
  return globalRunnerFile['../data/runners.json']?.default ?? [];
}

export function getSeriesRunners(year: number, series: Series): SeriesRunner[] {
  const files = series === 'road-gp' ? roadSeriesRunnerFiles : fellSeriesRunnerFiles;
  return files[`../data/${year}/${series}/runners.json`]?.default ?? [];
}

/** Maps series-local runner ID → profile URL for a given year/series. */
export function buildRunnerUrlMap(year: number, series: Series): Record<number, string> {
  const seriesRunners = getSeriesRunners(year, series);
  const globalById = Object.fromEntries(getGlobalRunners().map(r => [r.id, r]));
  const map: Record<number, string> = {};
  for (const sr of seriesRunners) {
    const global = globalById[sr.runnerId];
    if (global) map[sr.id] = siteUrl(`/runners/${runnerSlug(global)}/`);
  }
  return map;
}

// --- Profile page data aggregation ---

function parseCsvPath(path: string, series: Series, year: number): { raceId: string; provisional: boolean } | null {
  const seg = series === 'road-gp' ? 'road-gp' : 'fell';
  const re = new RegExp(`/data/${year}/${seg}/results/(.+?)(-provisional)?\\.csv$`);
  const match = path.match(re);
  if (!match) return null;
  return { raceId: match[1], provisional: !!match[2] };
}

function getRacesForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileRace[] {
  const csvFiles = series === 'road-gp' ? roadCsvFiles : fellCsvFiles;
  const raceList = getRaces(year, series);
  const raceById = Object.fromEntries(raceList.map(r => [r.id, r]));

  // Prefer final over provisional for each raceId
  const seen = new Map<string, { path: string; provisional: boolean }>();
  for (const path of Object.keys(csvFiles)) {
    const parsed = parseCsvPath(path, series, year);
    if (!parsed) continue;
    const existing = seen.get(parsed.raceId);
    if (!existing || (!parsed.provisional && existing.provisional)) {
      seen.set(parsed.raceId, { path, provisional: parsed.provisional });
    }
  }

  const results: RunnerProfileRace[] = [];
  for (const [raceId, { path }] of seen) {
    const raceResults = parseResultsCsv(csvFiles[path]);
    const match = raceResults.find(r => r.seriesRunnerId === seriesLocalId);
    if (!match) continue;
    const race = raceById[raceId];
    if (!race) continue;
    results.push({
      date: race.date ?? '',
      raceName: race.name,
      raceId,
      time: match.time,
      hasResults: hasResults(year, series, raceId),
      distance: race.distance,
    });
  }
  return results.sort((a, b) => a.date.localeCompare(b.date));
}

function getAwardsForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileAward[] {
  const awardsFiles = series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
  const raw = awardsFiles[`../data/${year}/${series}/awards.json`]?.default;
  if (!raw) return [];
  const found: RunnerProfileAward[] = [];
  for (const ia of raw.individualAwards) {
    const entry = ia.awards.find(a => a.seriesRunnerId === seriesLocalId);
    if (entry) {
      const categoryName = resolveIndividualCategoryName(ia.id, ia.sex, ia.ageCategory, ia.name);
      found.push({ categoryName, position: entry.position });
    }
  }
  return found;
}

export function resolveClubName(clubId: string): string {
  // allClubFiles is at module level (Vite requires import.meta.glob at module scope)
  for (const clubs of Object.values(allClubFiles)) {
    const club = clubs.default.find(c => c.id === clubId);
    if (club) return club.name;
  }
  return clubId;
}

// Resolves the vest as of `year` — clubs can change vest design over time, so this
// finds the most recent clubs.json at or before `year` that has a vest for this club,
// falling back to any year's vest if none exists at or before `year`.
function resolveClubVest(clubId: string, year: number): string {
  let bestYear = -Infinity;
  let bestVest: string | undefined;
  let fallbackVest: string | undefined;

  for (const [path, clubs] of Object.entries(allClubFiles)) {
    const match = path.match(/\/(\d{4})\/clubs\.json$/);
    if (!match) continue;
    const fileYear = Number(match[1]);
    const club = clubs.default.find(c => c.id === clubId);
    if (!club?.vest) continue;

    fallbackVest ??= club.vest;
    if (fileYear <= year && fileYear > bestYear) {
      bestYear = fileYear;
      bestVest = club.vest;
    }
  }

  return bestVest ?? fallbackVest ?? 'unknown.png';
}

function buildClubHistory(entries: Array<{ year: number; club: string }>): RunnerClubHistory[] {
  // One club per year (first entry seen wins if a runner somehow has two clubs in the same year)
  const yearToClub = new Map<number, string>();
  for (const { year, club } of entries) {
    if (!yearToClub.has(year)) yearToClub.set(year, club);
  }
  const years = [...yearToClub.keys()].sort((a, b) => a - b);

  // Split into contiguous spans by club so a return to a former club after a gap
  // shows as a separate entry, making the switch visible in chronological order.
  const spans: Array<{ clubId: string; years: number[] }> = [];
  for (const year of years) {
    const clubId = yearToClub.get(year)!;
    const current = spans[spans.length - 1];
    if (current && current.clubId === clubId) {
      current.years.push(year);
    } else {
      spans.push({ clubId, years: [year] });
    }
  }

  return spans.map(({ clubId, years }) => ({
    clubId,
    clubName: resolveClubName(clubId),
    yearRanges: formatYearRanges(years),
    vest: resolveClubVest(clubId, Math.max(...years)),
  }));
}

function buildAwardSummary(yearBlocks: RunnerYearBlock[]): RunnerAwardSummary {
  const roadGpCounts = new Map<string, RunnerAwardSummaryEntry>();
  const fellCounts = new Map<string, RunnerAwardSummaryEntry>();

  function tally(map: Map<string, RunnerAwardSummaryEntry>, award: RunnerProfileAward) {
    const key = `${award.categoryName}|${award.position}`;
    const entry = map.get(key) ?? { categoryName: award.categoryName, position: award.position, count: 0 };
    entry.count++;
    map.set(key, entry);
  }

  for (const block of yearBlocks) {
    for (const award of block.roadGp?.awards ?? []) tally(roadGpCounts, award);
    for (const award of block.fell?.awards ?? []) tally(fellCounts, award);
  }

  const sortEntries = (entries: RunnerAwardSummaryEntry[]) =>
    entries.sort((a, b) => a.position !== b.position ? a.position - b.position : a.categoryName.localeCompare(b.categoryName));

  return {
    roadGp: sortEntries([...roadGpCounts.values()]),
    fell: sortEntries([...fellCounts.values()]),
  };
}

export function getRunnerProfileStaticPaths() {
  const globalRunners = getGlobalRunners();
  const allSeriesFiles = { ...roadSeriesRunnerFiles, ...fellSeriesRunnerFiles };

  // Build: globalRunnerId → [{ year, series, seriesLocalId, club }]
  const globalToSeries = new Map<number, Array<{ year: number; series: Series; seriesLocalId: number; club: string }>>();
  for (const [path, fileData] of Object.entries(allSeriesFiles)) {
    const parsed = parseSeriesRunnerPath(path);
    if (!parsed) continue;
    for (const sr of fileData.default) {
      const list = globalToSeries.get(sr.runnerId) ?? [];
      list.push({ year: parsed.year, series: parsed.series, seriesLocalId: sr.id, club: sr.club });
      globalToSeries.set(sr.runnerId, list);
    }
  }

  return globalRunners.map(runner => {
    const slug = runnerSlug(runner);
    const entries = globalToSeries.get(runner.id) ?? [];

    // Group into year blocks; merge races/awards when a runner has multiple series entries
    // (e.g. competed for two clubs in the same year/series)
    const byYear = new Map<number, RunnerYearBlock>();
    for (const { year, series, seriesLocalId } of entries) {
      const block = byYear.get(year) ?? { year };
      const existing = series === 'road-gp' ? block.roadGp : block.fell;
      const yearSeries: RunnerYearSeries = {
        races: [
          ...(existing?.races ?? []),
          ...getRacesForRunner(year, series, seriesLocalId),
        ].sort((a, b) => a.date.localeCompare(b.date)),
        awards: [
          ...(existing?.awards ?? []),
          ...getAwardsForRunner(year, series, seriesLocalId),
        ],
      };
      if (series === 'road-gp') block.roadGp = yearSeries;
      else block.fell = yearSeries;
      byYear.set(year, block);
    }

    const yearBlocks = [...byYear.values()].sort((a, b) => b.year - a.year);
    const clubHistory = buildClubHistory(entries);
    const awardSummary = buildAwardSummary(yearBlocks);

    return {
      params: { slug },
      props: { runner, clubHistory, awardSummary, yearBlocks },
    };
  });
}
