import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath, parseIndividualStandingsPath } from '../../src/lib/results';

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

describe('parseTeamStandingsPath', () => {
  it('parses a road-gp standings path', () => {
    expect(parseTeamStandingsPath('../data/2026/road-gp/team-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('parses a fell standings path', () => {
    expect(parseTeamStandingsPath('../data/2026/fell/team-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('returns null for a team results path', () => {
    expect(parseTeamStandingsPath('../data/2026/road-gp/results/bwf-5-teams.json'))
      .toBeNull();
  });

  it('returns null for a config path', () => {
    expect(parseTeamStandingsPath('../data/2026/road-gp/config.json'))
      .toBeNull();
  });
});

describe('parseIndividualStandingsPath', () => {
  it('parses a road-gp individual standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/road-gp/individual-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('parses a fell individual standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/individual-standings.json'))
      .toEqual({ year: 2026 });
  });

  it('returns null for a team-standings path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/team-standings.json'))
      .toBeNull();
  });

  it('returns null for a config path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/config.json'))
      .toBeNull();
  });

  it('returns null for an individual results path', () => {
    expect(parseIndividualStandingsPath('../data/2026/fell/results/race-1.csv'))
      .toBeNull();
  });
});
