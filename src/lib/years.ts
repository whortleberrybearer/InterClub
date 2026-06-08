export function extractYears(paths: string[]): number[] {
  // Path format: "../data/2026/road-gp/races.json" → split index 2 is the year
  const years = paths.map(p => parseInt(p.split('/')[2], 10)).filter(n => !Number.isNaN(n));
  return [...new Set(years)].sort((a, b) => b - a);
}
