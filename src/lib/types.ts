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
