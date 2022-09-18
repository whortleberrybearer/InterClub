import * as React from "react"
import PropTypes from "prop-types"
import slugify from '@sindresorhus/slugify';
import { Link } from "gatsby"
import { buildCategory } from "../functions/category";
import moment from "moment";
import { Table, Form, Row, Col } from "react-bootstrap"

const RaceResults = ({ results }) => {
  const distinct = (value, index, self) => {
    return self.indexOf(value) === index;
  }

  const distinctRaces = results.map(result => result.RaceName).filter(distinct).sort();
  const distinctYears = results.map(result => moment(result.StartDateTime, "DD/MM/YYYY").year()).filter(distinct).sort().reverse();

  return (
    <>
      <Form>
        <Form.Group as={Row} className="mb-3" controlId="nameFilter">
          <Form.Label column sm="2">
            Name
          </Form.Label>
          <Col sm="10">
            <Form.Control type="text" />
          </Col>
        </Form.Group>
        <Form.Group as={Row} className="mb-3" controlId="clubFilter">
          <Form.Label column sm="2">
            Club
          </Form.Label>
          <Col sm="10">
            <Form.Select aria-label="Race filter">
              <option></option>
              {
                //distinctRaces.map(raceName => <option>{raceName}</option>)
              }
            </Form.Select>
          </Col>
        </Form.Group>
      </Form>

      <Table striped>
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
      </Table>
    </>
  )
}

RaceResults.propTypes = {
  results: PropTypes.node.isRequired,
}
  
export default RaceResults