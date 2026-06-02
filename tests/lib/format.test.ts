import { describe, it, expect } from 'vitest';
import { formatRaceDate, formatTime, getSeriesLabel, getSeriesLongLabel } from '../../src/lib/format';

describe('formatTime', () => {
  it('formats a sub-hour mm:ss time', () => {
    expect(formatTime('25:10')).toBe('25:10');
  });

  it('formats a single-digit minutes mm:ss time', () => {
    expect(formatTime('9:30')).toBe('9:30');
  });

  it('converts mm:ss where minutes >= 60 to h:mm:ss', () => {
    expect(formatTime('89:40')).toBe('1:29:40');
  });

  it('formats a stored hh:mm:ss with leading-zero hours to h:mm:ss', () => {
    expect(formatTime('01:29:40')).toBe('1:29:40');
  });

  it('formats a stored hh:mm:ss sub-hour to m:ss', () => {
    expect(formatTime('00:25:10')).toBe('25:10');
  });

  it('pads minutes and seconds when hours present', () => {
    expect(formatTime('1:05:03')).toBe('1:05:03');
  });

  it('returns dash for null', () => {
    expect(formatTime(null)).toBe('–');
  });

  it('returns dash for undefined', () => {
    expect(formatTime(undefined)).toBe('–');
  });

  it('returns dash for empty string', () => {
    expect(formatTime('')).toBe('–');
  });
});

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

describe('getSeriesLabel', () => {
  it('returns short label for road-gp', () => {
    expect(getSeriesLabel('road-gp')).toBe('Road GP');
  });
  it('returns short label for fell', () => {
    expect(getSeriesLabel('fell')).toBe('Fell Championship');
  });
});

describe('getSeriesLongLabel', () => {
  it('returns long label for road-gp', () => {
    expect(getSeriesLongLabel('road-gp')).toBe('Road Grand Prix');
  });
  it('returns long label for fell', () => {
    expect(getSeriesLongLabel('fell')).toBe('Fell Championship');
  });
});
