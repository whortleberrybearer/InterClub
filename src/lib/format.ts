import type { Series } from './types';

const DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

export function formatRaceDate(date: string, time?: string): string {
  const [year, month, day] = date.split('-').map(Number);
  // Use local date constructor to avoid timezone shifts
  const d = new Date(year, month - 1, day);
  const dayName = DAYS[d.getDay()];
  const monthName = MONTHS[month - 1];
  const dateStr = `${dayName} ${day} ${monthName}`;
  return time ? `${dateStr} · ${time}` : dateStr;
}

/** Normalise any stored time to hh:mm:ss (zero-padded). */
export function formatTime(time: string | null | undefined): string {
  if (!time) return '–';
  const parts = time.trim().split(':');
  if (parts.length === 2) {
    const [mm, ss] = parts;
    return `00:${mm.padStart(2, '0')}:${ss.padStart(2, '0')}`;
  }
  if (parts.length === 3) {
    const [hh, mm, ss] = parts;
    return `${hh.padStart(2, '0')}:${mm.padStart(2, '0')}:${ss.padStart(2, '0')}`;
  }
  return time;
}

export function getSeriesLabel(series: Series): string {
  return series === 'road-gp' ? 'Road GP' : 'Fell Championship';
}

export function getSeriesLongLabel(series: Series): string {
  return series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
}
