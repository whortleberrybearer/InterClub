const path = require("path")
const slugify = require('slugify')

async function createResultPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const racesWithResults = await graphql(
    `{
      allSqliteRaces(filter: {NumberOfRaceResults: {gt: 0}}) {
        edges {
          node {
            CompetitionId
            CompetitionType
            Name
            RaceId
            Year
          }
        }
      }
    }`);

  if (racesWithResults.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const resultsTemplate = path.resolve(`src/templates/results.js`);
  
  racesWithResults.data.allSqliteRaces.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}/${slugify(node.CompetitionType, { lower: true })}/${slugify(node.Name, { lower: true })}/results`,
      component: resultsTemplate,
      context: {
        competitionId: node.CompetitionId,
        raceId: node.RaceId,
      },
    })
  });
}

async function createClubResultPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const racesWithClubResults = await graphql(
    `{
      allSqliteRaces(filter: {NumberOfClubResults: {gt: 0}}) {
        edges {
          node {
            CompetitionId
            CompetitionType
            Name
            RaceId
            Year
          }
        }
      }
    }`);

  if (racesWithClubResults.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const clubResultsTemplate = path.resolve(`src/templates/club-results.js`);
  
  racesWithClubResults.data.allSqliteRaces.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}/${slugify(node.CompetitionType, { lower: true })}/${slugify(node.Name, { lower: true })}/club-results`,
      component: clubResultsTemplate,
      context: {
        competitionId: node.CompetitionId,
        raceId: node.RaceId,
      },
    })
  });
}

async function createClubStandingPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const competitionsWithStandings = await graphql(
    `{
      allSqliteCompetitions(filter: {NumberOfClubStandings: {gt: 0}}) {
        edges {
          node {
            CompetitionId
            CompetitionType
            Year
          }
        }
      }
    }`);

  if (competitionsWithStandings.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const clubStandingsTemplate = path.resolve(`src/templates/club-standings.js`);
  
  competitionsWithStandings.data.allSqliteCompetitions.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}/${slugify(node.CompetitionType, { lower: true })}/club-standings`,
      component: clubStandingsTemplate,
      context: {
        competitionId: node.CompetitionId
      },
    })
  });
}

exports.createPages = async ({ graphql, actions, reporter }) => {
  
  await createResultPages(graphql, actions, reporter);
  await createClubResultPages(graphql, actions, reporter);
  await createClubStandingPages(graphql, actions, reporter);
}