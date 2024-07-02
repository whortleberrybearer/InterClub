import * as React from 'react'
import { graphql, Link } from "gatsby"
import Layout from '../organisms/layout'
const slugify = require('slugify')

const YearPage = ({data}) => {
  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteCompetitions.CompetitionType} {data.sqliteCompetitions.Year}</h1>

        {data.sqliteCompetitions.Races.length > 0 &&
          <div>
              <h3>Races</h3>
              <table>
                  <tbody>
                      {data.sqliteCompetitions.Races.map((race) => (
                          <tr>
                              <td>{race.StartDateTime}</td>
                              <td>{race.Name}</td>
                              <td>
                                  {race.NumberOfRaceResults && 
                                  <Link to={`${slugify(race.Name, { lower: true })}/results`}>Results</Link>}
                              </td>
                              <td>
                                  {race.NumberOfClubResults && 
                                  <Link to={`${slugify(race.Name, { lower: true })}/club-results`}>Club Results</Link>}
                              </td>
                          </tr>
                      ))}
                  </tbody>
                  <tfoot>
                      <tr>
                          <td colSpan={3}>
                              {data.sqliteCompetitions.NumberOfStandings &&    
                              <Link to={`standings`}>Standings</Link>}
                          </td>
                          <td>
                              {data.sqliteCompetitions.NumberOfClubStandings &&    
                              <Link to={`club-standings`}>Club Standings</Link>}
                          </td>
                      </tr>
                  </tfoot>
              </table>
          </div>
        }

        {data.sqliteCompetitions.ClubWinners.length > 0 &&
          <div>
              <h3>Club Winners</h3>
              <table>
                  <tbody>
                  {data.sqliteCompetitions.ClubWinners.map((clubWinner) => (
                      <tr key={clubWinner.ClubWinnerId}>
                          <td>{clubWinner.Category}</td>
                          <td>{clubWinner.ClubShortName}</td>
                      </tr> 
                  ))}
                  </tbody>
              </table>
          </div>
        }

        {data.sqliteCompetitions.RunnerWinners.length > 0 &&
          <div>
              <h3>Individual Winners</h3>
              <table>
                  <tbody>
                  {data.sqliteCompetitions.RunnerWinners.map((runnerWinner) => (
                      <tr key={runnerWinner.RunnerWinnerId}>
                          <td>{runnerWinner.Category}</td>
                          <td>{runnerWinner.Position}</td>
                          <td>{runnerWinner.Name} {runnerWinner.Surname}</td>
                          <td>{runnerWinner.ClubShortName}</td>
                      </tr> 
                  ))}
                  </tbody>
              </table>
          </div>
        }
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  return (
    <>
      <title>{data.sqliteCompetitions.CompetitionType} {data.sqliteCompetitions.Year}</title>
      <meta name="description" content={`Inter Club details ${data.sqliteCompetitions.CompetitionType} for ${data.sqliteCompetitions.Year}.`} />
    </>
  );
}

export const query = graphql`
  query Query($competitionId: Int) {
    sqliteCompetitions(CompetitionId: {eq: $competitionId}) {
      CompetitionId
      CompetitionType
      YearId
      Year
      NumberOfStandings
      NumberOfClubStandings
      Races {
        Name
        RaceId
        StartDateTime
        NumberOfClubResults
        NumberOfRaceResults
      }
      ClubWinners {
        Category
        CategoryId
        ClubCategoryId
        ClubId
        ClubShortName
        ClubWinnerId
      }
      RunnerWinners {
        Category
        CategoryId
        RunnerCategoryId
        ClubId
        ClubShortName
        RunnerWinnerId
        Position
        Name
        Surname
      }
    }
  }`;

export default YearPage;