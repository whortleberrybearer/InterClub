module.exports = {
  siteMetadata: {
    title: `Inter Club`,
    // title: `Inter Club - Road Grand Prix and Fell Championship`,
    description: `Kick off your next, great Gatsby project with this default starter. This barebones starter ships with the main Gatsby configuration files you might need.`,
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
          // This does not work because it is a compount pk.
          {
            statement: 'SELECT * FROM RunnerClub rc INNER JOIN Club c ON c.ClubId = rc.ClubId',
            idFieldName: 'RunnerClubId',
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
        ]
      }
    }
  ],
}
