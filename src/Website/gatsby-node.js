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

async function createStandingPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const competitionsWithStandings = await graphql(
    `{
      allSqliteCompetitions(filter: {NumberOfStandings: {gt: 0}}) {
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

  const standingsTemplate = path.resolve(`src/templates/standings.js`);
  
  competitionsWithStandings.data.allSqliteCompetitions.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}/${slugify(node.CompetitionType, { lower: true })}/standings`,
      component: standingsTemplate,
      context: {
        competitionId: node.CompetitionId
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

async function createYearPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const years = await graphql(
    `{
      allSqliteYears {
        edges {
          node {
            YearId
            Year
          }
        }
      }
    }`);

  if (years.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const yearsTemplate = path.resolve(`src/templates/year.js`);
  
  years.data.allSqliteYears.edges.forEach(({ node }) => {
    createPage({
      path: `${node.Year}`,
      component: yearsTemplate,
      context: {
        id: node.YearId
      },
    })
  });
}

async function createClubWinnersPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const competitionTypes = await graphql(
    `{
      allSqliteCompetitionTypes {
        edges {
          node {
            CompetitionTypeId
            CompetitionType
          }
        }
      }
    }`);

  if (competitionTypes.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const clubWinnersTemplate = path.resolve(`src/templates/club-winners.js`);
  
  competitionTypes.data.allSqliteCompetitionTypes.edges.forEach(({ node }) => {
    createPage({
      path: `${slugify(node.CompetitionType, { lower: true })}/club-winners`,
      component: clubWinnersTemplate,
      context: {
        competitionTypeId: node.CompetitionTypeId
      },
    })
  });
}

async function createWinnersPages(graphql, actions, reporter) {
  const { createPage } = actions;

  const competitionTypes = await graphql(
    `{
      allSqliteCompetitionTypes {
        edges {
          node {
            CompetitionTypeId
            CompetitionType
          }
        }
      }
    }`);

  if (competitionTypes.errors) {
    reporter.panicOnBuild(`Error while running GraphQL query.`);
    
    return;
  }

  const runnerWinnersTemplate = path.resolve(`src/templates/winners.js`);
  
  competitionTypes.data.allSqliteCompetitionTypes.edges.forEach(({ node }) => {
    createPage({
      path: `${slugify(node.CompetitionType, { lower: true })}/winners`,
      component: runnerWinnersTemplate,
      context: {
        competitionTypeId: node.CompetitionTypeId
      },
    })
  });
}

exports.createPages = async ({ graphql, actions, reporter }) => {
  
  await createResultPages(graphql, actions, reporter);
  await createClubResultPages(graphql, actions, reporter);
  await createStandingPages(graphql, actions, reporter);
  await createClubStandingPages(graphql, actions, reporter);
  await createYearPages(graphql, actions, reporter);
  await createClubWinnersPages(graphql, actions, reporter);
  await createWinnersPages(graphql, actions, reporter);
}