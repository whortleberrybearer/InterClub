import { graphql, useStaticQuery, type GatsbyNode } from "gatsby";
import path from "path";

export const createPages: GatsbyNode["createPages"] = ({ actions }) => {
  const { createPage } = actions;
  
  console.log("start");

  const raceResultsFiles = useStaticQuery(graphql`
    query 
      allFile(filter: {name: {eq: "RaceResults"}}) {
        edges {
          node {
            id
            relativeDirectory
          }
        }
      }
    }`);

  console.log("hello");
  
  /*raceResultsFiles.map(file => {
    console.log(file);

    createPage({
      path: file.relativeDirectory.toLowerCase() + "/results",
      component: path.resolve("./src/pages/results.tsx"),
      context: {
        file
      },
      defer: true,
    });
  });*/
};

/*
export const sourceNodes: GatsbyNode["sourceNodes"] = async ({
  actions,
  createNodeId,
  createContentDigest,
}) => {
  const { createNode } = actions

  const data = await getSomeData()

  data.forEach((person: Person) => {
    const node = {
      ...person,
      parent: null,
      children: [],
      id: createNodeId(`person__${person.id}`),
      internal: {
        type: "Person",
        content: JSON.stringify(person),
        contentDigest: createContentDigest(person),
      },
    }

    createNode(node)
  })
}*/