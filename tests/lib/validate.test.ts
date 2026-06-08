import { describe, it, expect } from 'vitest';
import { validateCsvHeaders, validateCsvClubs } from '../../src/lib/validate';

// ---- validateCsvHeaders -----------------------------------------------------

const twoCategories = [
  { id: 'open', name: 'Open', scorerCount: 6 },
  { id: 'ladies', name: 'Ladies', scorerCount: 3 },
];

describe('validateCsvHeaders', () => {
  it('returns no errors or warnings when cat_* columns match teamCategories exactly', () => {
    const csv = 'position,cat_open,cat_ladies,first_name,last_name,club,sex,time\n1,1,,A,B,wesham,M,30:00';
    const result = validateCsvHeaders(csv, twoCategories);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('errors on a cat_* column not in teamCategories', () => {
    // has all expected columns PLUS an extra unknown one
    const csv = 'position,cat_open,cat_ladies,cat_typo,first_name,last_name,club,sex,time\n1,1,,,A,B,wesham,M,30:00';
    const result = validateCsvHeaders(csv, twoCategories);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0]).toContain('typo');
    expect(result.warnings).toEqual([]);
  });

  it('warns (not errors) when a teamCategory column is missing from the CSV', () => {
    // CSV has cat_open only; config also expects cat_ladies — data gap, not a hard error
    const csv = 'position,cat_open,first_name,last_name,club,sex,time\n1,1,A,B,wesham,M,30:00';
    const result = validateCsvHeaders(csv, twoCategories);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toHaveLength(1);
    expect(result.warnings[0]).toContain('ladies');
  });

  it('returns no errors or warnings when teamCategories is empty and no cat_* columns present', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,wesham,M,30:00';
    const result = validateCsvHeaders(csv, []);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('returns no errors or warnings when CSV has no cat_* columns at all (legacy format)', () => {
    // Old CSVs predate the category-column schema — skip rather than warn on every category.
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,wesham,M,30:00';
    const result = validateCsvHeaders(csv, twoCategories);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('handles CSVs with no data rows (header only)', () => {
    const csv = 'position,cat_open,cat_ladies,first_name,last_name,club,sex,time';
    const result = validateCsvHeaders(csv, twoCategories);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });
});

// ---- validateCsvClubs -------------------------------------------------------

const clubIds = ['wesham', 'blackpool', 'lytham'];

describe('validateCsvClubs', () => {
  it('returns no errors or warnings when all clubs are known', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,wesham,M,30:00\n2,C,D,blackpool,F,31:00';
    const result = validateCsvClubs(csv, clubIds);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('returns no errors or warnings for Guest club', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,Guest,M,30:00';
    const result = validateCsvClubs(csv, clubIds);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('warns (not errors) on unknown club ids', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,unknown-club,M,30:00\n2,C,D,wesham,F,31:00';
    const result = validateCsvClubs(csv, clubIds);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toHaveLength(1);
    expect(result.warnings[0]).toContain('unknown-club');
  });

  it('deduplicates repeated unknown club ids in warnings', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,bad-club,M,30:00\n2,C,D,bad-club,F,31:00';
    const result = validateCsvClubs(csv, clubIds);
    // should mention bad-club once, not twice
    expect(result.warnings.join(' ').split('bad-club').length - 1).toBe(1);
  });

  it('returns no errors or warnings when club column is absent', () => {
    const csv = 'position,first_name,last_name,sex,time\n1,A,B,M,30:00';
    const result = validateCsvClubs(csv, clubIds);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });

  it('ignores blank club values in rows', () => {
    const csv = 'position,first_name,last_name,club,sex,time\n1,A,B,,M,30:00';
    const result = validateCsvClubs(csv, clubIds);
    expect(result.errors).toEqual([]);
    expect(result.warnings).toEqual([]);
  });
});
