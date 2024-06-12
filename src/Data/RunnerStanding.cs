public class RunnerStanding
{
    public required int Position { get; init; }

    public required string Name { get; init; }

    public required string Surname { get; init; }

    public required string Club { get; init; }

    public string? Category { get; init; }

    public string? Sex { get; init; }

    public required int Total { get; init; }

    public bool? Qualified { get; init; }

    public required IEnumerable<RunnerStandingResult> Results { get; init; }
}
