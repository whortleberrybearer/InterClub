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

export function formatRaceDateShort(date: string): string {
  const [, month, day] = date.split('-').map(Number);
  return `${String(day).padStart(2, '0')}/${String(month).padStart(2, '0')}`;
}

/** Format a stored time as h:mm:ss or m:ss (no leading zeros on the first component). */
export function formatTime(time: string | null | undefined): string {
  if (!time) return '–';
  const parts = time.trim().split(':');
  let h = 0, m = 0, s = 0;
  if (parts.length === 2) {
    m = parseInt(parts[0], 10);
    s = parseInt(parts[1], 10);
  } else if (parts.length === 3) {
    h = parseInt(parts[0], 10);
    m = parseInt(parts[1], 10);
    s = parseInt(parts[2], 10);
  } else {
    return time;
  }
  if (isNaN(h) || isNaN(m) || isNaN(s)) return time;
  const total = h * 3600 + m * 60 + s;
  const hh = Math.floor(total / 3600);
  const mm = Math.floor((total % 3600) / 60);
  const ss = total % 60;
  if (hh > 0) {
    return `${hh}:${mm.toString().padStart(2, '0')}:${ss.toString().padStart(2, '0')}`;
  }
  return `${mm}:${ss.toString().padStart(2, '0')}`;
}

export function positionLabel(pos: number): string {
  const mod10 = pos % 10, mod100 = pos % 100;
  const suffix =
    mod10 === 1 && mod100 !== 11 ? 'st' :
    mod10 === 2 && mod100 !== 12 ? 'nd' :
    mod10 === 3 && mod100 !== 13 ? 'rd' : 'th';
  return `${pos}${suffix}`;
}

export function getSeriesLabel(series: Series): string {
  return series === 'road-gp' ? 'Road GP' : 'Fell Championship';
}

export function getSeriesLongLabel(series: Series): string {
  return series === 'road-gp' ? 'Road Grand Prix' : 'Fell Championship';
}
