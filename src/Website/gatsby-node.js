const path = require("path")

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
            Competition
            Name
            NumberOfResults
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

  const resultsTemplate = path.resolve(`src/pages/results.js`);
  
  racesWithResults.data.allSqliteRaces.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}/${node.Competition}/${node.Name}/results`,
      component: resultsTemplate,
      context: {
        id: node.RaceId,
      },
    })
  });
}