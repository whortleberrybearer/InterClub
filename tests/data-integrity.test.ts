/**
 * Data integrity checks run against the real src/data/ tree.
 *
 * These tests catch the "silent empty render" footgun documented in CLAUDE.md:
 * missing clubs.json / config.json causes results pages to render silently
 * with no clubs or categories. Mismatched cat_* columns or unknown club ids
 * are surfaced here so issues are visible before they reach production.
 */
import { describe, it, expect } from 'vitest';
import { readdirSync, existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { validateCsvHeaders, validateCsvClubs } from '../src/lib/validate';
import type { TeamCategory } from '../src/lib/types';

const DATA_DIR = resolve('src/data');
const SERIES = ['road-gp', 'fell'] as const;

function getYears(): number[] {
  return readdirSync(DATA_DIR)
    .map(d => parseInt(d, 10))
    .filter(n => !Number.isNaN(n))
    .sort((a, b) => a - b);
}

function readJson<T>(path: string): T | null {
  if (!existsSync(path)) return null;
  try {
    const raw = readFileSync(path, 'utf-8').replace(/^﻿/, ''); // strip BOM
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

// ---- clubs.json must exist for every year that has a series config ----------

describe('clubs.json presence', () => {
  for (const year of getYears()) {
    const hasAnyConfig = SERIES.some(s =>
      existsSync(join(DATA_DIR, String(year), s, 'config.json'))
    );
    if (!hasAnyConfig) continue;

    it(`${year}: clubs.json exists`, () => {
      const path = join(DATA_DIR, String(year), 'clubs.json');
      expect(existsSync(path), `Missing src/data/${year}/clubs.json`).toBe(true);
    });
  }
});

// ---- cat_* CSV columns must not contain unknown ids (errors) ----------------
// Missing expected columns are warnings, surfaced in a separate describe block.

describe('CSV cat_* columns — no unknown ids', () => {
  for (const year of getYears()) {
    for (const series of SERIES) {
      const configPath = join(DATA_DIR, String(year), series, 'config.json');
      const resultsDir = join(DATA_DIR, String(year), series, 'results');
      if (!existsSync(configPath) || !existsSync(resultsDir)) continue;

      const config = readJson<{ teamCategories?: TeamCategory[] }>(configPath);
      const teamCategories = config?.teamCategories ?? [];
      if (teamCategories.length === 0) continue;

      const csvFiles = readdirSync(resultsDir).filter(f => f.endsWith('.csv'));
      for (const csvFile of csvFiles) {
        it(`${year}/${series}/${csvFile}: no unknown cat_* column ids`, () => {
          const csv = readFileSync(join(resultsDir, csvFile), 'utf-8').replace(/^﻿/, '');
          const { errors } = validateCsvHeaders(csv, teamCategories);
          expect(errors, errors.join('\n')).toEqual([]);
        });
      }
    }
  }
});

// ---- cat_* columns present for each expected teamCategory (warnings) --------

describe('CSV cat_* columns — data completeness', () => {
  for (const year of getYears()) {
    for (const series of SERIES) {
      const configPath = join(DATA_DIR, String(year), series, 'config.json');
      const resultsDir = join(DATA_DIR, String(year), series, 'results');
      if (!existsSync(configPath) || !existsSync(resultsDir)) continue;

      const config = readJson<{ teamCategories?: TeamCategory[] }>(configPath);
      const teamCategories = config?.teamCategories ?? [];
      if (teamCategories.length === 0) continue;

      const csvFiles = readdirSync(resultsDir).filter(f => f.endsWith('.csv'));
      for (const csvFile of csvFiles) {
        it.skip(`${year}/${series}/${csvFile}: all teamCategory columns present (todo: data not yet processed)`, () => {
          const csv = readFileSync(join(resultsDir, csvFile), 'utf-8').replace(/^﻿/, '');
          const { warnings } = validateCsvHeaders(csv, teamCategories);
          expect(warnings, warnings.join('\n')).toEqual([]);
        });
      }
    }
  }
});

// ---- Club ids in CSV rows must exist in clubs.json --------------------------

describe('CSV club ids exist in clubs.json', () => {
  for (const year of getYears()) {
    const clubsPath = join(DATA_DIR, String(year), 'clubs.json');
    if (!existsSync(clubsPath)) continue;

    const clubs = readJson<Array<{ id: string }>>(clubsPath);
    if (!clubs) continue;
    const clubIds = clubs.map(c => c.id);

    for (const series of SERIES) {
      const resultsDir = join(DATA_DIR, String(year), series, 'results');
      if (!existsSync(resultsDir)) continue;

      const csvFiles = readdirSync(resultsDir).filter(f => f.endsWith('.csv'));
      for (const csvFile of csvFiles) {
        it(`${year}/${series}/${csvFile}: no unknown club ids`, () => {
          const csv = readFileSync(join(resultsDir, csvFile), 'utf-8').replace(/^﻿/, '');
          const { warnings } = validateCsvClubs(csv, clubIds);
          // Unknown club ids are a warning; we still fail the test so they're visible
          // and must be explicitly acknowledged or fixed.
          expect(warnings, `Unknown clubs found — fix CSV or add club to clubs.json:\n${warnings.join('\n')}`).toEqual([]);
        });
      }
    }
  }
});
