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
            name: 'Races'
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
                cs.NumberOfStandings NumberOfClubStandings
              FROM CompetitionsView cv
              LEFT OUTER JOIN
                (SELECT ca.CompetitionId, COUNT(*) NumberOfStandings
                FROM ClubStanding cs
                INNER JOIN ClubCategory ca
                ON ca.ClubCategoryId = cs.ClubCategoryId
                GROUP BY CompetitionId) cs
              ON cs.CompetitionId = cv.CompetitionId;`,
            idFieldName: 'CompetitionId',
            name: 'Competitions'
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
        ]
      }
    }
  ]
};