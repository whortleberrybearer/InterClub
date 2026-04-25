import type { Race, Series, SiteConfig } from './types';
import { extractYears } from './years';
import configData from '../data/config.json';

const config = configData as SiteConfig;

const raceFiles = import.meta.glob<{ default: Race[] }>(
  '../data/*/*/races.json',
  { eager: true }
);

export function getCurrentYear(): number {
  return config.currentYear;
}

export function getAvailableYears(): number[] {
  return extractYears(Object.keys(raceFiles));
}

export function getRaces(year: number, series: Series): Race[] {
  const key = `../data/${year}/${series}/races.json`;
  return raceFiles[key]?.default ?? [];
}

export function getRace(year: number, series: Series, raceId: string): Race | undefined {
  return getRaces(year, series).find(r => r.id === raceId);
}
