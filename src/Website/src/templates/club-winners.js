import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

const ClubWinnersPage = ({data}) => {
  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteCompetitionTypes.CompetitionType} Club Winners</h1>
        <table>
          <thead>
            <tr>
              <td></td>
              {data.allSqliteCompetitionTypeClubCategories.nodes.map((clubCategory) => (
                <td key={clubCategory.CompetitionTypeClubCategoryId}>{clubCategory.Category}</td>
              ))}
            </tr>
          </thead>
          <tbody>
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