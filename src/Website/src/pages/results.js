import * as React from 'react'
import { useStaticQuery, graphql } from "gatsby"

const ResultsPage = ({data}) => {
  return (
    <main>
      <h1>These are the results again</h1>
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
                    {data.allRaceResultsYaml.edges.map((edge) => (
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
query MyQuery($id: String) {
  allRaceResultsYaml(filter: {parent: {id: {eq: $id}}}) {
    edges {
      node {
        id
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
          Category
        }
        parent {
          id
        }
      }
    }
  }
}
`

export default ResultsPage