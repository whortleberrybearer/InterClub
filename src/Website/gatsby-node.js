const path = require("path")
const slugify = require('slugify')

async function createResultPages(graphql, actions, reporter) {
  const { createPage } = actions;

  // Query for markdown nodes to use in creating pages.
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

  // Query for markdown nodes to use in creating pages.
  const racesWithResults = await graphql(
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

  if (racesWithResults.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const clubResultsTemplate = path.resolve(`src/templates/club-results.js`);
  
  racesWithResults.data.allSqliteRaces.edges.forEach(({ node }) => {
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

exports.createPages = async ({ graphql, actions, reporter }) => {
  
  await createResultPages(graphql, actions, reporter);
  await createClubResultPages(graphql, actions, reporter);
}