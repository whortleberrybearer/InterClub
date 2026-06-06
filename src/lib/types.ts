export type Series = 'road-gp' | 'fell';

export interface SiteConfig {
  currentYear: number;
}

export interface Race {
  id: string;
  name: string;
  shortName?: string;
  date: string;       // ISO date string: "2026-06-07"
  time?: string;      // "HH:MM", e.g. "10:30"
  location?: string;
  distance?: string;
  ascent?: string;    // e.g. "150m"
  startAddress?: string;
  mapEmbedUrl?: string;      // Google Maps embed URL (from Share → Embed a map)
  parking?: string;          // free-text parking instructions
  routeImage?: string;       // filename relative to /public/images/
  routeDescription?: string; // free-text route description
  courseRecords?: CourseRecord[];
  postRaceVenue?: string;    // free-text post-race venue description
  detailsUrl?: string;
  image?: string;     // filename relative to /public/images/
}

export interface CourseRecord {
  sex: 'M' | 'F';
  time: string;   // "MM:SS", e.g. "24:15"
  name: string;   // e.g. "J. Smith"
  year: number;
}

export interface RaceResult {
  position: number | null;
  categoryPositions: Record<string, number | null>;
  firstName: string;
  lastName: string;
  club: string;        // club id (e.g. 'blackpool') or 'Guest'
  ageCategory: string;   // e.g. 'SEN', 'V35', 'U17'
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
  vest?: string;       // filename in /public/images/vests/, e.g. 'blackpool-sm.png'
}

export interface GlobalRunner {
  id: number;
  firstName: string;
  lastName: string;
  club: string;       // club id matching clubs.json
  sex: string;        // 'M' or 'F'
  ageCategory: string;        // e.g. 'SEN', 'V40'
  ageCategoryYear?: number;   // year the ageCategory was recorded
}

export interface SeriesRunner {
  id: number;         // series-local numeric ID; referenced from CSV series_runner_id
  runnerId: number;   // references GlobalRunner.id
  firstName: string;
  lastName: string;
  club: string;
  sex: string;
  ageCategory: string;
  number?: number;    // optional bib number
}

export interface RunnerProfileRace {
  date: string;       // ISO date e.g. "2026-04-01"
  raceName: string;
  raceId: string;
  time: string;
  hasResults: boolean;
  position: number | null;   // runner's overall finish position
  totalOpen: number | null;  // total finishers in the open category (null if not available)
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

export interface RunnerClubHistory {
  clubId: string;
  clubName: string;
  yearRanges: string;   // pre-formatted, e.g. "2019–2021, 2025"
  vest?: string;        // vest filename e.g. "blackpool.png" from clubs.json
}

export interface RunnerAwardSummaryEntry {
  categoryName: string;
  position: number;
  count: number;
}

export interface RunnerAwardSummary {
  roadGp: RunnerAwardSummaryEntry[];
  fell: RunnerAwardSummaryEntry[];
}

export interface SeriesConfig {
  ageCategories?: string[];          // renamed from categories; now optional
  teamCategories?: TeamCategory[];
  note?: string;                     // optional; used for suspended seasons
}

export interface TeamCategory {
  id: string;
  name: string;
  shortName?: string;     // abbreviated column header (≤3 chars); falls back to first 3 chars of name
  scorerCount: number;
  eligibility?: string;   // e.g. "All finishers", "Women", "Men & Women 40+"
}

export interface TeamScorer {
  name: string;
  position: number;         // rank within the sex/age group used for team scoring
  seriesRunnerId?: number;  // optional; links scorer to a runner profile page
}

export interface TeamClubResult {
  position: number;   // finishing position in this team category
  points: number;     // season points earned (stored explicitly)
  club: string;       // id → Club lookup via clubs.json
  total: number;      // sum of scorer positions
  scorers: TeamScorer[];
}

export interface TeamCategoryResult {
  id: string;   // id → TeamCategory lookup via config.teamCategories
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
  id: string;
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
  sex?: string;          // 'M' or 'F'; optional when inherited from category
  ageCategory?: string;  // e.g. 'SEN', 'V40'; optional when inherited from category
  total: number;
  results: Record<string, IndividualRaceResult | null>;  // keyed by race id; null means the runner did not enter that race
  seriesRunnerId?: number;   // optional; links standing entry to a runner profile
}

export interface IndividualStandingsCategory {
  id: string;
  sex?: 'M' | 'F';       // when set, runners in this category inherit it
  ageCategory?: string;   // when set, runners in this category inherit it
  name?: string;          // explicit display name override (e.g. "Overall", "Men")
  runners: IndividualStandingsRunner[];
}

export interface IndividualStandings {
  provisional: boolean;
  maxCountingRaces?: number;  // moved from SeriesConfig; page shows "Best N races count"
  races: string[];    // ordered list of race ids; defines column order
  categories: IndividualStandingsCategory[];
}

// Raw awards data (from awards.json)
export interface TeamAward {
  id: string;  // references teamCategories[].id in config.json
  club: string;      // references clubs.json id
}

export interface IndividualAwardEntry {
  position: number;
  name: string;
  club: string;      // references clubs.json id
  ageCategory?: string;
  seriesRunnerId?: number;   // optional; links award to a runner profile
}

export interface IndividualAward {
  id: string;
  sex?: 'M' | 'F';       // drives overall/male/female column split in SeriesAwards
  ageCategory?: string;
  name?: string;
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
  vest?: string;       // vest filename e.g. "blackpool.png" from clubs.json
  shortName?: string;  // club abbreviation e.g. "PH"
}

export interface ResolvedIndividualAwardEntry {
  position: number;
  name: string;
  clubName: string;
  vest?: string;        // club vest filename e.g. "blackpool.png"
  ageCategory?: string; // runner's age category (e.g. "V40"); set when relevant to display
  runnerUrl?: string;   // resolved profile URL when seriesRunnerId is present
}

export interface ResolvedIndividualAward {
  categoryName: string;
  /** Age category key used for pairing male/female rows (e.g. "SEN", "V40"). Absent for overall/no-age categories. */
  ageCategory?: string;
  /** True when the category itself has no age filter — show each runner's age category. */
  showAgeCategory: boolean;
  awards: ResolvedIndividualAwardEntry[];
}

export interface ResolvedSeriesAwards {
  teamAwards: ResolvedTeamAward[];
  overallAwards: ResolvedIndividualAward[];  // sex absent on award
  maleAwards: ResolvedIndividualAward[];     // sex === 'M' on award
  femaleAwards: ResolvedIndividualAward[];   // sex === 'F' on award
}
