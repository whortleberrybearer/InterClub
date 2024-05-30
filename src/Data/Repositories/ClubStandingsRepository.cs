using System.Diagnostics;
using YamlDotNet.Serialization;

public interface IClubStandingsRepository
{
    void Save(int year, string competition, IEnumerable<ClubStandings> clubStandings);
}

public class ClubStandingsRepository : IClubStandingsRepository
{
    private static readonly ISerializer _serializer = new SerializerBuilder().ConfigureDefaultValuesHandling(DefaultValuesHandling.OmitNull).Build();
    private readonly string _basePath;

    public ClubStandingsRepository(string basePath)
    {
        _basePath = basePath ?? throw new ArgumentNullException(nameof(basePath));
    }

    public void Save(int year, string competition, IEnumerable<ClubStandings> clubStandings)
    {
        string path = Path.Combine(_basePath, year.ToString(), competition);

        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        foreach (var clubStanding in clubStandings)
        {
            File.WriteAllText(
                Path.Combine(path, $"ClubStandings-{clubStanding.Category.Replace(" ", string.Empty)}.yaml"),
                _serializer.Serialize(clubStanding));
        }
    }
}