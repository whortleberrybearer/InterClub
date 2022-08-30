import * as React from 'react'
import { graphql } from 'gatsby'
import Layout from '../../components/layout'
import Seo from '../../components/seo'

const BlogPost = ({ data, children }) => {
  return (
    <Layout pageTitle={data.sqliteRunner.FirstName}>
      <p>{data.sqliteRunner.FirstName} {data.sqliteRunner.LastName}</p>
      {children}
    </Layout>
  )
}

export const query = graphql`
  query ($id: String) {
    sqliteRunner(id: {eq: $id}) {
      FirstName
      LastName
      id
      Sex
      RunnerId
      AgeCategory
    }
  }
`

export const Head = ({ data }) => <Seo title={data.sqliteRunner.FirstName} />

export default BlogPost