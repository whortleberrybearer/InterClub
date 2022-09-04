import * as React from 'react'
import { graphql, Link } from 'gatsby'
import Layout from '../../components/layout'
import Seo from '../../components/seo'
import slugify from '@sindresorhus/slugify';

const BlogPost = ({ data, children }) => {
  return (
    <Layout pageTitle={data.sqliteRunner.Name}>
      <p>{data.sqliteRunner.Name}</p>
      <p>{data.sqliteRunner.Sex}</p>
      <p>{data.sqliteRunner.AgeCategory}</p>
      {
        data.sqliteRunner.runnerClubs.map(club =>
          <p>{club.Name}</p>
        )
      }

      <ul>
      {
        data.sqliteRunner.runnerResults.map(result =>
          <p>{result.StartDateTime} <Link to={`/${result.Year}/${slugify(result.ShortName)}/${slugify(result.RaceName)}/results`}>{result.RaceName}</Link> {result.Distance} {result.Time}</p>
        )
      }
      </ul>
      {children}
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
        RaceName
        Distance
        Time
        StartDateTime(formatString: "DD/MM/YY")
        Year
        ShortName
      }
    }
  }
`

export const Head = ({ data }) => <Seo title={data.sqliteRunner.Name} />

export default BlogPost