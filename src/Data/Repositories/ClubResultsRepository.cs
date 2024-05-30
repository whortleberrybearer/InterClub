using YamlDotNet.Serialization;

public interface IClubResultsRepository
{
    void Save(int year, string competition, string race, IEnumerable<ClubResults> clubResults);
}

public class ClubResultsRepository : IClubResultsRepository
{
    private static readonly ISerializer _serializer = new SerializerBuilder().ConfigureDefaultValuesHandling(DefaultValuesHandling.OmitNull).Build();
    private readonly string _basePath;

    public ClubResultsRepository(string basePath)
    {
        _basePath = basePath ?? throw new ArgumentNullException(nameof(basePath));
    }

    public void Save(int year, string competition, string race, IEnumerable<ClubResults> clubResults)
    {
        string path = Path.Combine(_basePath, year.ToString(), competition, race);

        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        foreach (var clubResult in clubResults)
        {
            File.WriteAllText(
                Path.Combine(path, $"ClubResults-{clubResult.Category.Replace(" ", string.Empty)}.yaml"),
                _serializer.Serialize(clubResult));
        }
    }
}
