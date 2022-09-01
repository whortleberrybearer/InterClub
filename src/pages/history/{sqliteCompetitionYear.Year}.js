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

                  {race.ResultsAvailable && <span>Results</span>}
                  {race.TeamResultsAvailable && <span>Club Results</span>}
                </p>
              ))}
            </ul>
            <p>
              {node.StandingsAvailable && <span>Standings</span>}
              {node.TeamStandingsAvailable && <span>Club Standings</span>}
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
