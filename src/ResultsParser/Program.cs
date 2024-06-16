using Cocona;
using Dapper;
using Microsoft.Data.Sqlite;
using OfficeOpenXml;

// Needs to be set to avoid license exception.
ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

CoconaApp.Run(([Option("i")] string inputFile, [Option("o")] string outputPath, int year, string competition, string race) =>
{
    ExtractedResults extractedResults = ExtractResults(inputFile, competition, year);

    using (SqliteConnection connection = new SqliteConnection($"Data Source={Path.Combine(outputPath, "Database.db")}"))
    {
        connection.Open();

        using (SqliteTransaction transaction = connection.BeginTransaction())
        {
            int competitionId = connection.QuerySingle<int>(
                "SELECT CompetitionId " +
                "FROM CompetitionsView " +
                "WHERE CompetitionType = @competition " +
                "AND Year = @year;",
                new
                {
                    competition,
                    year,
                });
            IEnumerable<YearClub> yearClubs = connection.Query<YearClub>(
                "SELECT YearClubId, ShortName " +
                "FROM YearClubsView " +
                "WHERE Year = @year;",
                new
                {
                    year,
                });
            int raceId = connection.QuerySingle<int>(
                "SELECT RaceId " +
                "FROM Race " +
                "WHERE Name = @name " +
                "AND CompetitionId = @competitionId;",
                new
                {
                    name = race,
                    competitionId,
                });

            if (extractedResults.RaceResults is not null)
            {
                SaveRaceResults(raceId, extractedResults.RaceResults, yearClubs, connection, transaction);
            }

            if (extractedResults.ClubResults is not null)
            {
                SaveClubResults(raceId, extractedResults.ClubResults, yearClubs, connection, transaction);
            }

            if (extractedResults.ClubStandings is not null)
            {
                SaveClubStandings(competitionId, raceId, race, extractedResults.ClubStandings, yearClubs, connection, transaction);
            }

            transaction.Commit();
        }
    }
});

void SaveRaceResults(
    int raceId, 
    IEnumerable<RaceResult> raceResults, 
    IEnumerable<YearClub> yearClubs, 
    SqliteConnection connection, 
    SqliteTransaction transaction)
{
    foreach (RaceResult raceResult in raceResults)
    {
        raceResult.RaceResultId = connection.QuerySingle<int>(
            "INSERT INTO RaceResult (RaceId, Position, RunnerNumber, Name, Surname, Category, Sex, Club, YearClubId, Time, Comments) " +
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
                yearClubId = yearClubs.FirstOrDefault(yc => yc.ShortName.Equals(raceResult.Club, StringComparison.InvariantCultureIgnoreCase))?.YearClubId,
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

void SaveClubResults(int raceId, IEnumerable<ClubResults> clubResults, IEnumerable<YearClub> yearClubs, SqliteConnection connection, SqliteTransaction transaction)
{
    foreach (ClubResults clubResult in clubResults)
    {
        for (int i = 0; i < clubResult.Results.Count(); i++)
        {
            ClubResult result = clubResult.Results.ElementAt(i);

            result.ClubResultId = connection.QuerySingle<int>(
                "INSERT INTO ClubResult (RaceId, Category, YearClubId, Position, Score) " +
                "VALUES (@raceId, @category, @club, @position, @score);" +
                "SELECT last_insert_rowid();",
                new
                {
                    raceId,
                    category = clubResult.Category,
                    yearClubId = yearClubs.First(yc => yc.ShortName.Equals(result.Club, StringComparison.InvariantCultureIgnoreCase)).YearClubId,
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

void SaveClubStandings(
    int competitionId,
    int raceId,
    string race,
    IEnumerable<ClubStandings> clubStandings,
    IEnumerable<YearClub> yearClubs,
    SqliteConnection connection,
    SqliteTransaction transaction)
{
    foreach (ClubStandings clubStanding in clubStandings)
    {
        for (int i = 0; i < clubStanding.Standings.Count(); i++)
        {
            ClubStanding standing = clubStanding.Standings.ElementAt(i);

            int clubStandingId = connection.QuerySingle<int>(
                "INSERT INTO ClubStanding (CompetitionId, Category, YearClubId, Position, Total) " +
                "VALUES (@competitionId, @category, @club, @position, @total);" +
                "SELECT last_insert_rowid();",
                new
                {
                    competitionId,
                    category = clubStanding.Category,
                    yearClubId = yearClubs.First(yc => yc.ShortName.Equals(standing.Club, StringComparison.InvariantCultureIgnoreCase)).YearClubId,
                    position = i + 1,
                    total = standing.Total,
                },
                transaction);

            foreach (ClubStandingResult result in standing.Results.Where(r => r.Race == race))
            {
                connection.Execute(
                    "INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points) " +
                    "VALUES (@clubStandingId, @raceId, @points)",
                    new
                    {
                        clubStandingId,
                        raceId,
                        points = result.Points,
                    },
                    transaction);
            }
        }
    }
}
 
ExtractedResults ExtractResults(string inputFile, string competition, int year)
{
    IResultsExtractor resultsExtractor;

    if (competition.Equals("Road", StringComparison.InvariantCultureIgnoreCase))
    {
        resultsExtractor = new ExcelRoadExtractor2024();
    }
    else if (competition.Equals("Fell", StringComparison.InvariantCultureIgnoreCase))
    {
        resultsExtractor = new ExcelFellExtractor2023();
    }
    else
    {
        throw new Exception("Unknown competition");
    }

    using (Stream fileStream = File.OpenRead(inputFile))
    {
        return resultsExtractor.ExtractResults(fileStream);
    }
}