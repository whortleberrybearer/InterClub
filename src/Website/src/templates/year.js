import * as React from 'react'
import { graphql } from "gatsby"
import Layout from '../organisms/layout'
import CompetitionSummary from '../organisms/competition-summary';

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
          <CompetitionSummary key={competition.CompetitionId} competition={competition}></CompetitionSummary>
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
        NumberOfStandings
        NumberOfClubStandings
        Races {
          Name
          RaceId
          StartDateTime
          NumberOfClubResults
          NumberOfRaceResults
        }
      }
    }
  }`;

export default YearPage;