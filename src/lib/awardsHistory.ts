import { CLUB_COLORS } from './clubColors';
import {
  getAllAwardsByYear,
  getAllSeriesConfigs,
  pivotIndividualAwardsByCategory,
  resolveIndividualCategoryName,
} from './results';
import { buildRunnerUrlMap, buildRunnerSexMap } from './runners';
import type { Series, TeamCategory } from './types';
import type { CategoryHistoryData } from './results';

export const CANONICAL_IDS: Record<Series, string[]> = {
  'road-gp': ['open', 'ladies', 'vets', 'lady-vets', 'vet50s', 'vet60s'],
  'fell':    ['open', 'ladies', 'vets', 'vet50s', 'vet60s'],
};

export const ID_ALIASES: Record<string, string> = {
  'women':    'ladies',
  'womens':   'ladies',
  'v50':      'vet50s',
  'vet50':    'vet50s',
  'v60':      'vet60s',
  'vet60':    'vet60s',
  'ladyvets': 'lady-vets',
};

export interface ClubInfo {
  id: string;
  name: string;
  shortName: string;
  swatch: string;
  ink: string;
  vest?: string;
}

export interface EnrichedCategory extends TeamCategory {
  since: number;
}

export interface TeamHistoryRow {
  year: number;
  suspended?: string;
  categoryWinners: Record<string, ClubInfo | null>;
}

const CLUB_SWATCHES: Record<string, { swatch: string; ink: string }> = {
  ...Object.fromEntries(Object.entries(CLUB_COLORS).map(([id, color]) => [id, { swatch: color, ink: '#fff' }])),
  'blackpool-fylde': { swatch: CLUB_COLORS.blackpool ?? '#e85d2c',  ink: '#fff' },
  'north-fylde':     { swatch: 'var(--club-north-fylde)',              ink: 'var(--club-north-fylde-ink)' },
  'springfields':    { swatch: '#6b7280',                              ink: '#fff' },
};

const HISTORICAL_CLUBS: [string, ClubInfo][] = [
  ['north-fylde',     { id: 'north-fylde',     name: 'North Fylde AC',      shortName: 'NFA', swatch: 'var(--club-north-fylde)',              ink: 'var(--club-north-fylde-ink)' }],
  ['springfields',    { id: 'springfields',    name: 'Springfields AC',      shortName: 'SAC', swatch: '#6b7280',                             ink: '#fff' }],
  ['blackpool-fylde', { id: 'blackpool-fylde', name: 'Blackpool & Fylde AC', shortName: 'BFA', swatch: CLUB_COLORS.blackpool ?? '#e85d2c', ink: '#fff' }],
  ['chorley-ac',      { id: 'chorley-ac',      name: 'Chorley AC',           shortName: 'CAC', swatch: CLUB_COLORS['chorley-ac'] ?? '#8c1c1c', ink: '#fff' }],
];

export function buildClubMeta(series: Series): Record<string, ClubInfo> {
  const allYearlyAwards = getAllAwardsByYear(series);
  const clubMetaMap = new Map<string, ClubInfo>(HISTORICAL_CLUBS);

  allYearlyAwards.forEach(yearly => {
    yearly.clubs.forEach(club => {
      const swatchData = CLUB_SWATCHES[club.id] ?? { swatch: 'oklch(55% 0.08 250)', ink: '#fff' };
      clubMetaMap.set(club.id, {
        id: club.id,
        name: club.name,
        shortName: club.shortName ?? club.id.slice(0, 3).toUpperCase(),
        vest: club.vest,
        ...swatchData,
      });
    });
  });

  return Object.fromEntries(clubMetaMap);
}

