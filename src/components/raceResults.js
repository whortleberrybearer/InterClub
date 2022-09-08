import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import { buildCategory } from "../functions/category";
import moment from "moment";

const RaceResults = ({ results }) => {
  const distinct = (value, index, self) => {
    return self.indexOf(value) === index;
  }

  const distinctRaces = results.map(result => result.RaceName).filter(distinct).sort();
  const distinctYears = results.map(result => moment(result.StartDateTime, "DD/MM/YYYY").year()).filter(distinct).sort().reverse();

  return (
    <>
      <label for="name-filter">Name</label>
      <input id="name-filter"></input>
      <label for="club-filter">Club</label>
      <select id="club-filter">
      </select>

      <table>
        <thead>
          <tr>
            <th>Position</th>
            <th>Name</th>
            <th>Category</th>
            <th>Club</th>
            <th>Time</th>
          </tr>
        </thead>
        <tbody>
          {
            results.map(result =>
              <tr>
                <td>{result.ResultPosition}</td>
                <td><Link to={`/runners/${result.RunnerId}-${slugify(result.RunnerName ?? '')}`}>{result.FirstName} {result.LastName}</Link></td>
                <td>{buildCategory(result.Sex, result.AgeCategory)}</td>
                <td>{result.ClubName}</td>
                <td>{result.Time}</td>
              </tr>
            )
          }
        </tbody>
      </table>
    </>
  )
}

RaceResults.propTypes = {
  results: PropTypes.node.isRequired,
}
  
export default RaceResults