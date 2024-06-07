import * as React from 'react'
import { graphql } from "gatsby"

const ResultsPage = ({data}) => {
  return (
    <main>
      <h1>{data.sqliteRaces.Name} Results</h1>
      <table>
                <thead>
                    <tr>
                    <th>Pos</th>
                    <th>Number</th>
                    <th>Name</th>
                    <th>Cat</th>
                    <th>Club</th>
                    <th>Time</th>
                    </tr>
                </thead>
                <tbody>
                    {data.allSqliteRaceResults.edges.map((edge) => (
                        <tr key={edge.node.id}>
                            <td>{edge.node.Position}</td>
                            <td>{edge.node.RunnerNumber}</td>
                            <td>{edge.node.Name} {edge.node.Surname}</td>
                            <td>{edge.node.Sex}{edge.node.Category}</td>
                            <td>{edge.node.Club}</td>
                            <td>{edge.node.Time}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
    </main>
  )
}

export const Head = () => <title>Results</title>

export const query = graphql`
  query Query($id: Int) {
    sqliteRaces(RaceId: {eq: $id}) {
      Name
    }
    allSqliteRaceResults(filter: {RaceId: {eq: $id}}, sort: {Position: ASC}) {
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
        }
      }
    }
  }`;

export default ResultsPage