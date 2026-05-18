import { describe, it, expect } from 'vitest';
import { runnerSlug, parseSeriesRunnerPath, formatYearRanges } from '../../src/lib/runners';
import type { GlobalRunner } from '../../src/lib/types';

const makeRunner = (overrides: Partial<GlobalRunner> = {}): GlobalRunner => ({
  id: 1,
  firstName: 'Luke',
  lastName: 'Minns',
  club: 'blackpool',
  sex: 'M',
  category: 'V35',
  ...overrides,
});

describe('runnerSlug', () => {
  it('produces id-firstname-lastname', () => {
    expect(runnerSlug(makeRunner())).toBe('1-luke-minns');
  });

  it('uses the global numeric id as prefix', () => {
    expect(runnerSlug(makeRunner({ id: 42 }))).toBe('42-luke-minns');
  });

  it('lowercases the name', () => {
    expect(runnerSlug(makeRunner({ firstName: 'JANE', lastName: 'DOE' }))).toBe('1-jane-doe');
  });

  it('replaces non-alphanumeric characters with hyphens', () => {
    expect(runnerSlug(makeRunner({ firstName: "O'Brien", lastName: 'Smith-Jones' }))).toBe('1-o-brien-smith-jones');
  });

  it('collapses consecutive hyphens', () => {
    expect(runnerSlug(makeRunner({ firstName: 'A  B', lastName: 'C' }))).toBe('1-a-b-c');
  });
});

describe('parseSeriesRunnerPath', () => {
  it('parses road-gp runner path', () => {
    expect(parseSeriesRunnerPath('../data/2026/road-gp/runners.json')).toEqual({ year: 2026, series: 'road-gp' });
  });

  it('parses fell runner path', () => {
    expect(parseSeriesRunnerPath('../data/2019/fell/runners.json')).toEqual({ year: 2019, series: 'fell' });
  });

  it('returns null for non-runner paths', () => {
    expect(parseSeriesRunnerPath('../data/2026/road-gp/races.json')).toBeNull();
    expect(parseSeriesRunnerPath('../data/2026/road-gp/results/bwf-5.csv')).toBeNull();
  });
});

describe('formatYearRanges', () => {
  it('returns empty string for empty input', () => {
    expect(formatYearRanges([])).toBe('');
  });

  it('returns a single year as a plain number', () => {
    expect(formatYearRanges([2025])).toBe('2025');
  });

  it('collapses two consecutive years into a range', () => {
    expect(formatYearRanges([2024, 2025])).toBe('2024–2025');
  });

  it('collapses a contiguous run into a single range', () => {
    expect(formatYearRanges([2019, 2020, 2021])).toBe('2019–2021');
  });

  it('separates non-contiguous years with a comma', () => {
    expect(formatYearRanges([2022, 2025])).toBe('2022, 2025');
  });

  it('produces a range then a trailing gap year', () => {
    expect(formatYearRanges([2019, 2020, 2021, 2025])).toBe('2019–2021, 2025');
  });

  it('handles multiple isolated years', () => {
    expect(formatYearRanges([2019, 2021, 2023])).toBe('2019, 2021, 2023');
  });

  it('sorts unsorted input before processing', () => {
    expect(formatYearRanges([2025, 2019, 2020])).toBe('2019–2020, 2025');
  });
});
