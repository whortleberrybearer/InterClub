public record ClubResults
{
    public required string Category { get; init; }

    public required IEnumerable<ClubResult> Results { get; init; }
}
