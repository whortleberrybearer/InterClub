/**
 * Layout component that queries for data
 * with Gatsby's useStaticQuery component
 *
 * See: https://www.gatsbyjs.com/docs/use-static-query/
 */

import * as React from "react"
import PropTypes from "prop-types"
import { useStaticQuery, graphql } from "gatsby"
import { Container } from "react-bootstrap"
import Header from "./header"
import "./layout.css"
import PageTitle from '../components/pageTitle';

const Layout = ({ title, children }) => {
  const data = useStaticQuery(graphql`
    query SiteTitleQuery {
      site {
        siteMetadata {
          title
        }
      }
    }
  `)

  return (
    <>
      <div id="wrapper">
        <Header siteTitle={data.site.siteMetadata?.title || `Title`} />
        <PageTitle title={title}></PageTitle>
        <main className="section pt-0">
          <Container>
            <div class="article-format p-4 p-lg-5 shadow-sm rounded">
              {children}
            </div>
          </Container>
        </main>
        <footer
            style={{
              marginTop: `var(--space-5)`,
              fontSize: `var(--font-sm)`,
            }}
          >
            © {new Date().getFullYear()} &middot; Built with
            {` `}
            <a href="https://www.gatsbyjs.com">Gatsby</a>
          </footer>
      </div>
    </>
  )
}

Layout.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Layout
