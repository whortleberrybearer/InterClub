import { describe, it, expect } from 'vitest';
import { formatRaceDate } from '../../src/lib/format';

describe('formatRaceDate', () => {
  it('formats date with time', () => {
    expect(formatRaceDate('2026-06-07', '10:30')).toBe('Sun 7 Jun · 10:30');
  });

  it('formats date without time', () => {
    expect(formatRaceDate('2026-06-07')).toBe('Sun 7 Jun');
  });

  it('formats a date in July', () => {
    expect(formatRaceDate('2026-07-05', '10:00')).toBe('Sun 5 Jul · 10:00');
  });

  it('formats a date in August', () => {
    expect(formatRaceDate('2026-08-30', '10:00')).toBe('Sun 30 Aug · 10:00');
  });

  it('handles single-digit days without zero padding', () => {
    expect(formatRaceDate('2026-08-02', '09:00')).toBe('Sun 2 Aug · 09:00');
  });
});
