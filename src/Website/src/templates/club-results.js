import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'
  
const ClubResultsPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const clubCategories = data.allSqliteClubCategories.edges.sort((a, b) => {
    return categoryOrder.indexOf(a.node.Category) - categoryOrder.indexOf(b.node.Category);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteRaces.Name} Club Results</h1>
        <p>{new Date(data.sqliteRaces.StartDateTime).toLocaleDateString()}</p>

        {clubCategories.map((clubCategory) => (
            <h2>{clubCategory.node.Category}</h2>
        ))}
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  const raceDate = new Date(data.sqliteRaces.StartDateTime);

  return (
    <>
      <title>{data.sqliteRaces.Name} Club Results ({raceDate.toLocaleDateString()})</title>
      <meta name="description" content={`${data.sqliteRaces.Name} club results. Race Date: ${raceDate.toLocaleDateString()}.`} />
    </>
  );
}

export const query = graphql`
  query Query($raceId: Int, $competitionId: Int) {
    sqliteRaces(RaceId: {eq: $raceId}) {
      Name
      StartDateTime
    }
    allSqliteClubCategories(filter: {CompetitionId: {eq: $competitionId}}) {
      edges {
        node {
          Category
          ClubCategoryId
        }
      }
    }
}`;

export default ClubResultsPage