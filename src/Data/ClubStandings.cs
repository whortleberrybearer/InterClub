public class ClubStandings
{
    public required string Category { get; init; }

    public required IEnumerable<ClubStanding> Standings { get; init; }
}
