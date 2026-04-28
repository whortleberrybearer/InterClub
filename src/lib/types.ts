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
}

export interface Club {
  id: string;
  name: string;
  shortName: string;
  logo: string;        // filename in /public/images/clubs/, may not exist yet
}

export interface IndividualCategory {
  id: string;
  name: string;
}

export interface SeriesConfig {
  ageCategories: string[];           // renamed from categories
  maxCountingRaces?: number;         // optional; when set, the page shows "Best N races count"
  individualCategories?: IndividualCategory[];
  teamCategories?: TeamCategory[];
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
