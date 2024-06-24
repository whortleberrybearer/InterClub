import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findAndSortRunnerStandingsForCategory(runnerCategoryId, standings) {
  return standings
      .filter((s) => s.RunnerCategoryId === runnerCategoryId)
      .sort((a, b) => a.Position - b.Position);
}

function findRunnerStandingResult(raceId, standingResults) { 
  const runnerCategoryResult = standingResults.find((sr) => sr.RaceId === raceId);

  return runnerCategoryResult?.Points;
}


const YearPage = ({data}) => {
  const categoryOrder = [ "Open", "Male", "Female", "Male Vet 40", "Female Vet 40", "Male Vet 50", "Female Vet 50", "Male Vet 60", "Female Vet 60" ];
  const runnerCategories = data.allSqliteRunnerCategories.nodes.sort((a, b) => {
    return categoryOrder.indexOf(a.Category) - categoryOrder.indexOf(b.Category);
  });

  return (
    <Layout>
      <main className="container">
      <h1>{data.sqliteCompetitions.CompetitionType} Standings {data.sqliteCompetitions.Year}</h1>
      
      {runnerCategories.map((runnerCategory) => (
        <div key={runnerCategory.RunnerCategoryId}>
          <h2>{runnerCategory.Category}</h2>

          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Club</th>

                {data.allSqliteRaces.nodes.map((race) => (
                  <th key={race.RaceId}>{race.Name}</th>
                ))}

                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              {findAndSortRunnerStandingsForCategory(runnerCategory.RunnerCategoryId, data.allSqliteRunnerStandings.nodes).map((runnerStanding) => (
                <tr key={runnerStanding.RunnerStandingId}>
                  <td>{runnerStanding.Name} {runnerStanding.Surname}</td>
                  <td>{runnerStanding.Sex}{runnerStanding.AgeCategory}</td>
                  <td>{runnerStanding.ClubShortName}</td>

                  {data.allSqliteRaces.nodes.map((race) => (
                    <td key={`${runnerStanding.RunnerStandingId}-${race.RaceId}`}>
                      {findRunnerStandingResult(race.RaceId, runnerStanding.RunnerStandingResults)}
                    </td>
                  ))}

                  <td>{runnerStanding.Total}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  return (
    <>
      <title>{data.sqliteCompetitions.CompetitionType} Standings {data.sqliteCompetitions.Year}</title>
      <meta name="description" content={`${data.sqliteCompetitions.CompetitionType} standings. Year: ${data.sqliteCompetitions.Year}.`} />
    </>
  );
}

export const query = graphql`
  query Query($competitionId: Int) {
    sqliteCompetitions(CompetitionId: {eq: $competitionId}) {
      CompetitionId
      CompetitionType
      CompetitionTypeId
      Year
      YearId
    }
    allSqliteRunnerCategories(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        RunnerCategoryId
        CategoryId
        Category
      }
    }
    allSqliteRaces(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        RaceId
        Name
        StartDateTime
      }
    }
    allSqliteRunnerStandings(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        RunnerCategoryId
        CategoryId
        ClubId
        ClubShortName
        RunnerStandingId
        Position
        Name
        Surname
        Sex
        AgeCategory
        Total
        RunnerStandingResults {
          Points
          RaceId
          RunnerStandingResultId
        }
      }
    }
}`;

export default YearPage;