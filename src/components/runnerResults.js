import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import moment from "moment";
import { Table, Form, Row, Col } from "react-bootstrap"

const RunnerResults = ({ results }) => {
  const distinct = (value, index, self) => {
    return self.indexOf(value) === index;
  }

  const distinctRaces = results.map(result => result.RaceName).filter(distinct).sort();
  const distinctYears = results.map(result => moment(result.StartDateTime, "DD/MM/YYYY").year()).filter(distinct).sort().reverse();

  return (
    <>
      <h3>Results</h3>
      <Form>
        <Form.Group as={Row} className="mb-3" controlId="yearFilter">
          <Form.Label column sm="2">
            Year
          </Form.Label>
          <Col sm="10">
            <Form.Select aria-label="Year filter">
              <option></option>
              {
                distinctYears.map(year => <option>{year}</option>)
              }
            </Form.Select>
          </Col>
        </Form.Group>
        <Form.Group as={Row} className="mb-3" controlId="raceFilter">
          <Form.Label column sm="2">
            Race
          </Form.Label>
          <Col sm="10">
            <Form.Select aria-label="Race filter">
              <option></option>
              {
                distinctRaces.map(raceName => <option>{raceName}</option>)
              }
            </Form.Select>
          </Col>
        </Form.Group>
      </Form>

      <Table striped>
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
      </Table>
    </>
  )
}

RunnerResults.propTypes = {
  results: PropTypes.node.isRequired,
}
  
export default RunnerResults