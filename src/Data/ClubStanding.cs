public class ClubStanding
{
    public required string Club { get; init; }

    public required int Total { get; init; }
    
    public required IEnumerable<ClubStandingResult> Results { get; init; }
}
