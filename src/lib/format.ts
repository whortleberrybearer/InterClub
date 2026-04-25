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
