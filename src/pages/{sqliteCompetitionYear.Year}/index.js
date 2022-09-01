import * as React from 'react'
import { graphql, Link } from 'gatsby'

import Layout from "../../components/layout"
import Seo from "../../components/seo"

const CompetitionYearPage = ({ data, pageContext }) =>  (
  <Layout>
    <h1>The year: {pageContext.Year}</h1>
    <p>Welcome to page 2</p>
    <ul>
      {
        data.allSqliteCompetition.nodes.map(node => (
          <li key={node.CompetitionId}>
            {node.CompetitionId} {node.CompetitionTypeId} {node.Name}

            <ul>
              {node.competitionRaces.map(race => (
                <p>
                  {race.StartDateTime} {race.Name}

                  {race.ResultsAvailable && <Link to={`${slugify(race.Name)}/results`}>Results</Link>}
                  {race.TeamResultsAvailable && <Link to={`${race.Name}/clubresults`}>Club Results</Link>}
                </p>
              ))}
            </ul>
            <p>
              {node.StandingsAvailable && <Link to={`/${pageContext.Year}/standings`}>Standings</Link>}
              {node.TeamStandingsAvailable && <Link to={`/${pageContext.Year}/clubstandings`}>Club Standings</Link>}
            </p>
          </li>
        ))
      }
      </ul>
    <Link to="/">Go back to the homepage</Link>
  </Layout>
)

export const query = graphql`
  query ($Year: Int) {
    allSqliteCompetition(
      filter: {Year: {eq: $Year}}
      sort: {order: ASC, fields: [CompetitionTypeId, competitionRaces___competition___competitionRaces___StartDateTime]}
    ) {
      nodes {
        Year
        TeamStandingsAvailable
        StandingsAvailable
        CompetitionTypeId
        CompetitionId
        Name
        competitionRaces {
          RaceId
          ResultsAvailable
          StartDateTime(formatString: "DD MMM")
          TeamResultsAvailable
          Name
        }
      }
    }
  }
`

export const Head = () => <Seo title="Competion year" />

export default CompetitionYearPage
