import type { Club, RaceResult, Series, SeriesConfig, TeamResults, TeamStandings } from './types';

export function parseResultsCsv(csv: string): RaceResult[] {
  const lines = csv.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trim().split('\n');
  if (lines.length < 2) return [];

  const headers = lines[0].split(',');
  const idx = (name: string) => headers.indexOf(name);

  return lines.slice(1).filter(l => l.trim()).map(line => {
    const cols = line.split(',');
    const get = (name: string) => cols[idx(name)]?.trim() ?? '';
    const num = (name: string) => { const v = get(name); return v ? parseInt(v, 10) : null; };
    return {
      position: num('position'),
      icPosition: num('ic_position'),
      firstName: get('first_name'),
      lastName: get('last_name'),
      club: get('club'),
      category: get('category'),
      sex: get('sex'),
      time: get('time'),
    };
  });
}

const csvFiles = import.meta.glob<string>('../data/*/road-gp/results/*.csv', {
  query: '?raw', import: 'default', eager: true,
});
const fellCsvFiles = import.meta.glob<string>('../data/*/fell/results/*.csv', {
  query: '?raw', import: 'default', eager: true,
});
const clubFiles = import.meta.glob<{ default: Club[] }>('../data/*/clubs.json', { eager: true });
const roadConfigFiles = import.meta.glob<{ default: SeriesConfig }>('../data/*/road-gp/config.json', { eager: true });
const fellConfigFiles = import.meta.glob<{ default: SeriesConfig }>('../data/*/fell/config.json', { eager: true });

function csvFilesForSeries(series: Series) {
  return series === 'road-gp' ? csvFiles : fellCsvFiles;
}

const roadTeamFiles = import.meta.glob<{ default: TeamResults }>(
  '../data/*/road-gp/results/*-teams*.json', { eager: true }
);
const fellTeamFiles = import.meta.glob<{ default: TeamResults }>(
  '../data/*/fell/results/*-teams*.json', { eager: true }
);

function teamFilesForSeries(series: Series) {
  return series === 'road-gp' ? roadTeamFiles : fellTeamFiles;
}

const roadStandingsFiles = import.meta.glob<{ default: TeamStandings }>(
  '../data/*/road-gp/team-standings.json', { eager: true }
);
const fellStandingsFiles = import.meta.glob<{ default: TeamStandings }>(
  '../data/*/fell/team-standings.json', { eager: true }
);

function standingsFilesForSeries(series: Series) {
  return series === 'road-gp' ? roadStandingsFiles : fellStandingsFiles;
}

export function parseTeamResultsPath(path: string): { year: number; raceId: string; provisional: boolean } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/results\/(.+)-teams(-provisional)?\.json$/);
  if (!match) return null;
  return {
    year: parseInt(match[1], 10),
    raceId: match[2],
    provisional: !!match[3],
  };
}

export function parseTeamStandingsPath(path: string): { year: number } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/team-standings\.json$/);
  if (!match) return null;
  return { year: parseInt(match[1], 10) };
}

export function getTeamStandings(year: number, series: Series): TeamStandings | null {
  const files = standingsFilesForSeries(series);
  return files[`../data/${year}/${series}/team-standings.json`]?.default ?? null;
}

export function hasTeamStandings(year: number, series: Series): boolean {
  const files = standingsFilesForSeries(series);
  return `../data/${year}/${series}/team-standings.json` in files;
}

export function getTeamStandingsStaticPaths(series: Series) {
  const files = standingsFilesForSeries(series);
  return Object.keys(files).flatMap(path => {
    const parsed = parseTeamStandingsPath(path);
    if (!parsed) return [];
    const { year } = parsed;
    const standings = files[path].default;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    const linkedRaceIds = standings.races.filter(raceId =>
      hasTeamResults(year, series, raceId)
    );
    return [{
      params: { year: String(year) },
      props: { year, standings, clubs, config, linkedRaceIds },
    }];
  });
}

interface TeamResultsInfo {
  teamResults: TeamResults;
  provisional: boolean;
}

