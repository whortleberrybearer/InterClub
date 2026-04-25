import { describe, it, expect } from 'vitest';
import { extractYears } from '../../src/lib/years';

describe('extractYears', () => {
  it('extracts unique years sorted descending', () => {
    const paths = [
      '../data/2026/road-gp/races.json',
      '../data/2026/fell/races.json',
      '../data/2025/road-gp/races.json',
      '../data/2025/fell/races.json',
    ];
    expect(extractYears(paths)).toEqual([2026, 2025]);
  });

  it('returns empty array for no paths', () => {
    expect(extractYears([])).toEqual([]);
  });

  it('handles a single year', () => {
    const paths = ['../data/2026/road-gp/races.json'];
    expect(extractYears(paths)).toEqual([2026]);
  });
});