export function buildTeamHistory(
  series: Series,
  canonicalIds: string[],
  idAliases: Record<string, string>,
  clubMeta: Record<string, ClubInfo>
): { allCategories: EnrichedCategory[]; fullYearList: TeamHistoryRow[] } {
  const allYearlyAwards = getAllAwardsByYear(series);
  const normalize = (id: string) => idAliases[id] ?? id;
  const ascendingYears = [...allYearlyAwards].sort((a, b) => a.year - b.year);

  const categorySince = new Map<string, number>();
  ascendingYears.forEach(yearly => {
    yearly.awards.teamAwards.forEach(award => {
      const id = normalize(award.id);
      if (canonicalIds.includes(id) && !categorySince.has(id)) categorySince.set(id, yearly.year);
    });
    yearly.config.teamCategories?.forEach(cat => {
      const id = normalize(cat.id);
      if (canonicalIds.includes(id) && !categorySince.has(id)) categorySince.set(id, yearly.year);
    });
  });

  const categoryMap = new Map<string, TeamCategory>();
  ascendingYears.forEach(yearly => {
    yearly.config.teamCategories?.forEach(cat => {
      const id = normalize(cat.id);
      if (canonicalIds.includes(id) && !categoryMap.has(id)) {
        categoryMap.set(id, { ...cat, id });
      }
    });
  });
  for (const id of canonicalIds) {
    if (!categoryMap.has(id) && categorySince.has(id)) {
      const name = id.charAt(0).toUpperCase() + id.slice(1).replace(/[-_]/g, ' ');
      categoryMap.set(id, { id, name, scorerCount: 0 });
    }
  }

  const allCategories: EnrichedCategory[] = canonicalIds
    .filter(id => categoryMap.has(id))
    .map(id => ({ ...categoryMap.get(id)!, since: categorySince.get(id) ?? 0 }));

  const noteByYear = new Map(
    getAllSeriesConfigs(series)
      .filter(({ config }) => !!config.note)
      .map(({ year, config }) => [year, config.note!])
  );
  const awardYearSet = new Set(allYearlyAwards.map(y => y.year));
  const allYearsSorted = [...new Set([...awardYearSet, ...noteByYear.keys()])]
    .sort((a, b) => b - a);

  const fullYearList: TeamHistoryRow[] = [];
  for (const year of allYearsSorted) {
    if (awardYearSet.has(year)) {
      const yearly = allYearlyAwards.find(y => y.year === year)!;
      const categoryWinners: Record<string, ClubInfo | null> = {};
      allCategories.forEach(cat => { categoryWinners[cat.id] = null; });
      yearly.awards.teamAwards.forEach(award => {
        const id = normalize(award.id);
        if (!(id in categoryWinners)) return;
        const meta = clubMeta[award.club];
        categoryWinners[id] = meta
          ? { ...meta }
          : { id: award.club, name: award.club, shortName: award.club.slice(0, 3).toUpperCase(), swatch: 'oklch(55% 0.08 250)', ink: '#fff' };
      });
      fullYearList.push({ year, categoryWinners });
    } else {
      fullYearList.push({ year, suspended: noteByYear.get(year)!, categoryWinners: {} });
    }
  }

  return { allCategories, fullYearList };
}

export function buildIndividualHistoryData(
  series: Series,
  clubMeta: Record<string, ClubInfo>
): CategoryHistoryData[] {
  const allYearlyAwards = getAllAwardsByYear(series);
  const noteByYear = new Map(
    getAllSeriesConfigs(series)
      .filter(({ config }) => !!config.note)
      .map(({ year, config }) => [year, config.note!])
  );
  const yearlyResolved = allYearlyAwards.map(yearly => {
    const runnerUrlMap = buildRunnerUrlMap(yearly.year, series);
    const runnerSexMap = buildRunnerSexMap(yearly.year, series);
    return {
      year: yearly.year,
      categories: yearly.awards.individualAwards.map(ia => ({
        id: ia.id,
        name: resolveIndividualCategoryName(ia.id, ia.sex, ia.ageCategory, ia.name),
        sex: ia.sex ?? null,
        awards: ia.awards.map(a => {
          // Prefer that year's club roster (captures the vest in use at the time), falling
          // back to clubMeta for clubs no longer in a current clubs.json (e.g. defunct clubs).
          const yearClub = yearly.clubs.find(c => c.id === a.club);
          const meta = clubMeta[a.club];
          return {
            position: a.position,
            name: a.name,
            clubName: yearClub?.name ?? meta?.name ?? a.club ?? '',
            clubVest: yearClub?.vest ?? meta?.vest ?? 'unknown.png',
            runnerUrl: a.seriesRunnerId != null ? runnerUrlMap[a.seriesRunnerId] : undefined,
            // Sex-agnostic (overall) categories need the runner's actual sex to be
            // attributed to the correct Men's/Women's cross-category leaderboard.
            sex: a.seriesRunnerId != null ? runnerSexMap[a.seriesRunnerId] : undefined,
          };
        }),
      })),
    };
  });
  return pivotIndividualAwardsByCategory(yearlyResolved, noteByYear);
}
