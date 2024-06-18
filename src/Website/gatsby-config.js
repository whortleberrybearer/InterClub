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
            statement: 'SELECT * FROM RaceResult;',
            idFieldName: 'RaceResultId',
            name: 'RaceResults'
          },
          {
            statement: `
              SELECT 
                r.*,
                rr.NumberOfResults
              FROM RacesView r
              LEFT OUTER JOIN 
                (SELECT RaceId, COUNT(*) NumberOfResults
                FROM RaceResult
                GROUP BY RaceId) rr
              ON r.RaceId = rr.RaceId;`,
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
          }
        ]
      }
    }
  ]
};