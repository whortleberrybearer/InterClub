using Cocona;
using Dapper;
using Microsoft.Data.Sqlite;
using OfficeOpenXml;

// Needs to be set to avoid license exception.
ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

CoconaApp.Run(([Option("i")] string inputFile, [Option("o")] string outputPath, int year, string competition, string race) =>
{
    ExtractedResults extractedResults = ExtractResults(inputFile);

    using (SqliteConnection connection = new SqliteConnection($"Data Source={Path.Combine(outputPath, "Database.db")}"))
    {
        connection.Open();

        using (SqliteTransaction transaction = connection.BeginTransaction())
        {
            int raceId = connection.QuerySingle<int>(
                "SELECT RaceId " +
                "FROM Race r " +
                "INNER JOIN Competition c " +
                "ON r.CompetitionId = c.CompetitionId " +
                "WHERE r.Name = @name " +
                "AND c.Competition = @competition " +
                "AND c.Year = @year;",
                new
                {
                    competition,
                    year,
                    name = race,
                });

            if (extractedResults.RaceResults is not null)
            {
                SaveRaceResults(raceId, extractedResults.RaceResults, connection, transaction);
            }

            if (extractedResults.ClubResults is not null)
            {
                SaveClubResults(raceId, extractedResults.ClubResults, connection, transaction);
            }

            if (extractedResults.ClubStandings is not null)
            {
                IClubStandingsRepository clubStandingsRepository = new ClubStandingsRepository(outputPath);

                clubStandingsRepository.Save(year, competition, extractedResults.ClubStandings);
            }

            transaction.Commit();
        }
    }
});

void SaveRaceResults(int raceId, IEnumerable<RaceResult> raceResults, SqliteConnection connection, SqliteTransaction transaction)
{
    foreach (RaceResult raceResult in raceResults)
    {
        raceResult.RaceResultId = connection.QuerySingle<int>(
            "INSERT INTO RaceResult (RaceId, Position, RunnerNumber, Name, Surname, Category, Sex, Club, Time, Comments) " +
            "VALUES (@raceId, @position, @runnerNumber, @name, @surname, @category, @sex, @club, @time, @comments);" +
            "SELECT last_insert_rowid();",
            new
            {
                raceId,
                position = raceResult.Position,
                runnerNumber = raceResult.RunnerNumber,
                name = raceResult.Name,
                surname = raceResult.Surname,
                category = raceResult.Category,
                sex = raceResult.Sex,
                club = raceResult.Club,
                time = raceResult.Time,
                comments = raceResult.Comments,
            },
            transaction);

        foreach (ClubCategoryResult clubCategoryResult in raceResult.ClubCategoryResults)
        {
            connection.Execute(
                "INSERT INTO ClubCategoryResult(RaceResultId, Category, Position) " +
                "VALUES(@raceResultId, @category, @position);",
                new
                {
                    raceResultId = raceResult.RaceResultId,
                    category = clubCategoryResult.Category,
                    position = clubCategoryResult.Position,
                },
                transaction);
        }
    }
}

void SaveClubResults(int raceId, IEnumerable<ClubResults> clubResults, SqliteConnection connection, SqliteTransaction transaction)
{
    foreach (ClubResults clubResult in clubResults)
    {
        for (int i = 0; i < clubResult.Results.Count(); i++)
        {
            ClubResult result = clubResult.Results.ElementAt(i);

            result.ClubResultId = connection.QuerySingle<int>(
                "INSERT INTO ClubResult (RaceId, Category, Club, Position, Score) " +
                "VALUES (@raceId, @category, @club, @position, @score);" +
                "SELECT last_insert_rowid();",
                new
                {
                    raceId,
                    category = clubResult.Category,
                    club = result.Club,
                    position = i + 1,
                    score = result.Score,
                },
                transaction);

            foreach (TeamScorer teamScorer in result.Scorers)
            {
                connection.Execute(
                    "INSERT INTO TeamScorer (ClubResultId, RaceResultId) " +
                    "VALUES (@clubResultId, @raceResultId);",
                    new
                    {
                        clubResultId = result.ClubResultId,
                        raceResultId = teamScorer.Result.RaceResultId,
                    },
                    transaction);
            }
        }
    }
}


ExtractedResults ExtractResults(string inputFile)
{
    IResultsExtractor resultsExtractor = new ExcelRoadExtractor2024();

    using (Stream fileStream = File.OpenRead(inputFile))
    {
        return resultsExtractor.ExtractResults(fileStream);
    }
}