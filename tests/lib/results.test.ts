import { describe, it, expect } from 'vitest';
import { parseResultsCsv, parseTeamResultsPath, parseTeamStandingsPath, parseIndividualStandingsPath, pivotIndividualAwardsByCategory } from '../../src/lib/results';

describe('parseResultsCsv', () => {
  const sample = [
    'position,ic_position,first_name,last_name,club,age_category,sex,time',
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
    const csv = 'position,ic_position,first_name,last_name,club,age_category,sex,time\n,,Jane,Smith,wesham,SEN,F,25:00';
    const [row] = parseResultsCsv(csv);
    expect(row.position).toBeNull();
  });

  it('maps all string fields correctly', () => {
    const [first] = parseResultsCsv(sample);
    expect(first.firstName).toBe('Luke');
    expect(first.lastName).toBe('Minns');
    expect(first.club).toBe('blackpool');
    expect(first.ageCategory).toBe('V35');
    expect(first.sex).toBe('M');
    expect(first.time).toBe('19:35');
  });

  it('handles Windows line endings (CRLF)', () => {
    const crlf = sample.replace(/\n/g, '\r\n');
    expect(parseResultsCsv(crlf)).toHaveLength(3);
  });

  it('returns empty array for header-only CSV', () => {
    expect(parseResultsCsv('position,ic_position,first_name,last_name,club,age_category,sex,time')).toHaveLength(0);
  });

  it('returns empty array for empty string', () => {
    expect(parseResultsCsv('')).toHaveLength(0);
  });

  it('parses raceNumber as a number when present', () => {
    const csv = 'position,ic_position,race_number,first_name,last_name,club,age_category,sex,time\n1,1,42,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBe(42);
  });

  it('parses raceNumber as null when the column is empty', () => {
    const csv = 'position,ic_position,race_number,first_name,last_name,club,age_category,sex,time\n1,1,,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBeNull();
  });

  it('parses raceNumber as null when the column is absent (old CSV format)', () => {
    const csv = 'position,ic_position,first_name,last_name,club,age_category,sex,time\n1,1,Luke,Minns,blackpool,V35,M,19:35';
    const [row] = parseResultsCsv(csv);
    expect(row.raceNumber).toBeNull();
  });

  it('parses seriesRunnerId when column is present', () => {
    const csv = [
      'position,ic_position,first_name,last_name,club,age_category,sex,time,series_runner_id',
      '1,1,Luke,Minns,blackpool,V35,M,19:35,2',
      '11,,T.,Guest,Guest,SEN,M,21:44,',
    ].join('\n');
    const results = parseResultsCsv(csv);
    expect(results[0].seriesRunnerId).toBe(2);
    expect(results[1].seriesRunnerId).toBeNull();
  });

  it('returns seriesRunnerId as null when column is absent', () => {
    const results = parseResultsCsv(sample);
    results.forEach(r => expect(r.seriesRunnerId).toBeNull());
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

describe('pivotIndividualAwardsByCategory', () => {
  it('returns empty array for empty input', () => {
    expect(pivotIndividualAwardsByCategory([])).toEqual([]);
  });

  it('returns one category entry for a single year with one category', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'sen-m',
        name: 'Senior Men',
        sex: 'M' as const,
        awards: [
          { position: 1, name: 'A. Smith', clubName: 'Wesham' },
          { position: 2, name: 'B. Jones', clubName: 'Preston' },
        ],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('sen-m');
    expect(result[0].name).toBe('Senior Men');
    expect(result[0].sex).toBe('M');
    expect(result[0].rows).toHaveLength(1);
    expect(result[0].rows[0].year).toBe(2024);
    expect(result[0].rows[0].positions[1]).toEqual({ name: 'A. Smith', clubName: 'Wesham', runnerUrl: undefined });
    expect(result[0].rows[0].positions[2]).toEqual({ name: 'B. Jones', clubName: 'Preston', runnerUrl: undefined });
    expect(result[0].rows[0].positions[3]).toBeNull();
  });

  it('omits years that have no entry for a category', () => {
    const input = [
      {
        year: 2024,
        categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [{ position: 1, name: 'A', clubName: 'X' }] }],
      },
      {
        year: 2023,
        categories: [], // no sen-m this year
      },
      {
        year: 2022,
        categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [{ position: 1, name: 'B', clubName: 'Y' }] }],
      },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows).toHaveLength(2);
    expect(result[0].rows.map(r => r.year)).toEqual([2024, 2022]);
  });

  it('preserves the input year order (caller is responsible for sorting)', () => {
    const input = [
      { year: 2025, categories: [{ id: 'sen-f', name: 'Senior Women', sex: 'F' as const, awards: [{ position: 1, name: 'C', clubName: 'Z' }] }] },
      { year: 2024, categories: [{ id: 'sen-f', name: 'Senior Women', sex: 'F' as const, awards: [{ position: 1, name: 'D', clubName: 'W' }] }] },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].year).toBe(2025);
    expect(result[0].rows[1].year).toBe(2024);
  });

  it('returns null for positions not present in the data', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'v40-m', name: 'V40 Men', sex: 'M' as const,
        awards: [{ position: 1, name: 'E', clubName: 'Q' }],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].positions[2]).toBeNull();
    expect(result[0].rows[0].positions[3]).toBeNull();
  });

  it('propagates runnerUrl when present', () => {
    const input = [{
      year: 2024,
      categories: [{
        id: 'sen-m', name: 'Senior Men', sex: 'M' as const,
        awards: [{ position: 1, name: 'F', clubName: 'R', runnerUrl: '/runners/f-surname' }],
      }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].rows[0].positions[1]?.runnerUrl).toBe('/runners/f-surname');
  });

  it('collects all categories across all years', () => {
    const input = [
      { year: 2024, categories: [{ id: 'sen-m', name: 'Senior Men', sex: 'M' as const, awards: [] }] },
      { year: 2023, categories: [{ id: 'v40-f', name: 'V40 Women', sex: 'F' as const, awards: [] }] },
    ];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result).toHaveLength(2);
    expect(result.map(c => c.id)).toContain('sen-m');
    expect(result.map(c => c.id)).toContain('v40-f');
  });

  it('propagates null sex for overall categories', () => {
    const input = [{
      year: 2024,
      categories: [{ id: 'overall', name: 'Overall', sex: null, awards: [] }],
    }];
    const result = pivotIndividualAwardsByCategory(input);
    expect(result[0].sex).toBeNull();
  });
});
