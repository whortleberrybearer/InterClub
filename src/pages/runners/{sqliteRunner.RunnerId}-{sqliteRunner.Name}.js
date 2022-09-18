import * as React from 'react'
import { graphql, Link } from 'gatsby'
import Layout from '../../components/layout'
import Seo from '../../components/seo'
import { buildCategory } from '../../functions/category';
import RunnerResults from '../../components/runnerResults'

const RunnerPage = ({ data }) => {
  return (
    <Layout title={data.sqliteRunner.Name}>
      <p>Category: {buildCategory(data.sqliteRunner.Sex, data.sqliteRunner.AgeCategory)}</p>
      <p>Clubs: TODO: Need to get this working </p>
      {
        data.sqliteRunner.runnerClubs.map(club =>
          <p>{club.Name}</p>
        )
      }

      <RunnerResults results={data.sqliteRunner.runnerResults}></RunnerResults>
    </Layout>
  )
}

export const query = graphql`
  query ($id: String) {
    sqliteRunner(id: {eq: $id}) {
      RunnerId
      AgeCategory
      Name
      Sex
      runnerClubs {
        Name
      }
      runnerResults {
        EventId
        RaceName
        Distance
        Time
        StartDateTime(formatString: "DD/MM/YYYY")
        Year
        ShortName
      }
    }
  }
`

export const Head = ({ data }) => {
  // TODO: Try and return the club
  return (
    <Seo 
      title={data.sqliteRunner.Name} 
      description={`Runner details for ${data.sqliteRunner.Name}, Category: ${buildCategory(data.sqliteRunner.Sex, data.sqliteRunner.AgeCategory)}`} />
  )
}

export default RunnerPage