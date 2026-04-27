import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath } from '../../src/lib/results';

describe('parseResultsCsv', () => {
  const sample = [
    'position,ic_position,first_name,last_name,club,category,sex,time',
    '1,1,Luke,Minns,blackpool,V35,M,19:35',
    '2,2,Rob,Danson,preston,V35,M,19:38',
    '3,,T.,Guest,Guest,SEN,M,20:00',
  ].join('\n');

  it('returns one row per data line', () => {
    expect(parseResultsCsv(sample)).toHaveLength(3);
  });

  it('parses position and icPosition as numbers', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.position).toBe(1);
    expect(first.icPosition).toBe(1);
  });

  it('parses icPosition as null when empty (guest runner)', () => {
    const results = parseResultsCsv(sample);
    expect(results[2].icPosition).toBeNull();
  });

  it('parses position as null when empty', () => {
    const csv = 'position,ic_position,first_name,last_name,club,category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
    const [row] = parseResultsCsv(csv);
    expect(row.position).toBeNull();
  });

  it('maps all string fields correctly', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.firstName).toBe('Luke');
    expect(first.lastName).toBe('Minns');
    expect(first.club).toBe('blackpool');
    expect(first.category).toBe('V35');
    expect(first.sex).toBe('M');
    expect(first.time).toBe('19:35');
  });

  it('handles Windows line endings (CRLF)', () => {
    const crlf = sample.replace(/\n/g, '\r\n');
    expect(parseResultsCsv(crlf)).toHaveLength(3);
  });

  it('returns empty array for header-only CSV', () => {
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,category,sex,time')).toHaveLength(0);
  });

  it('returns empty array for empty string', () => {
    expect(parseResultsCsv('')).toHaveLength(0);
  });
});

describe('parseTeamResultsPath', () => {
  it('parses a final road-gp team results path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5-teams.json'))
      .toEqual({ year: 2026, raceId: 'bwf-5', provisional: false });
  });

  it('parses a provisional team results path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5-teams-provisional.json'))
      .toEqual({ year: 2026, raceId: 'bwf-5', provisional: true });
  });

  it('parses a fell path', () => {
    expect(parseTeamResultsPath('../data/2026/fell/results/race-1-teams.json'))
      .toEqual({ year: 2026, raceId: 'race-1', provisional: false });
  });

  it('parses a race id containing hyphens', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/long-race-id-teams.json'))
      .toEqual({ year: 2026, raceId: 'long-race-id', provisional: false });
  });

  it('returns null for a CSV path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/results/bwf-5.csv')).toBeNull();
  });

  it('returns null for a non-teams JSON path', () => {
    expect(parseTeamResultsPath('../data/2026/road-gp/config.json')).toBeNull();
  });
});
