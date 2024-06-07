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
            statement: 'SELECT * FROM RaceResult',
            idFieldName: 'RaceResultId',
            name: 'RaceResults'
          },
          {
            statement: `
              SELECT 
                r.RaceId,
                r.Name,
                c.Year,
                c.Competition,
                rr.NumberOfResults
              FROM Race r
              INNER JOIN Competition c
              ON r.CompetitionId = c.CompetitionId
              LEFT OUTER JOIN 
                (SELECT RaceId, COUNT(*) NumberOfResults
                FROM RaceResult
                GROUP BY RaceId) rr
              ON r.RaceId = rr.RaceId;
            }`,
            idFieldName: 'RaceId',
            name: 'Races'
          }
        ]
      }
    }
  ]
};