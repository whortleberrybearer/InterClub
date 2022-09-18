import * as React from 'react'
import { graphql, Link } from 'gatsby'
import CompetitionRaces from '../../components/competitionRaces';
import Layout from "../../components/layout"
import Seo from "../../components/seo"

const CompetitionYearPage = ({ data, pageContext }) =>  (
  <Layout title={`History ${pageContext.Year}`}>
      {
        data.allSqliteCompetition.nodes.map(node => (
          <>
            <h2>{node.Name}</h2>
            <CompetitionRaces competition={node}></CompetitionRaces>
          </>
        ))
      }
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
        ShortName
        competitionRaces {
          RaceId
          ResultsAvailable
          StartDateTime(formatString: "DD/MM/YY")
          TeamResultsAvailable
          Name
        }
      }
    }
  }
`

export const Head = ({ pageContext }) => <Seo title={`History ${pageContext.Year}`} />

export default CompetitionYearPage
