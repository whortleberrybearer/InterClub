// Step 1: Import React
import * as React from 'react'

import Layout from '../components/layout'
import Seo from "../components/seo"

// Step 2: Define your component
const HistoryPage = () => {
  return (
    <Layout>
      <h1>Welcome to my Gatsby site!</h1>
      <p>I'm making this by following the Gatsby Tutorial.</p>
    </Layout>
  )
}

export const Head = () => <Seo title="History" />

// Step 3: Export your component
export default HistoryPage