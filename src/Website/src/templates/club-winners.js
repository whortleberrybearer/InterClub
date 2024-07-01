import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findClubWinner(yearId, categoryId, clubWinners) {
  return clubWinners
      .find((cw) => cw.YearId === yearId && cw.CategoryId === categoryId);
}

const ClubWinnersPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const clubCategories = data.allSqliteCompetitionTypeClubCategories.nodes.sort((a, b) => {
    return categoryOrder.indexOf(a.Category) - categoryOrder.indexOf(b.Category);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteCompetitionTypes.CompetitionType} Club Winners</h1>
        <table>
          <thead>
            <tr>
              <ht></ht>
              {clubCategories.map((clubCategory) => (
                <th key={clubCategory.CompetitionTypeClubCategoryId}>{clubCategory.Category}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.allSqliteYears.nodes.map((year) => (
              <tr key={year.YearId}>
                <td>{year.Year}</td>
                {clubCategories.map((clubCategory) => (
                  <td key={`${year.YearId}-${clubCategory.ClubCategoryId}`}>
                    {findClubWinner(year.YearId, clubCategory.CategoryId, data.allSqliteClubWinners.nodes)?.ClubShortName}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  return (
    <>
      <title>{data.sqliteCompetitionTypes.CompetitionType} Club Winners</title>
      <meta name="description" content={`History of Inter Club ${data.sqliteCompetitionTypes.CompetitionType} club winners.`} />
    </>
  );
}

export const query = graphql`
  query Query($competitionTypeId: Int) {
    sqliteCompetitionTypes(CompetitionTypeId: {eq: $competitionTypeId}) {
      CompetitionType
      CompetitionTypeId
    }
    allSqliteYears(sort: {Year: ASC}) {
      nodes {
        Year
        YearId
        Cancelled
        Comment
      }
    }
    allSqliteClubWinners(filter: {CompetitionTypeId: {eq: $competitionTypeId}}) {
      nodes {
        Year
        YearClubId
        YearId
        ClubWinnerId
        ClubShortName
        ClubId
        ClubCategoryId
        CategoryId
        Category
      }
    }
    allSqliteCompetitionTypeClubCategories(filter: {CompetitionTypeId: {eq: $competitionTypeId}}) {
      nodes {
        CompetitionTypeClubCategoryId
        Category
        CategoryId
      }
    }
  }`;

export default ClubWinnersPage;