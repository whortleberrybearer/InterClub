import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findAndSortClubStandingsForCategory(clubCategoryId, clubStandings) {
  return clubStandings
      .filter((cs) => cs.ClubCategoryId === clubCategoryId)
      .sort((a, b) => a.Position - b.Position);
}

const ClubStandingsPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const clubCategories = data.allSqliteClubCategories.nodes.sort((a, b) => {
    return categoryOrder.indexOf(a.Category) - categoryOrder.indexOf(b.Category);
  });

  return (
    <Layout>
      <main className="container">
      <h1>{data.sqliteCompetitions.CompetitionType} Club Standings {data.sqliteCompetitions.Year}</h1>
      
      {clubCategories.map((clubCategory) => (
        <div key={clubCategory.ClubCategoryId}>
          <h2>{clubCategory.Category}</h2>

          <table>
            <thead>
              <tr>
                <th>Club</th>

                {data.allSqliteRaces.nodes.map((race) => (
                  <th key={race.RaceId}>{race.Name}</th>
                ))}

                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              {findAndSortClubStandingsForCategory(clubCategory.ClubCategoryId, data.allSqliteClubStandings.nodes).map((clubStanding) => (
                <tr key={clubStanding.ClubStandingId}>
                  <td>{clubStanding.ClubShortName}</td>
                  <td>{clubStanding.Total}</td>
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
      <title>{data.sqliteCompetitions.CompetitionType} Club Standings {data.sqliteCompetitions.Year}</title>
      <meta name="description" content={`${data.sqliteCompetitions.CompetitionType} club standings. Year: ${data.sqliteCompetitions.Year}.`} />
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
    allSqliteClubCategories(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        ClubCategoryId
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
    allSqliteClubStandings(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        ClubCategoryId
        CategoryId
        ClubId
        ClubShortName
        ClubStandingId
        Position
        Total
      }
    }
}`;

export default ClubStandingsPage;