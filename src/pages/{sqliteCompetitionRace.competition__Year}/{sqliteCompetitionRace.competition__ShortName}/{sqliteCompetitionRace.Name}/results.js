import * as React from "react"
import { graphql, Link } from 'gatsby'
import RaceResults from "../../../../components/raceResults"
import Layout from "../../../../components/layout"
import Seo from "../../../../components/seo"

const RaceResultsPage = ({ data }) => (
  <Layout>     
    
    <h2>{data.sqliteCompetitionRace.Name} Results</h2>
    <p>Date: {data.sqliteCompetitionRace.StartDateTime}</p>
    <p>Distance: {data.sqliteCompetitionRace.Distance}</p>
    <p>Ascent: {data.sqliteCompetitionRace.Ascent}</p>
    
    <RaceResults results={data.sqliteCompetitionRace.raceResults}></RaceResults>
  </Layout>
)

export const query = graphql`
  query ($id: String) {
    sqliteCompetitionRace(id: {eq: $id}) {
      id
      Name
      StartDateTime(formatString: "DD/MM/YY")
      Distance
      Ascent
      ResultsAvailable
      TeamResultsAvailable
      raceResults {
        Number
        LastName
        FirstName
        Time
        AgeCategory
        ResultPosition
        Sex
        RunnerId
        RunnerName
        ClubName
        competitionCategoryResults {
          Points
          CompetitionCategoryId
        }
      }
      competition {
        competitionCategories {
          Name
          CompetitionCategoryId
        }
      }
    }
  }
`

export const Head = ({ data }) => <Seo title={`${data.sqliteCompetitionRace.Name} Results (${data.sqliteCompetitionRace.StartDateTime})`} />

export default RaceResultsPage
