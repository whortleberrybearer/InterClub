import type {
  Club, GlobalRunner, RunnerProfileAward, RunnerProfileRace,
  RunnerYearBlock, RunnerYearSeries, Series, SeriesAwards, SeriesRunner,
} from './types';
import { parseResultsCsv, hasResults, getSeriesConfig } from './results';
import { getRaces } from './data';

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
    if (global) map[sr.id] = `/runners/${runnerSlug(global)}/`;
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
      date: race.date,
      raceName: race.name,
      raceId,
      time: match.time,
      hasResults: hasResults(year, series, raceId),
    });
  }
  return results.sort((a, b) => a.date.localeCompare(b.date));
}

function getAwardsForRunner(year: number, series: Series, seriesLocalId: number): RunnerProfileAward[] {
  const awardsFiles = series === 'road-gp' ? roadAwardsFiles : fellAwardsFiles;
  const raw = awardsFiles[`../data/${year}/${series}/awards.json`]?.default;
  if (!raw) return [];
  const config = getSeriesConfig(year, series);
  const found: RunnerProfileAward[] = [];
  for (const ia of raw.individualAwards) {
    const entry = ia.awards.find(a => a.seriesRunnerId === seriesLocalId);
    if (entry) {
      const categoryName = config.individualCategories?.find(c => c.id === ia.category)?.name ?? ia.category;
      found.push({ categoryName, position: entry.position });
    }
  }
  return found;
}

function resolveClubName(clubId: string): string {
  // allClubFiles is at module level (Vite requires import.meta.glob at module scope)
  for (const clubs of Object.values(allClubFiles)) {
    const club = clubs.default.find(c => c.id === clubId);
    if (club) return club.name;
  }
  return clubId;
}

export function getRunnerProfileStaticPaths() {
  const globalRunners = getGlobalRunners();
  const allSeriesFiles = { ...roadSeriesRunnerFiles, ...fellSeriesRunnerFiles };

  // Build: globalRunnerId → [{ year, series, seriesLocalId }]
  const globalToSeries = new Map<number, Array<{ year: number; series: Series; seriesLocalId: number }>>();
  for (const [path, fileData] of Object.entries(allSeriesFiles)) {
    const parsed = parseSeriesRunnerPath(path);
    if (!parsed) continue;
    for (const sr of fileData.default) {
      const list = globalToSeries.get(sr.runnerId) ?? [];
      list.push({ year: parsed.year, series: parsed.series, seriesLocalId: sr.id });
      globalToSeries.set(sr.runnerId, list);
    }
  }

  return globalRunners.map(runner => {
    const slug = runnerSlug(runner);
    const entries = globalToSeries.get(runner.id) ?? [];

    // Group into year blocks
    const byYear = new Map<number, RunnerYearBlock>();
    for (const { year, series, seriesLocalId } of entries) {
      const block = byYear.get(year) ?? { year };
      const yearSeries: RunnerYearSeries = {
        races: getRacesForRunner(year, series, seriesLocalId),
        awards: getAwardsForRunner(year, series, seriesLocalId),
      };
      if (series === 'road-gp') block.roadGp = yearSeries;
      else block.fell = yearSeries;
      byYear.set(year, block);
    }

    const yearBlocks = [...byYear.values()].sort((a, b) => b.year - a.year);
    const clubName = resolveClubName(runner.club);

    return {
      params: { slug },
      props: { runner, clubName, yearBlocks },
    };
  });
}
