export type Series = 'road-gp' | 'fell';

export interface SiteConfig {
  currentYear: number;
}

export interface Race {
  id: string;
  name: string;
  date: string;       // ISO date string: "2026-06-07"
  time?: string;      // "HH:MM", e.g. "10:30"
  location?: string;
  distance?: string;
  detailsUrl?: string;
  image?: string;     // filename relative to /public/images/
  shortName?: string;
}

export interface RaceResult {
  position: number | null;
  icPosition: number | null;
  firstName: string;
  lastName: string;
  club: string;        // club id (e.g. 'blackpool') or 'Guest'
  category: string;   // e.g. 'SEN', 'V35', 'U17'
  sex: string;        // 'M' or 'F'
  time: string;       // 'MM:SS', may be empty
  raceNumber: number | null;
  seriesRunnerId: number | null;   // series-local runner ID from CSV; null when absent
}

export interface Club {
  id: string;
  name: string;
  shortName: string;
  logo: string;        // filename in /public/images/clubs/, may not exist yet
}

export interface GlobalRunner {
  id: number;
  firstName: string;
  lastName: string;
  club: string;       // club id matching clubs.json
  sex: string;        // 'M' or 'F'
  category: string;   // e.g. 'SEN', 'V40'
}

export interface SeriesRunner {
  id: number;         // series-local numeric ID; referenced from CSV series_runner_id
  runnerId: number;   // references GlobalRunner.id
  firstName: string;
  lastName: string;
  club: string;
  sex: string;
  category: string;
  number?: number;    // optional bib number
}

export interface RunnerProfileRace {
  date: string;       // ISO date e.g. "2026-04-01"
  raceName: string;
  raceId: string;
  time: string;
  hasResults: boolean;
}

export interface RunnerProfileAward {
  categoryName: string;
  position: number;
}

export interface RunnerYearSeries {
  races: RunnerProfileRace[];
  awards: RunnerProfileAward[];
}

export interface RunnerYearBlock {
  year: number;
  roadGp?: RunnerYearSeries;
  fell?: RunnerYearSeries;
}

export interface IndividualCategory {
  id: string;
  name: string;
  sex?: 'M' | 'F';
}

export interface SeriesConfig {
  ageCategories?: string[];          // renamed from categories; now optional
  maxCountingRaces?: number;         // optional; when set, the page shows "Best N races count"
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
  note?: string;                     // optional; used for suspended seasons
}

export interface TeamCategory {
  id: string;
  name: string;
  scorerCount: number;
}

export interface TeamScorer {
  name: string;
  position: number;   // rank within the sex/age group used for team scoring
}

export interface TeamClubResult {
  position: number;   // finishing position in this team category
  points: number;     // season points earned (stored explicitly)
  club: string;       // id → Club lookup via clubs.json
  total: number;      // sum of scorer positions
  scorers: TeamScorer[];
}

export interface TeamCategoryResult {
  category: string;   // id → TeamCategory lookup via config.teamCategories
  clubs: TeamClubResult[];
}

export interface TeamResults {
  categories: TeamCategoryResult[];
}

export interface TeamStandingsClub {
  position: number;
  club: string;
  points: (number | null)[];
  total: number;
  tiebreaker: string | null;
}

export interface TeamStandingsCategory {
  category: string;
  clubs: TeamStandingsClub[];
}

export interface TeamStandings {
  provisional: boolean;
  races: string[];
  categories: TeamStandingsCategory[];
}

export interface IndividualRaceResult {
  points: number;
  counting: boolean;
}

export interface IndividualStandingsRunner {
  position: number;
  name: string;
  club: string;
  sex: string;          // 'M' or 'F'
  ageCategory: string;  // e.g. 'SEN', 'V40'
  total: number;
  results: Record<string, IndividualRaceResult>;  // keyed by race id; only races the runner entered
  seriesRunnerId?: number;   // optional; links standing entry to a runner profile
}

export interface IndividualStandingsCategory {
  category: string;   // id → IndividualCategory lookup via config.individualCategories
  runners: IndividualStandingsRunner[];
}

export interface IndividualStandings {
  provisional: boolean;
  races: string[];    // ordered list of race ids; defines column order
  categories: IndividualStandingsCategory[];
}

// Raw awards data (from awards.json)
export interface TeamAward {
  category: string;  // references teamCategories[].id in config.json
  club: string;      // references clubs.json id
}

export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;      // references clubs.json id
  seriesRunnerId?: number;   // optional; links award to a runner profile
}

export interface IndividualAward {
  category: string;  // references individualCategories[].id in config.json
  awards: IndividualAwardEntry[];
}

export interface SeriesAwards {
  teamAwards: TeamAward[];
  individualAwards: IndividualAward[];
}

// Resolved awards data (display names looked up, categories partitioned by sex)
export interface ResolvedTeamAward {
  categoryName: string;
  clubName: string;
}

export interface ResolvedIndividualAwardEntry {
  position: number;
  name: string;
  clubName: string;
  runnerUrl?: string;   // resolved profile URL when seriesRunnerId is present
}

export interface ResolvedIndividualAward {
  categoryName: string;
  awards: ResolvedIndividualAwardEntry[];
}

export interface ResolvedSeriesAwards {
  teamAwards: ResolvedTeamAward[];
  overallAwards: ResolvedIndividualAward[];  // sex field absent on config category
  maleAwards: ResolvedIndividualAward[];     // sex === 'M' on config category
  femaleAwards: ResolvedIndividualAward[];   // sex === 'F' on config category
}