export function getTeamResults(year: number, series: Series, raceId: string): TeamResultsInfo | null {
  const files = teamFilesForSeries(series);
  const finalKey = Object.keys(files).find(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams.json`)
  );
  const provisionalKey = Object.keys(files).find(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams-provisional.json`)
  );
  const key = finalKey ?? provisionalKey;
  if (!key) return null;
  return {
    teamResults: files[key].default,
    provisional: !finalKey && !!provisionalKey,
  };
}

export function hasTeamResults(year: number, series: Series, raceId: string): boolean {
  const files = teamFilesForSeries(series);
  return Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}-teams.json`) ||
    k.includes(`/${year}/${series}/results/${raceId}-teams-provisional.json`)
  );
}

export function getTeamResultsStaticPaths(series: Series) {
  const files = teamFilesForSeries(series);
  const seen = new Map<string, { year: number; raceId: string; provisional: boolean }>();

  for (const path of Object.keys(files)) {
    const parsed = parseTeamResultsPath(path);
    if (!parsed) continue;
    const { year, raceId, provisional } = parsed;
    const key = `${year}/${raceId}`;
    const existing = seen.get(key);
    if (!existing || (!provisional && existing.provisional)) {
      seen.set(key, { year, raceId, provisional });
    }
  }

  return [...seen.values()].map(({ year, raceId, provisional }) => {
    const info = getTeamResults(year, series, raceId)!;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    return {
      params: { year: String(year), raceId },
      props: { year, raceId, teamResults: info.teamResults, provisional, clubs, config },
    };
  });
}

interface ResultsInfo {
  results: RaceResult[];
  provisional: boolean;
}

function parseResultsPath(path: string): { year: number; raceId: string; provisional: boolean } | null {
  const match = path.match(/\/data\/(\d+)\/[^/]+\/results\/(.+)\.csv$/);
  if (!match) return null;
  const year = parseInt(match[1], 10);
  const filename = match[2];
  const provisional = filename.endsWith('-provisional');
  const raceId = provisional ? filename.slice(0, -'-provisional'.length) : filename;
  return { year, raceId, provisional };
}

export function getResultsInfo(year: number, series: Series, raceId: string): ResultsInfo | null {
  const files = csvFilesForSeries(series);
  const provisionalKey = Object.keys(files).find(k => k.includes(`/${year}/${series}/results/${raceId}-provisional.csv`));
  const finalKey = Object.keys(files).find(k => k.includes(`/${year}/${series}/results/${raceId}.csv`) && !k.includes('-provisional'));

  const key = finalKey ?? provisionalKey;
  if (!key) return null;

  return {
    results: parseResultsCsv(files[key]),
    provisional: !finalKey && !!provisionalKey,
  };
}

export function hasResults(year: number, series: Series, raceId: string): boolean {
  const files = csvFilesForSeries(series);
  return Object.keys(files).some(k =>
    k.includes(`/${year}/${series}/results/${raceId}.csv`) ||
    k.includes(`/${year}/${series}/results/${raceId}-provisional.csv`)
  );
}

export function getResultsStaticPaths(series: Series) {
  const files = csvFilesForSeries(series);
  const seen = new Map<string, { year: number; raceId: string; provisional: boolean }>();

  for (const path of Object.keys(files)) {
    const parsed = parseResultsPath(path);
    if (!parsed) continue;
    const { year, raceId, provisional } = parsed;
    const key = `${year}/${raceId}`;
    const existing = seen.get(key);
    // Final (non-provisional) takes precedence; otherwise first seen wins
    if (!existing || (!provisional && existing.provisional)) {
      seen.set(key, { year, raceId, provisional });
    }
  }

  return [...seen.values()].map(({ year, raceId, provisional }) => {
    const info = getResultsInfo(year, series, raceId)!;
    const clubs = getClubs(year);
    const config = getSeriesConfig(year, series);
    return {
      params: { year: String(year), raceId },
      props: { year, raceId, results: info.results, provisional, clubs, config },
    };
  });
}

export function getClubs(year: number): Club[] {
  return clubFiles[`../data/${year}/clubs.json`]?.default ?? [];
}

export function getSeriesConfig(year: number, series: Series): SeriesConfig {
  const files = series === 'road-gp' ? roadConfigFiles : fellConfigFiles;
  return files[`../data/${year}/${series}/config.json`]?.default ?? { categories: [] };
}
