import { Link } from "gatsby";
import React from "react"
const slugify = require('slugify')

export default function CompetitionSummary({ competition }) {
  return (
    <div>
      <h2>{competition.CompetitionType}</h2>
      {competition.Races.length > 0 &&
        <div>
            <h3>Races</h3>
            <table>
                <tbody>
                    {competition.Races.map((race) => (
                        <tr>
                            <td>{race.StartDateTime}</td>
                            <td>{race.Name}</td>
                            <td>
                                {race.NumberOfRaceResults && 
                                <Link to={`${slugify(competition.CompetitionType, { lower: true })}/${slugify(race.Name, { lower: true })}/results`}>Results</Link>}
                            </td>
                            <td>
                                {race.NumberOfClubResults && 
                                <Link to={`${slugify(competition.CompetitionType, { lower: true })}/${slugify(race.Name, { lower: true })}/club-results`}>Club Results</Link>}
                            </td>
                        </tr>
                    ))}
                </tbody>
                <tfoot>
                    <tr>
                        <td colSpan={3}>
                            {competition.NumberOfStandings &&    
                            <Link to={`${slugify(competition.CompetitionType, { lower: true })}/standings`}>Standings</Link>}
                        </td>
                        <td>
                            {competition.NumberOfClubStandings &&    
                            <Link to={`${slugify(competition.CompetitionType, { lower: true })}/club-standings`}>Club Standings</Link>}
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
      }

      {competition.ClubWinners.length > 0 &&
        <div>
            <h3>Club Winners</h3>
            <table>
                <tbody>
                {competition.ClubWinners.map((clubWinner) => (
                    <tr key={clubWinner.ClubWinnerId}>
                        <td>{clubWinner.Category}</td>
                        <td>{clubWinner.ClubShortName}</td>
                    </tr> 
                ))}
                </tbody>
            </table>
        </div>
      }

      {competition.RunnerWinners.length > 0 &&
        <div>
            <h3>Individual Winners</h3>
            <table>
                <tbody>
                {competition.RunnerWinners.map((runnerWinner) => (
                    <tr key={runnerWinner.RunnerWinnerId}>
                        <td>{runnerWinner.Category}</td>
                        <td>{runnerWinner.Position}</td>
                        <td>{runnerWinner.Name} {runnerWinner.Surname}</td>
                        <td>{runnerWinner.ClubShortName}</td>
                    </tr> 
                ))}
                </tbody>
            </table>
        </div>
      }
    </div>
  );
}