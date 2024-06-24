import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'

const YearPage = ({data}) => {
  const competitionOrder = [ "Road", "Fell" ];
  const competitions = data.allSqliteCompetitions.nodes.sort((a, b) => {
    return competitionOrder.indexOf(a.CompetitionType) - competitionOrder.indexOf(b.CompetitionType);
  });

  return (
    <Layout>
      <main className="container">
        <h1>{data.sqliteYears.Year}</h1>

        {competitions.map((competition) => (
          <div key={competition.CompetitionId}>
            <h2>{competition.CompetitionType}</h2>
          </div>
        ))} 
      </main>
    </Layout>
  )
}

export const Head =  ({data}) => {
  return (
    <>
      <title>{data.sqliteYears.Year}</title>
      <meta name="description" content={`Inter Club details for ${data.sqliteYears.Year}.`} />
    </>
  );
}

export const query = graphql`
  query Query($id: Int) {
    sqliteYears(YearId: {eq: $id}) {
      Year
      YearId
    }
    allSqliteCompetitions(filter: {YearId: {eq: $id}}) {
      nodes {
        CompetitionId
        CompetitionType
      }
    }
  }`;

export default YearPage;