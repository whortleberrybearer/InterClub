import * as React from "react"
import { graphql, Link } from 'gatsby'
import CompetitionStandingsTable from "../../../components/competitionStandingsTable"
import Layout from "../../../components/layout"
import Seo from "../../../components/seo"

const CompetitionStandingsPage = ({ data, id, Year, context, pageContext }) => (
  <Layout title={`${data.sqliteCompetition.Name} Standings`}>
    <CompetitionStandingsTable
      standings={data.sqliteCompetition.competitionRunners}
      races={data.sqliteCompetition.competitionRaces}></CompetitionStandingsTable>
  </Layout>
)

export const query = graphql`
  query ($id: String) {
    sqliteCompetition(id: {eq: $id}) {
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
        competition {
          ShortName
          Year
        }
      }
      competitionRunnerCategories {
        CompetitionRunnerCategoryId
        Sex
      }
      competitionRunners {
        FirstName
        LastName
        AgeCategory
        Points
        Number
        Name
        Position
        Qualified
        Sex
        RunnerId,
        RunnerName
        competitionRunnerResults {
          Points
          RaceId
          Scoring
        }
      }
    }
  }
`

export const Head = ({ data }) => <Seo title={`${data.sqliteCompetition.Name} Standings ${data.sqliteCompetition.Year}`} />

export default CompetitionStandingsPage
