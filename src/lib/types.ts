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

export interface SeriesConfig {
  categories: string[];
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
