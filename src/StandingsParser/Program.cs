using Cocona;
using Dapper;
using Microsoft.Data.Sqlite;
using OfficeOpenXml;

// Needs to be set to avoid license exception.
ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

CoconaApp.Run(([Option("i")] string inputFile, [Option("o")] string outputPath, int year, string competition) =>
{
    ExtractedStandings extractedStandings = ExtractStandings(inputFile, competition, year);

    using (SqliteConnection connection = new SqliteConnection($"Data Source={Path.Combine(outputPath, "Database.db")}"))
    {
        connection.Open();

        using (SqliteTransaction transaction = connection.BeginTransaction())
        {
            int competitionId = connection.QuerySingle<int>(
                "SELECT CompetitionId " +
                "FROM Competition " +
                "WHERE Competition = @competition " +
                "AND Year = @year;",
                new
                {
                    competition,
                    year,
                });

            if (extractedStandings.RunnerStandings is not null)
            {
                SaveRunnerStandings(competitionId, extractedStandings.RunnerStandings, connection, transaction);
            }

            transaction.Commit();
        }
    }
});

ExtractedStandings ExtractStandings(string inputFile, string competition, int year)
{
    IStandingsExtractor standingsExtractor = new ExcelFellExtractor2017();

    using (Stream fileStream = File.OpenRead(inputFile))
    {
        return standingsExtractor.ExtractStandings(fileStream);
    }
}

void SaveRunnerStandings(int competitionId, IEnumerable<RunnerStandings> runnerStandings, SqliteConnection connection, SqliteTransaction transaction)
{
    throw new NotImplementedException();
}
