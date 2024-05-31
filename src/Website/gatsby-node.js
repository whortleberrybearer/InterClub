const path = require("path")

// Implement the Gatsby API “createPages”. This is called once the
// data layer is bootstrapped to let plugins create pages from data.
exports.createPages = async ({ graphql, actions, reporter }) => {
  const { createPage } = actions;

  // Query for markdown nodes to use in creating pages.
  const raceResultsFiles = await graphql(
    `{
        allFile(filter: {name: {eq: "RaceResults"}}) {
          edges {
            node {
              id
              relativeDirectory
            }
          }
        }
      }`);

  if (raceResultsFiles.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const resultsTemplate = path.resolve(`src/pages/results.js`);
  
  raceResultsFiles.data.allFile.edges.forEach(({ node }) => {
    createPage({
      path: node.relativeDirectory.toLowerCase() + "/results",
      component: resultsTemplate,
      // In your blog post template's graphql query, you can use pagePath
      // as a GraphQL variable to query for data from the markdown file.
      context: {
        id: node.id,
      },
    })
  });
}