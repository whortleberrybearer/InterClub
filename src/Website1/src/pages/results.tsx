import * as React from "react"
import { Link, HeadFC, PageProps, useStaticQuery, graphql } from "gatsby"
import Layout from "../components/layout"

const ResultsPage: React.FC<PageProps> = () => {
  const data = useStaticQuery(graphql`
    query {
      allRaceResultsYaml {
        nodes {
          Category
          Club
          ClubCategoryResults {
            Category
            Position
          }
          Name
          Position
          RunnerNumber
          Sex
          Surname
          Time
        }
      }
    }
  `);

    return (
        <Layout pageTitle="Results Page Again">
            <table>
                <thead>
                    <th>Pos</th>
                    <th>Number</th>
                    <th>Name</th>
                    <th>Cat</th>
                    <th>Club</th>
                    <th>Time</th>
                </thead>
                <tbody>
                    {data.allRaceResultsYaml.nodes.map((raceResult: any) => (
                        <tr>
                            <td>{raceResult.Position}</td>
                            <td>{raceResult.RunnerNumber}</td>
                            <td>{raceResult.Name} {raceResult.Surname}</td>
                            <td>{raceResult.Sex}{raceResult.Category}</td>
                            <td>{raceResult.Club}</td>
                            <td>{raceResult.Time}</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </Layout>
    )
  }
  
  export default ResultsPage
  
  export const Head: HeadFC = () => <title>Results</title>
  