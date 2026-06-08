import { describe, it, expect } from 'vitest';
import {
  formatRaceDate, formatRaceDateShort, formatTime,
  getSeriesLabel, getSeriesLongLabel,
  positionLabel, seriesAccent,
} from '../../src/lib/format';

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

describe('formatRaceDateShort', () => {
  it('formats a date as DD/MM', () => {
    expect(formatRaceDateShort('2026-06-07')).toBe('07/06');
  });

  it('zero-pads single-digit day and month', () => {
    expect(formatRaceDateShort('2026-04-05')).toBe('05/04');
  });

  it('handles double-digit day and month', () => {
    expect(formatRaceDateShort('2026-11-22')).toBe('22/11');
  });
});

describe('positionLabel', () => {
  it('appends st to 1', () => {
    expect(positionLabel(1)).toBe('1st');
  });

  it('appends nd to 2', () => {
    expect(positionLabel(2)).toBe('2nd');
  });

  it('appends rd to 3', () => {
    expect(positionLabel(3)).toBe('3rd');
  });

  it('appends th to 4 through 20', () => {
    expect(positionLabel(4)).toBe('4th');
    expect(positionLabel(11)).toBe('11th');
    expect(positionLabel(12)).toBe('12th');
    expect(positionLabel(13)).toBe('13th');
  });

  it('appends st/nd/rd correctly for 21–23', () => {
    expect(positionLabel(21)).toBe('21st');
    expect(positionLabel(22)).toBe('22nd');
    expect(positionLabel(23)).toBe('23rd');
  });

  it('appends th for 100–120 (teens override)', () => {
    expect(positionLabel(111)).toBe('111th');
    expect(positionLabel(112)).toBe('112th');
    expect(positionLabel(113)).toBe('113th');
  });
});

describe('seriesAccent', () => {
  it('returns amber classes for road-gp', () => {
    const a = seriesAccent('road-gp');
    expect(a.text).toBe('text-amber');
    expect(a.bg).toBe('bg-amber-bg');
    expect(a.badge).toBe('bg-amber');
    expect(a.border).toBe('border-amber');
    expect(a.borderLeft).toBe('border-l-amber');
    expect(a.time).toBe('text-amber/70');
    expect(a.hoverText).toBe('hover:text-amber');
    expect(a.soft).toContain('amber');
  });

  it('returns teal classes for fell', () => {
    const a = seriesAccent('fell');
    expect(a.text).toBe('text-teal');
    expect(a.bg).toBe('bg-teal-bg');
    expect(a.badge).toBe('bg-teal');
    expect(a.border).toBe('border-teal');
    expect(a.borderLeft).toBe('border-l-teal');
    expect(a.time).toBe('text-teal/70');
    expect(a.hoverText).toBe('hover:text-teal');
    expect(a.soft).toContain('teal');
  });

  it('returns distinct values for fell and road-gp', () => {
    const fell   = seriesAccent('fell');
    const roadGp = seriesAccent('road-gp');
    expect(fell.text).not.toBe(roadGp.text);
    expect(fell.badge).not.toBe(roadGp.badge);
  });
});
