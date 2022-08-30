import * as React from 'react'
import { graphql, Link } from 'gatsby'

import Layout from '../../components/layout'
import Seo from '../../components/seo'

const RunnersPage = ({ data }) => {
  return (
    <Layout pageTitle="My Blog Posts">
      <p>My cool posts will go in here</p>
      <ul>
      {
        data.allSqliteRunner.nodes.map(node => (
          <li key={node.RunnerId}>
            <Link to={`/runners/${node.RunnerId}`}>
              {node.FirstName} {node.LastName}
            </Link>
          </li>
        ))
      }
      </ul>
    </Layout>
  )
}

export const query = graphql`
  query {
    allSqliteRunner {
      nodes {
        FirstName
        LastName
        RunnerId
      }
    }
  }
  
`

export const Head = () => <Seo title="My Blog Posts" />

export default RunnersPage