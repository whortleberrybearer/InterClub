import * as React from "react"
import { graphql, Link } from 'gatsby'
import slugify from '@sindresorhus/slugify';

import Layout from "../../../../components/layout"
import Seo from "../../../../components/seo"

const SecondPage = ({ data }) => (
  <Layout>     
    
    <h1>{data.sqliteCompetitionRace.Name} Results</h1>
    <p>{data.sqliteCompetitionRace.StartDateTime}</p>
    <p>{data.sqliteCompetitionRace.Distance}</p>
    <p>{data.sqliteCompetitionRace.Ascent}</p>
    
    <ul>
      {
        data.sqliteCompetitionRace.raceResults.map(result =>
          <p>{result.ResultPosition} <Link to={`/runners/${result.RunnerId}-${slugify(result.RunnerName ?? '')}`}>{result.FirstName} {result.LastName}</Link> {result.ClubName} {result.Time}</p>
          )
      }
    </ul>
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

export const Head = ({ data }) => <Seo title={`${data.sqliteCompetitionRace.Name} Results`} />

export default SecondPage
