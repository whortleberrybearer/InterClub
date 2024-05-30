public record RaceResult
{
    public int? RunnerNumber { get; init; }
    
    public required int Position { get; init; }
    
    public string? Name { get; init; }
    
    public string? Surname { get; init; }
    
    public string? Category { get; init; }
    
    public string? Sex { get; init; }
    
    public string? Club { get; init; }
    
    public TimeSpan? Time { get; init; }
    
    public string? Comments { get; init; }
    
    public required IEnumerable<ClubCategoryResult> ClubCategoryResults { get; init; }
}
