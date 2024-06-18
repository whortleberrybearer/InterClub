const path = require("path")
const slugify = require('slugify')

// Implement the Gatsby API “createPages”. This is called once the
// data layer is bootstrapped to let plugins create pages from data.
exports.createPages = async ({ graphql, actions, reporter }) => {
  const { createPage } = actions;

  // Query for markdown nodes to use in creating pages.
  const racesWithResults = await graphql(
    `{
      allSqliteRaces(filter: {NumberOfResults: {gt: 0}}) {
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