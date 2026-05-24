// src/lib/search-render.ts
// Shared HTML-rendering utilities for SearchBox and the search results page.
import type { SearchRecord } from './search-client'

export type SectionGroup = {
  id: string
  label: string
  items: SearchRecord[]
  total: number
}

const SECTION_META: Record<string, { label: string }> = {
  runner:    { label: 'Runners' },
  race:      { label: 'Race Results' },
  standings: { label: 'Standings' },
  year:      { label: 'Archives' },
}

export function escHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
}

export function sectionId(type: SearchRecord['type']): string {
  return type === 'race-detail' || type === 'race-results' ? 'race' : type
}

export function groupResults(results: SearchRecord[]): SectionGroup[] {
  const map: Record<string, SearchRecord[]> = { runner: [], race: [], standings: [], year: [] }
  for (const r of results) {
    const id = sectionId(r.type)
    if (map[id]) map[id].push(r)
  }
  return Object.entries(map).map(([id, items]) => ({
    id,
    label: SECTION_META[id].label,
    items,
    total: items.length,
  }))
}

export function iconSvg(type: SearchRecord['type']): string {
  switch (type) {
    case 'runner':
      return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="4" r="2.2" stroke="currentColor" stroke-width="1.4"/><path d="M2.5 12c0-2.2 2-3.6 4.5-3.6S11.5 9.8 11.5 12" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
    case 'race-detail':
    case 'race-results':
      return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M2 11.5L4.5 8L7 10L11.5 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><circle cx="11.5" cy="4" r="1.5" fill="currentColor"/></svg>`
    case 'standings':
      return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M3.5 2.5h7v2.5a3.5 3.5 0 01-7 0V2.5z" stroke="currentColor" stroke-width="1.4"/><path d="M10.5 3.5h1.5v1a1.5 1.5 0 01-1.5 1.5M3.5 3.5H2v1a1.5 1.5 0 001.5 1.5" stroke="currentColor" stroke-width="1.4"/><path d="M5.5 11.5h3M7 8.5v3" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
    default: // year / archive
      return `<svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="5" stroke="currentColor" stroke-width="1.4"/><path d="M7 4.5V7l1.8 1.2" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>`
  }
}

export function badgeStyle(type: SearchRecord['type']): string {
  switch (type) {
    case 'runner':      return 'background:oklch(97% 0.04 60);color:oklch(72% 0.18 60)'
    case 'race-detail':
    case 'race-results': return 'background:var(--color-teal-bg);color:var(--color-teal)'
    case 'standings':   return 'background:oklch(95% 0.04 220);color:oklch(45% 0.12 220)'
    default:            return 'background:var(--color-canvas);color:var(--color-muted)'
  }
}

/** Render a result row. Pass `dense: true` for the compact dropdown variant. */
export function rowHtml(r: SearchRecord, highlight: (t: string) => string, dense = false): string {
  const py = dense ? 'py-[0.5625rem]' : 'py-[0.6875rem]'
  const labelSize = dense ? '13.5px' : '14.5px'
  return (
    `<a href="${escHtml(r.url)}" class="flex items-center gap-3 px-4 ${py} border-t border-line no-underline text-content transition-colors duration-100 hover:bg-canvas">` +
    `<span style="width:28px;height:28px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;border-radius:7px;${badgeStyle(r.type)}">` +
      iconSvg(r.type) +
    `</span>` +
    `<span style="flex:1;min-width:0">` +
      `<span style="display:block;font-size:${labelSize};font-weight:500;${dense ? '' : 'line-height:1.2;'}overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${highlight(r.label)}</span>` +
      (r.subtitle ? `<span style="display:block;font-size:11.5px;color:var(--color-muted);${dense ? '' : 'margin-top:1px;'}overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${escHtml(r.subtitle)}</span>` : '') +
    `</span>` +
    `<span style="color:var(--color-muted);flex-shrink:0;font-size:14px">›</span>` +
    `</a>`
  )
}
