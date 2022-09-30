module.exports = {
  siteMetadata: {
    title: `Inter Club`,
    description: `Road Grand Prix and Fell Championship`,
    author: `Barry Wheeler`,
    siteUrl: `https://gatsbystarterdefaultsource.gatsbyjs.io/`,
  },
  plugins: [
    `gatsby-plugin-image`,
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        name: `images`,
        path: `${__dirname}/src/images`,
      },
    },
    `gatsby-transformer-sharp`,
    `gatsby-plugin-sharp`,
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: `gatsby-starter-default`,
        short_name: `starter`,
        start_url: `/`,
        background_color: `#663399`,
        // This will impact how browsers show your PWA/website
        // https://css-tricks.com/meta-theme-color-and-trickery/
        // theme_color: `#663399`,
        display: `minimal-ui`,
        icon: `src/images/gatsby-icon.png`, // This path is relative to the root of the site.
      },
    },
    {
      resolve: `gatsby-source-sqlite`,
      options: {
        fileName: 'C:\\Users\\wheel\\source\\repos\\InterClub\\database\\InterClub.db',
        queries: [
          {
            statement: `SELECT *, FirstName || ' ' || LastName AS Name FROM Runner`,
            idFieldName: 'RunnerId',
            name: 'runner'
          },
          {
            statement: 'SELECT * FROM RunnerClub rc INNER JOIN Club c ON c.ClubId = rc.ClubId',
            idFieldName: 'RunnerClubId',  // This key does not exist, so this might not work, but it seems to.
            name: 'runnerClub',
            parentName: 'runner',
            foreignKey: 'RunnerId',
            cardinality: 'OneToMany'
          },
          {
            statement: 'SELECT DISTINCT(Year) FROM Competition',
            idFieldName: 'Year',
            name: 'competitionYear'
          },
          {
            statement: 'SELECT * FROM Competition c INNER JOIN CompetitionType ct ON ct.CompetitionTypeId = c.CompetitionTypeId',
            idFieldName: 'CompetitionId',
            name: 'competition'
          },
          {
            statement: 'SELECT * FROM Race r INNER JOIN Event e ON e.EventId = r.EventId',
            idFieldName: 'RaceId',
            name: 'competitionRace',
            parentName: 'competition',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement: 
              `SELECT *, e.Name AS RaceName FROM Result r
              INNER JOIN CompetitionRunner cr
              ON cr.CompetitionRunnerId = r.CompetitionRunnerId
              INNER JOIN Race rc
              ON r.RaceId = rc.RaceId
              INNER JOIN Event e
              ON e.EventId = rc.EventId
              INNER JOIN Competition c
              ON c.CompetitionId = rc.CompetitionId
              INNER JOIN CompetitionType ct
              ON ct.CompetitionTypeId = c.CompetitionTypeId`,
            idFieldName: 'ResultId',
            name: 'runnerResults',
            parentName: 'runner',
            foreignKey: 'RunnerId',
            cardinality: 'OneToMany'
          },
          {
            statement: 
              `SELECT *, r.Position AS ResultPosition, rn.FirstName || ' ' || rn.LastName AS RunnerName, c.Name AS ClubName  
              FROM Result r 
              LEFT OUTER JOIN CompetitionRunner cr
              ON cr.CompetitionRunnerId = r.CompetitionRunnerId 
              LEFT OUTER JOIN Runner rn 
              ON rn.RunnerId = cr.RunnerId
              LEFT OUTER JOIN CompetitionClub cc
              ON cc.CompetitionClubId = r.CompetitionClubId
              LEFT OUTER JOIN Club c
              ON c.ClubId = cc.ClubId
              ORDER BY Position`,
            idFieldName: 'ResultId',
            name: 'raceResults',
            parentName: 'competitionRace',
            foreignKey: 'RaceId',
            cardinality: 'OneToMany'
          },
          {
            statement:
              `SELECT *
              FROM CompetitionCategory cc
              INNER JOIN Category c
              ON c.CategoryId = cc.CategoryId`,
            idFieldName: 'CompetitionCategoryId',
            name: 'competitionCategories',
            parentName: 'competition',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement:
              `SELECT *
              FROM CompetitionRunnerCategory crc`,
            idFieldName: 'CompetitionRunnerCategoryId',
            name: 'competitionRunnerCategories',
            parentName: 'competition',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM CompetitionCategoryResult`,
            idFieldName: 'CompetitionCategoryResultId',
            name: 'competitionCategoryResults',
            parentName: 'raceResults',
            foreignKey: 'ResultId',
            cardinality: 'OneToMany'
          },
          {
            statement:
              `SELECT *
              FROM CompetitionRunnerCategoryStanding crcs
              INNER JOIN CompetitionRunner cr
              ON cr.CompetitionRunnerId = crcs.CompetitionRunnerId
              INNER JOIN CompetitionClub cc
              ON cc.CompetitionClubId = cr.CompetitionClubId
              INNER JOIN Club c
              ON c.ClubId = cc.ClubId`,
            idFieldName: 'CompetitionRunnerCategoryStandingId',
            name: 'competitionRunnerCategoryStandings',
            parentName: 'competitionRunnerCategories',
            foreignKey: 'CompetitionRunnerCategoryId',
            cardinality: 'OneToMany'
          },
          {
            statement: 
              `SELECT *, cr.FirstName || ' ' || cr.LastName AS RunnerName
              FROM CompetitionRunner cr
              INNER JOIN CompetitionClub cc
              ON cc.CompetitionClubId = cr.CompetitionClubId
              INNER JOIN Club c
              ON c.ClubId = cc.ClubId`,
            idFieldName: 'CompetitionRunnerId',
            name: 'competitionRunners',
            parentName: 'competition',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement: 
              `SELECT *
              FROM Result r`,
            idFieldName: 'ResultId',
            name: 'competitionRunnerResults',
            parentName: 'competitionRunners',
            foreignKey: 'CompetitionRunnerId',
            cardinality: 'OneToMany'
          },
        ]
      }
    }
  ],
}
