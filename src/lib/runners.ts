import type { GlobalRunner, Series, SeriesRunner } from './types';

export function runnerSlug(runner: GlobalRunner): string {
  const name = `${runner.firstName} ${runner.lastName}`
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
  return `${runner.id}-${name}`;
}

export function parseSeriesRunnerPath(path: string): { year: number; series: Series } | null {
  const match = path.match(/\/data\/(\d+)\/(road-gp|fell)\/runners\.json$/);
  if (!match) return null;
  return { year: parseInt(match[1], 10), series: match[2] as Series };
}
