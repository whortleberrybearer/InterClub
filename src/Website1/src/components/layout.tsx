import * as React from 'react'
import { Link, graphql, useStaticQuery } from 'gatsby'
import { ReactNode } from 'react';

interface MyProps {
    pageTitle: string;
    children?: ReactNode;
 }
 
const Layout: React.FC<MyProps> = ({ pageTitle, children }) => {
  const data = useStaticQuery(graphql`
    query {
      site {
        siteMetadata {
          title
        }
      }
    }
  `)
  
  return (
    <div>
      <nav>
        <ul>
          <li><Link to="/">Home</Link></li>
          <li><Link to="/about">About</Link></li>
        </ul>
      </nav>
      <main>
        <h1>{data.site.siteMetadata.title} - {pageTitle}</h1>
        {children}
      </main>
    </div>
  )
}

export default Layout