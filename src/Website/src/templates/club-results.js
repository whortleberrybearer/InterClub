import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findAndSortClubResultsForCategory(clubCategoryId, clubResults) {
    return clubResults
        .filter((cr) => cr.ClubCategoryId === clubCategoryId)
        .sort((a, b) => a.Position - b.Position);
}

const ClubResultsPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const clubCategories = data.allSqliteClubCategories.nodes.sort((a, b) => {
    return categoryOrder.indexOf(a.Category) - categoryOrder.indexOf(b.Category);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteRaces.Name} Club Results</h1>
        <p>{new Date(data.sqliteRaces.StartDateTime).toLocaleDateString()}</p>

        {clubCategories.map((clubCategory) => (
            <div key={clubCategory.ClubCategoryId}>
              <h2>{clubCategory.Category}</h2>

              <table>
                <tbody>
                  {findAndSortClubResultsForCategory(clubCategory.ClubCategoryId, data.allSqliteClubResults.nodes).map((clubResult) => (
                    <tr key={clubResult.ClubResultId}>
                      <td>
                        {clubResult.ClubShortName}

                        <table>
                            <tbody>
                                {clubResult.TeamScorers.map((teamScorer) => (
                                    <tr key={teamScorer.TeamScorerId}>
                                        <td>{teamScorer.Position}</td>
                                        <td>{teamScorer.Name} {teamScorer.Surname}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                      </td>
                      <td>{clubResult.Score}</td>
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
    allSqliteClubResults(filter: {RaceId: {eq: $raceId}}) {
      nodes {
        ClubCategoryId
        ClubResultId
        ClubShortName
        Position
        Score
        TeamScorers {
          Name
          Surname
          Position
          TeamScorerId
        }
      }
    }
    allSqliteClubCategories(filter: {CompetitionId: {eq: $competitionId}}) {
      nodes {
        Category
        ClubCategoryId
      }
    }
}`;

export default ClubResultsPage;