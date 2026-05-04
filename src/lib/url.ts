const BASE = import.meta.env.BASE_URL.replace(/\/$/, '');

export function siteUrl(path: string): string {
  return `${BASE}${path}`;
}
