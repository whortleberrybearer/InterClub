import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

function findRunnerWinner(yearId, categoryId, runnerWinners) {
  console.log(runnerWinners);
  console.log(categoryId);
  console.log(yearId);
  return runnerWinners
      .find((cw) => cw.YearId === yearId && cw.CategoryId === categoryId);
}

const RunnerWinnersPage = ({data}) => {
  const categoryOrder = [ "Open", "Female", "Vet", "Female Vet 40", "Vet 50", "Vet 60" ];
  const runnerCategories = data.allSqliteCompetitionTypeRunnerCategories.nodes.sort((a, b) => {
    return categoryOrder.indexOf(a.Category) - categoryOrder.indexOf(b.Category);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteCompetitionTypes.CompetitionType} Winners</h1>
        <table>
          <thead>
            <tr>
              <th></th>
              {runnerCategories.map((runnerCategory) => (
                <th key={runnerCategory.CompetitionTypeRunnerCategoryId}>{runnerCategory.Category}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.allSqliteYears.nodes.map((year) => (
              <tr key={year.YearId}>
                <td>{year.Year}</td>
                {year.Cancelled 
                  ? <td colSpan={runnerCategories.length}>{year.Comment}</td>
                  : runnerCategories.map((runnerCategory) => (
                      <td key={`${year.YearId}-${runnerCategory.CategoryId}`}>
                        {findRunnerWinner(year.YearId, runnerCategory.CategoryId, data.allSqliteRunnerWinners.nodes)?.Surname}
                      </td>
                    ))
                }
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
      <title>{data.sqliteCompetitionTypes.CompetitionType} Winners</title>
      <meta name="description" content={`History of Inter Club ${data.sqliteCompetitionTypes.CompetitionType} winners.`} />
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
    allSqliteRunnerWinners(filter: {CompetitionTypeId: {eq: $competitionTypeId}}) {
      nodes {
        Year
        YearId
        RunnerWinnerId
        ClubShortName
        ClubId
        RunnerCategoryId
        CategoryId
        Category
        Name
        Surname
        Position
      }
    }
    allSqliteCompetitionTypeRunnerCategories(filter: {CompetitionTypeId: {eq: $competitionTypeId}}) {
      nodes {
        CompetitionTypeRunnerCategoryId
        Category
        CategoryId
      }
    }
  }`;

export default RunnerWinnersPage;