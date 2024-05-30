using YamlDotNet.Serialization;

public interface IRaceResultsRepository
{
    void Save(int year, string competition, string race, IEnumerable<RaceResult> raceResults);
}

public class RaceResultsRepository : IRaceResultsRepository
{
    private static readonly ISerializer _serializer = new SerializerBuilder().Build();
    private readonly string _basePath;

    public RaceResultsRepository(string basePath)
    {
        _basePath = basePath ?? throw new ArgumentNullException(nameof(basePath));
    }

    public void Save(int year, string competition, string race, IEnumerable<RaceResult> raceResults)
    {
        string path = Path.Combine(_basePath, year.ToString(), competition, race);

        if (!Directory.Exists(path)) 
        {
            Directory.CreateDirectory(path);
        }

        File.WriteAllText(
            Path.Combine(path, "RaceResults.yaml"),
            _serializer.Serialize(raceResults));
    }
}