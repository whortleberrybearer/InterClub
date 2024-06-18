import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findClubCategoryResult(clubCategoryId, clubCategoryResults) { 
  const clubCategoryResult = 
    clubCategoryResults.find((ccr) => ccr.ClubCategoryId === clubCategoryId);

    return clubCategoryResult?.Position;
}

const ResultsPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const clubCategories = data.allSqliteClubCategories.edges.sort((a, b) => {
    return categoryOrder.indexOf(a.node.Category) - categoryOrder.indexOf(b.node.Category);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteRaces.Name} Results</h1>
        <p>{new Date(data.sqliteRaces.StartDateTime).toLocaleDateString()}</p>
        <table>
          <thead>
            <tr>
              <th>Number</th>
              <th>Pos</th>

              {clubCategories.map((clubCategory) => (
                <th key={clubCategory.node.ClubCategoryId}>{clubCategory.node.Category}</th>
              ))}

              <th>Name</th>
              <th>Cat</th>
              <th>Club</th>
              <th>Time</th>
            </tr>
          </thead>
          <tbody>
              {data.allSqliteRaceResults.edges.map((raceResult) => (
                <tr key={raceResult.node.RaceResultId}>
                  <td>{raceResult.node.RunnerNumber}</td>
                  <td>{raceResult.node.Position}</td>
                  
                  {clubCategories.map((clubCategory) => (
                    <td key={`${raceResult.node.RaceResultId}-${clubCategory.node.ClubCategoryId}`}>
                      {findClubCategoryResult(clubCategory.node.ClubCategoryId, raceResult.node.ClubCategoryResults)}
                    </td>
                  ))}

                  <td>{raceResult.node.Name} {raceResult.node.Surname}</td>
                  <td>{raceResult.node.Sex}{raceResult.node.Category}</td>
                  <td>{raceResult.node.Club}</td>
                  <td>{raceResult.node.Time}</td>
                </tr>
              ))}
          </tbody>
        </table>
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  const raceDate = new Date(data.sqliteRaces.StartDateTime);

  return (
    <>
      <title>{data.sqliteRaces.Name} Results ({raceDate.toLocaleDateString()})</title>
      <meta name="description" content={`${data.sqliteRaces.Name} results. Race Date: ${raceDate.toLocaleDateString()}.`} />
    </>
  );
}

export const query = graphql`
  query Query($raceId: Int, $competitionId: Int) {
    sqliteRaces(RaceId: {eq: $raceId}) {
      Name
      StartDateTime
    }
    allSqliteRaceResults(filter: {RaceId: {eq: $raceId}}, sort: {Position: ASC}) {
      edges {
        node {
          RaceResultId
          Position
          RunnerNumber
          Name
          Surname
          Sex
          Category
          Club
          Time
          ClubCategoryResults {
            Position
            ClubCategoryId
          }
        }
      }
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

export default ResultsPage