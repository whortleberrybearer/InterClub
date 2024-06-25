/**
 * @type {import('gatsby').GatsbyConfig}
 */
module.exports = {
  siteMetadata: {
    title: `Website`,
    siteUrl: `https://www.yourdomain.tld`
  },
  plugins: [
    "gatsby-plugin-image", 
    "gatsby-plugin-sitemap", {
      resolve: 'gatsby-plugin-manifest',
      options: {
        "icon": "src/images/icon.png"
      }
    },
    "gatsby-plugin-sharp",
    "gatsby-transformer-sharp", 
    {
      resolve: 'gatsby-source-filesystem',
      options: {
        "name": "images",
        "path": "./src/images/"
      },
      __key: "images"
    },
    {
      resolve: `gatsby-source-sqlite`,
      options: {
        fileName: '../../data/Database.db',
        queries: [
          {
            statement: 'SELECT * FROM RaceResultsView;',
            idFieldName: 'RaceResultId',
            name: 'RaceResults'
          },
          {
            statement: `
              SELECT 
                r.*,
                rr.NumberOfResults NumberOfRaceResults,
                cr.NumberOfResults NumberOfClubResults
              FROM RacesView r
              LEFT OUTER JOIN 
                (SELECT RaceId, COUNT(*) NumberOfResults
                FROM RaceResult
                GROUP BY RaceId) rr
              ON rr.RaceId = r.RaceId
              LEFT OUTER JOIN 
                (SELECT RaceId, COUNT(*) NumberOfResults
                FROM ClubResult
                GROUP BY RaceId) cr
              ON cr.RaceId = r.RaceId;`,
            idFieldName: 'RaceId',
            name: 'Races',
            parentName: 'Competitions',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM ClubCategoriesView;`,
            idFieldName: 'ClubCategoryId',
            name: 'ClubCategories'
          },
          {
            statement: `SELECT * FROM ClubCategoryResult;`,
            idFieldName: 'ClubCategoryResultId',
            name: 'ClubCategoryResults',
            parentName: 'RaceResults',
            foreignKey: 'RaceResultId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM ClubResultsView;`,
            idFieldName: 'ClubResultId',
            name: 'ClubResults',
            parentName: 'ClubCategories',
            foreignKey: 'ClubCategoryId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM TeamScorersView;`,
            idFieldName: 'TeamScorerId',
            name: 'TeamScorers',
            parentName: 'ClubResults',
            foreignKey: 'ClubResultId',
            cardinality: 'OneToMany'
          },
          {
            statement: `
              SELECT 
                cv.*,
                cs.NumberOfStandings NumberOfClubStandings,
                rs.NumberOfStandings NumberOfStandings
              FROM CompetitionsView cv
              LEFT OUTER JOIN
                (SELECT cc.CompetitionId, COUNT(*) NumberOfStandings
                FROM ClubStanding cs
                INNER JOIN ClubCategory cc
                ON cc.ClubCategoryId = cs.ClubCategoryId
                GROUP BY cc.CompetitionId) cs
              ON cs.CompetitionId = cv.CompetitionId
              LEFT OUTER JOIN
                (SELECT rc.CompetitionId, COUNT(*) NumberOfStandings
                FROM RunnerStanding rs
                INNER JOIN RunnerCategory rc
                ON rc.RunnerCategoryId = rs.RunnerCategoryId
                GROUP BY rc.CompetitionId) rs
              ON rs.CompetitionId = cv.CompetitionId;`,
            idFieldName: 'CompetitionId',
            name: 'Competitions',
            parentName: 'Years',
            foreignKey: 'YearId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM ClubStandingsView;`,
            idFieldName: 'ClubStandingId',
            name: 'ClubStandings'
          },
          {
            statement: `SELECT * FROM ClubStandingResult;`,
            idFieldName: 'ClubStandingResultId',
            name: 'ClubStandingResults',
            parentName: 'ClubStandings',
            foreignKey: 'ClubStandingId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM RunnerCategoriesView;`,
            idFieldName: 'RunnerCategoryId',
            name: 'RunnerCategories'
          },
          {
            statement: `SELECT * FROM RunnerStandingsView;`,
            idFieldName: 'RunnerStandingId',
            name: 'RunnerStandings'
          },
          {
            statement: `SELECT * FROM RunnerStandingResult;`,
            idFieldName: 'RunnerStandingResultId',
            name: 'RunnerStandingResults',
            parentName: 'RunnerStandings',
            foreignKey: 'RunnerStandingId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM Year;`,
            idFieldName: 'YearId',
            name: 'Years'
          },
          {
            statement: `SELECT * FROM ClubWinnersView;`,
            idFieldName: 'ClubWinnerId',
            name: 'ClubWinners',
            parentName: 'Competitions',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
          {
            statement: `SELECT * FROM RunnerWinnersView;`,
            idFieldName: 'RunnerWinnerId',
            name: 'RunnerWinners',
            parentName: 'Competitions',
            foreignKey: 'CompetitionId',
            cardinality: 'OneToMany'
          },
        ]
      }
    }
  ]
};