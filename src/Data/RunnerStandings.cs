public class RunnerStandings
{
    public required string Category { get; init; }

    public required IEnumerable<RunnerStanding> Standings { get; init; }
}
