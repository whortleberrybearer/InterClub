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
        fileName: 'C:/Users/wheel/source/repos/InterClub/database/InterClub.db',
        queries: [
          {
            statement: `SELECT *, FirstName || ' ' || LastName AS Name FROM runner`,
            idFieldName: 'RunnerId',
            name: 'runner'
          }
        ]
      }
    }
  ],
}
