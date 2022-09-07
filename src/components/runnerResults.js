import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import moment from "moment";

const RunnerResults = ({ results }) => {
  const distinct = (value, index, self) => {
    return self.indexOf(value) === index;
  }

  const distinctRaces = results.map(result => result.RaceName).filter(distinct).sort();
  const distinctYears = results.map(result => moment(result.StartDateTime, "DD/MM/YYYY").year()).filter(distinct).sort().reverse();

  return (
    <>
      <h3>Results</h3>
      <label for="year-filter">Year</label>
      <select id="year-filter">
        {
          distinctYears.map(year => <option>{year}</option>)
        }
      </select>
      <label for="race-filter">Race</label>
      <select id="race-filter">
        {
          distinctRaces.map(raceName => <option>{raceName}</option>)
        }
      </select>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Race</th>
            <th>Distance</th>
            <th>Time</th>
          </tr>
        </thead>
        <tbody>
          {
            results.reverse().map(result =>
              <tr>
                <td>{result.StartDateTime}</td>
                <td><Link to={`/${result.Year}/${slugify(result.ShortName)}/${slugify(result.RaceName)}/results`}>{result.RaceName}</Link></td>
                <td>{result.Distance}</td>
                <td>{result.Time}</td>
              </tr>
            )
          }
        </tbody>
      </table>
    </>
  )
}

RunnerResults.propTypes = {
  results: PropTypes.node.isRequired,
}
  
export default RunnerResults