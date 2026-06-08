import type { TeamCategory } from './types';

export interface ValidationResult {
  errors: string[];
  warnings: string[];
}

/**
 * Checks that every `cat_*` column in a CSV header corresponds to a known
 * teamCategory id, and that every teamCategory has a matching `cat_*` column.
 *
 * - Extra unknown `cat_*` columns → **error** (wrong data)
 * - Missing expected `cat_*` columns → **warning** (data gap, to be filled later)
 * - CSV with no `cat_*` columns at all → skipped (legacy pre-schema format)
 */
export function validateCsvHeaders(csv: string, teamCategories: TeamCategory[]): ValidationResult {
  const headerLine = csv.split(/\r?\n/)[0] ?? '';
  const headers = headerLine.split(',').map(h => h.trim());
  const catCols = headers.filter(h => h.startsWith('cat_')).map(h => h.slice(4));

  // Legacy CSVs (pre-schema) have no cat_* columns at all — skip entirely.
  if (catCols.length === 0) return { errors: [], warnings: [] };

  const expectedIds = teamCategories.map(c => c.id);
  const errors: string[] = [];
  const warnings: string[] = [];

  for (const id of catCols) {
    if (!expectedIds.includes(id)) {
      errors.push(`Unknown cat_* column "cat_${id}" — not in teamCategories`);
    }
  }
  for (const id of expectedIds) {
    if (!catCols.includes(id)) {
      warnings.push(`teamCategory "${id}" has no "cat_${id}" column in CSV (data not yet processed)`);
    }
  }

  return { errors, warnings };
}

/**
 * Checks that every `club` value in the CSV body refers to a known club id
 * (or is "Guest", or is blank).
 *
 * Unknown club ids → **warning** (may be historical naming or a typo to investigate)
 */
export function validateCsvClubs(csv: string, clubIds: string[]): ValidationResult {
  const lines = csv.replace(/\r\n/g, '\n').replace(/\r/g, '\n').trim().split('\n');
  if (lines.length < 2) return { errors: [], warnings: [] };

  const headers = lines[0].split(',').map(h => h.trim());
  const clubIdx = headers.indexOf('club');
  if (clubIdx === -1) return { errors: [], warnings: [] };

  const unknown = new Set<string>();
  for (const line of lines.slice(1)) {
    if (!line.trim()) continue;
    const clubVal = line.split(',')[clubIdx]?.trim() ?? '';
    if (clubVal && clubVal !== 'Guest' && !clubIds.includes(clubVal)) {
      unknown.add(clubVal);
    }
  }

  if (unknown.size === 0) return { errors: [], warnings: [] };
  return {
    errors: [],
    warnings: [`Unknown club ids: ${[...unknown].sort().join(', ')}`],
  };
}
