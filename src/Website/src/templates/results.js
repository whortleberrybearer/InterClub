import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findClubCategoryResult(clubCategoryId, clubCategoryResults) { 
  const clubCategoryResult = 
    clubCategoryResults.find((ccr) => ccr.ClubCategoryId === clubCategoryId);

    return clubCategoryResult?.Position;
}

const ResultsPage = ({data}) => {
  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteRaces.Name} Results</h1>
        <p>{data.sqliteRaces.StartDateTime}</p>
        <table>
          <thead>
            <tr>
              <th>Number</th>
              <th>Pos</th>

              {data.allSqliteClubCategories.edges.map((clubCategory) => (
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
                  
                  {data.allSqliteClubCategories.edges.map((clubCategory) => (
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

export const Head = () => <title>Results</title>

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