public class ClubResult
{
    public required string Club { get; init; }
    
    public required int Score { get; init; }

    public required IEnumerable<TeamScorer> Scorers { get; init; }

    public int ClubResultId { get; set; }
}
