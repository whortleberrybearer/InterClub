import { describe, it, expect } from 'vitest'
import { createFuse, runSearch, type SearchRecord } from '../src/lib/search-client'

const records: SearchRecord[] = [
  { type: 'runner', label: 'Steve Smith', url: '/runners/1-steve-smith/' },
  { type: 'runner', label: 'Sarah Jones', url: '/runners/2-sarah-jones/' },
  { type: 'runner', label: 'Alan Smithson', url: '/runners/3-alan-smithson/' },
  { type: 'race-results', label: 'Preston Inter Club Results 2012', url: '/road-gp/2012/preston/results/' },
  { type: 'year', label: 'Road GP 2012', url: '/road-gp/2012/' },
]

describe('runSearch', () => {
  const fuse = createFuse(records)

  it('returns empty array for query shorter than 3 characters', () => {
    expect(runSearch(fuse, '')).toEqual([])
    expect(runSearch(fuse, 'st')).toEqual([])
    expect(runSearch(fuse, '  ')).toEqual([])
  })

  it('finds a runner by surname', () => {
    const results = runSearch(fuse, 'smith')
    const labels = results.map(r => r.label)
    expect(labels).toContain('Steve Smith')
  })

  it('finds a race by partial name', () => {
    const results = runSearch(fuse, 'preston')
    const labels = results.map(r => r.label)
    expect(labels.some(l => l.includes('Preston'))).toBe(true)
  })

  it('respects the limit', () => {
    const manyRecords: SearchRecord[] = Array.from({ length: 100 }, (_, i) => ({
      type: 'runner' as const,
      label: `Runner ${String(i).padStart(3, '0')} Smith`,
      url: `/runners/${i}/`,
    }))
    const bigFuse = createFuse(manyRecords)
    const results = runSearch(bigFuse, 'smith', 10)
    expect(results.length).toBeLessThanOrEqual(10)
  })

  it('returns at most 50 results by default', () => {
    const manyRecords: SearchRecord[] = Array.from({ length: 200 }, (_, i) => ({
      type: 'runner' as const,
      label: `Runner ${String(i).padStart(3, '0')} Smith`,
      url: `/runners/${i}/`,
    }))
    const bigFuse = createFuse(manyRecords)
    expect(runSearch(bigFuse, 'smith').length).toBeLessThanOrEqual(50)
  })
})
