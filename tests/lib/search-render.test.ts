import { describe, it, expect } from 'vitest'
import {
  escHtml,
  sectionId,
  groupResults,
  badgeStyle,
  rowHtml,
} from '../../src/lib/search-render'
import type { SearchRecord } from '../../src/lib/search-client'

// ---- escHtml ----------------------------------------------------------------

describe('escHtml', () => {
  it('escapes ampersands', () => {
    expect(escHtml('A & B')).toBe('A &amp; B')
  })

  it('escapes less-than', () => {
    expect(escHtml('<script>')).toBe('&lt;script&gt;')
  })

  it('escapes greater-than', () => {
    expect(escHtml('1 > 0')).toBe('1 &gt; 0')
  })

  it('escapes double quotes', () => {
    expect(escHtml('"hello"')).toBe('&quot;hello&quot;')
  })

  it('leaves safe characters untouched', () => {
    expect(escHtml('Hello World 123')).toBe('Hello World 123')
  })

  it('escapes multiple special chars in one string', () => {
    expect(escHtml('<a href="x&y">')).toBe('&lt;a href=&quot;x&amp;y&quot;&gt;')
  })
})

// ---- sectionId --------------------------------------------------------------

describe('sectionId', () => {
  it('maps race-detail to race', () => {
    expect(sectionId('race-detail')).toBe('race')
  })

  it('maps race-results to race', () => {
    expect(sectionId('race-results')).toBe('race')
  })

  it('passes runner through unchanged', () => {
    expect(sectionId('runner')).toBe('runner')
  })

  it('passes standings through unchanged', () => {
    expect(sectionId('standings')).toBe('standings')
  })

  it('passes year through unchanged', () => {
    expect(sectionId('year')).toBe('year')
  })
})

// ---- groupResults -----------------------------------------------------------

describe('groupResults', () => {
  const r = (type: SearchRecord['type'], label = 'x'): SearchRecord => ({
    type, label, url: '/x/',
  })

  it('returns four sections in order: runner, race, standings, year', () => {
    const groups = groupResults([])
    expect(groups.map(g => g.id)).toEqual(['runner', 'race', 'standings', 'year'])
  })

  it('places a runner record in the runner section', () => {
    const groups = groupResults([r('runner', 'Alice')])
    const runners = groups.find(g => g.id === 'runner')!
    expect(runners.items).toHaveLength(1)
    expect(runners.items[0].label).toBe('Alice')
  })

  it('places race-results and race-detail both in the race section', () => {
    const groups = groupResults([r('race-results'), r('race-detail')])
    const race = groups.find(g => g.id === 'race')!
    expect(race.items).toHaveLength(2)
  })

  it('reports total equal to item count', () => {
    const groups = groupResults([r('runner'), r('runner'), r('standings')])
    expect(groups.find(g => g.id === 'runner')!.total).toBe(2)
    expect(groups.find(g => g.id === 'standings')!.total).toBe(1)
  })

  it('section labels come from the metadata map', () => {
    const groups = groupResults([])
    const labels = groups.map(g => g.label)
    expect(labels).toEqual(['Runners', 'Race Results', 'Standings', 'Archives'])
  })
})

// ---- badgeStyle -------------------------------------------------------------

describe('badgeStyle', () => {
  it('returns a non-empty string for each type', () => {
    const types: SearchRecord['type'][] = ['runner', 'race-results', 'race-detail', 'standings', 'year']
    for (const t of types) {
      expect(badgeStyle(t).length).toBeGreaterThan(0)
    }
  })

  it('returns the same style for race-results and race-detail', () => {
    expect(badgeStyle('race-results')).toBe(badgeStyle('race-detail'))
  })

  it('returns distinct styles for runner, race, standings, year', () => {
    const styles = new Set([
      badgeStyle('runner'),
      badgeStyle('race-results'),
      badgeStyle('standings'),
      badgeStyle('year'),
    ])
    expect(styles.size).toBe(4)
  })
})

// ---- rowHtml ----------------------------------------------------------------

describe('rowHtml', () => {
  const record: SearchRecord = {
    type: 'runner',
    label: 'Luke Minns',
    url: '/runners/1-luke-minns/',
    subtitle: 'Blackpool Wyre & Fylde AC',
  }
  const ident = (t: string) => t

  it('renders an anchor tag with the record URL', () => {
    const html = rowHtml(record, ident)
    expect(html).toContain('href="/runners/1-luke-minns/"')
  })

  it('renders the label text', () => {
    const html = rowHtml(record, ident)
    expect(html).toContain('Luke Minns')
  })

  it('renders the subtitle when present', () => {
    const html = rowHtml(record, ident)
    expect(html).toContain('Blackpool Wyre &amp; Fylde AC')
  })

  it('omits subtitle span when subtitle is absent', () => {
    const noSub: SearchRecord = { type: 'year', label: 'Road GP 2024', url: '/road-gp/2024/' }
    const html = rowHtml(noSub, ident)
    expect(html).not.toContain('font-size:11.5px')
  })

  it('escapes special chars in the URL', () => {
    const xss: SearchRecord = { type: 'runner', label: 'x', url: '/path?a=1&b=2' }
    const html = rowHtml(xss, ident)
    expect(html).toContain('href="/path?a=1&amp;b=2"')
  })

  it('uses a smaller py class in dense mode', () => {
    const normal = rowHtml(record, ident, false)
    const dense  = rowHtml(record, ident, true)
    expect(dense).not.toBe(normal)
    expect(dense).toContain('py-[0.5625rem]')
    expect(normal).toContain('py-[0.6875rem]')
  })

  it('applies the highlight function to the label', () => {
    const bolded = rowHtml(record, t => `<b>${t}</b>`)
    expect(bolded).toContain('<b>Luke Minns</b>')
  })
})
