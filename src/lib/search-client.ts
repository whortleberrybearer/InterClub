// src/lib/search-client.ts
import Fuse from 'fuse.js'

export type SearchRecord = {
  type: 'runner' | 'race-detail' | 'race-results' | 'year' | 'standings'
  label: string
  url: string
  subtitle?: string
}

export function createFuse(records: SearchRecord[]): Fuse<SearchRecord> {
  return new Fuse(records, { keys: ['label'], threshold: 0.3 })
}

export function runSearch(fuse: Fuse<SearchRecord>, query: string, limit = 50): SearchRecord[] {
  if (query.trim().length < 3) return []
  return fuse.search(query).slice(0, limit).map(r => r.item)
}

export async function loadIndex(): Promise<SearchRecord[]> {
  const res = await fetch(`${import.meta.env.BASE_URL}search-index.json`)
  return res.json()
}

export function typeLabel(type: SearchRecord['type']): string {
  const labels: Record<SearchRecord['type'], string> = {
    'runner': 'Runner',
    'race-detail': 'Race',
    'race-results': 'Results',
    'year': 'Archive',
    'standings': 'Standings',
  }
  return labels[type]
}
