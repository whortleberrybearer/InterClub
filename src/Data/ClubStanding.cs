public class ClubStanding
{
    public required string Club { get; init; }

    public required int Total { get; init; }
    
    public required IEnumerable<int> Points { get; init; }
}
