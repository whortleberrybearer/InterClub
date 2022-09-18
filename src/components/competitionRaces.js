import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import { buildCategory } from "../functions/category";
import moment from "moment";
import { Table, Form, Row, Col } from "react-bootstrap"

const CompetitionRaces = ({ competition }) => {
  return (
    <>
      <Table striped>
        <thead>
          <tr>
            <th>Date</th>
            <th>Race</th>
            <th></th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {
            competition.competitionRaces.map(race =>
              <tr>
                <td>{race.StartDateTime}</td>
                <td>{race.Name}</td>
                <td>{race.ResultsAvailable === 1 && <Link to={`${slugify(competition.ShortName)}/${slugify(race.Name)}/results`}>Results</Link>}</td>
                <td>{race.TeamResultsAvailable === 1 && <Link to={`${slugify(competition.ShortName)}/${slugify(race.Name)}/clubresults`}>Club Results</Link>}</td>
              </tr>
            )
          }
        </tbody>
        <tfoot>
          <tr>
            <th colSpan="2" className="text-right">Overall</th>
            <td>{competition.StandingsAvailable === 1 && <Link to={`${slugify(competition.ShortName)}/standings`}>Standings</Link>}</td>
            <td>{competition.TeamStandingsAvailable === 1 && <Link to={`${slugify(competition.ShortName)}/clubstandings`}>Club Standings</Link>}</td>
          </tr>
        </tfoot>
      </Table>
    </>
  )
}

CompetitionRaces.propTypes = {
  races: PropTypes.node.isRequired,
}
  
export default CompetitionRaces