import type { APIRoute } from 'astro'
import { getGlobalRunners, runnerSlug, resolveClubName } from '../lib/runners'
import { getAvailableYears, getRaces, getCurrentYear } from '../lib/data'
import { hasResults, hasTeamStandings, hasIndividualStandings } from '../lib/results'
import { siteUrl } from '../lib/url'
import type { SearchRecord } from '../lib/search-client'

export const GET: APIRoute = () => {
  const records: SearchRecord[] = []
  const currentYear = getCurrentYear()
  const allRoadYears = getAvailableYears('road-gp')
  const allFellYears = getAvailableYears('fell')

  // Runners
  for (const runner of getGlobalRunners()) {
    const details = [runner.sex, runner.ageCategory].filter(Boolean).join(' ')
    records.push({
      type: 'runner',
      label: `${runner.firstName} ${runner.lastName}`,
      url: siteUrl(`/runners/${runnerSlug(runner)}/`),
      subtitle: details ? `${resolveClubName(runner.club)} · ${details}` : resolveClubName(runner.club),
    })
  }

  // Current year race detail pages (road-gp only — fell has no detail pages)
  for (const race of getRaces(currentYear, 'road-gp')) {
    records.push({
      type: 'race-detail',
      label: race.name,
      url: siteUrl(`/road-gp/${currentYear}/${race.id}/`),
    })
  }

  // Race results — all years, road-gp
  for (const year of allRoadYears) {
    for (const race of getRaces(year, 'road-gp')) {
      if (hasResults(year, 'road-gp', race.id)) {
        records.push({
          type: 'race-results',
          label: `${race.name} Results ${year}`,
          url: siteUrl(`/road-gp/${year}/${race.id}/results/`),
        })
      }
    }
  }

  // Race results — all years, fell
  for (const year of allFellYears) {
    for (const race of getRaces(year, 'fell')) {
      if (hasResults(year, 'fell', race.id)) {
        records.push({
          type: 'race-results',
          label: `${race.name} Results ${year}`,
          url: siteUrl(`/fell/${year}/${race.id}/results/`),
        })
      }
    }
  }

  // Year archive pages — past years only
  for (const year of allRoadYears.filter(y => y < currentYear)) {
    records.push({
      type: 'year',
      label: `Road GP ${year}`,
      url: siteUrl(`/road-gp/${year}/`),
    })
  }
  for (const year of allFellYears.filter(y => y < currentYear)) {
    records.push({
      type: 'year',
      label: `Fell Championship ${year}`,
      url: siteUrl(`/fell/${year}/`),
    })
  }

  // Standings pages (any year, both series)
  for (const year of allRoadYears) {
    if (hasIndividualStandings(year, 'road-gp')) {
      records.push({
        type: 'standings',
        label: `Road GP ${year} Individual Standings`,
        url: siteUrl(`/road-gp/${year}/individual-standings/`),
      })
    }
    if (hasTeamStandings(year, 'road-gp')) {
      records.push({
        type: 'standings',
        label: `Road GP ${year} Team Standings`,
        url: siteUrl(`/road-gp/${year}/team-standings/`),
      })
    }
  }
  for (const year of allFellYears) {
    if (hasIndividualStandings(year, 'fell')) {
      records.push({
        type: 'standings',
        label: `Fell Championship ${year} Individual Standings`,
        url: siteUrl(`/fell/${year}/individual-standings/`),
      })
    }
    if (hasTeamStandings(year, 'fell')) {
      records.push({
        type: 'standings',
        label: `Fell Championship ${year} Team Standings`,
        url: siteUrl(`/fell/${year}/team-standings/`),
      })
    }
  }

  return new Response(JSON.stringify(records), {
    headers: { 'Content-Type': 'application/json' },
  })
}
