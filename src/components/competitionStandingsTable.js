import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import { buildCategory } from "../functions/category";
import { Table, Form, Row, Col } from "react-bootstrap"

const CompetitionStandingsTable = ({ standings, races }) => {
  const raceIds = races.map(race => race.RaceId);

  function findResult(results, raceId) {
    let result = results.find(result => result.RaceId == raceId);

    if (result?.Scoring === 1) {
        return <td><b>{result.Points}</b></td>
    }

    return <td>{result?.Points}</td>;
  }

  return (
    <Table striped>
      <thead>
        <tr>
          <th>Pos</th>
          <th>Name</th>
          <th>Category</th>
          <th>Club</th>
          {
            races.map(race => 
              <th><Link to={`/${race.competition.Year}/${slugify(race.competition.ShortName)}/${slugify(race.Name)}/results`}>{race.Name.replace("Inter Club", "")}</Link></th>
            )
          }
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        {
          standings.sort((a, b) => a.Position - b.Position).map(standing =>
            <tr>
              <td>{standing.Position}</td>
              <td><Link to={`/runners/${standing.RunnerId}-${slugify(standing.RunnerName ?? '')}`}>{standing.FirstName} {standing.LastName}</Link></td>
              <td>{buildCategory(standing.Sex, standing.AgeCategory)}</td>
              <td>{standing.Name}</td>
              {
                raceIds.map(raceId =>
                  findResult(standing.competitionRunnerResults, raceId)
                )
              }
              <td>{standing.Qualified ? <b>{standing.Points}</b> : standing.Points}</td>
            </tr>
          )
        }
      </tbody>
    </Table>
  )
}

CompetitionStandingsTable.propTypes = {
  standings: PropTypes.node.isRequired,
  races: PropTypes.node.isRequired,
}
  
export default CompetitionStandingsTable