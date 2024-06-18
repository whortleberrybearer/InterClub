using Cocona;
using Dapper;
using Microsoft.Data.Sqlite;
using OfficeOpenXml;
using System.Diagnostics;
using System.Xml.Linq;

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
            IEnumerable<Race> races = connection.Query<Race>(
                "SELECT RaceId, Name " +
                "FROM Race " +
                "WHERE CompetitionId = @competitionId",
                new
                { 
                    competitionId 
                });
            IEnumerable<CompetitionCategory> competitionCategories = connection.Query<CompetitionCategory>(
                "SELECT rc.RunnerCategoryId CompetitionCategoryId, c.Category " +
                "FROM RunnerCategory rc " +
                "INNER JOIN Category c " +
                "ON c.CategoryId = rc.Category" +
                "WHERE rc.CompetitionId = @competitionId",
                new
                {
                    competitionId
                });

            if (extractedStandings.RunnerStandings is not null)
            {
                SaveRunnerStandings(competitionId, extractedStandings.RunnerStandings, connection, transaction, races, yearClubs, competitionCategories);
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

void SaveRunnerStandings(
    int competitionId,
    IEnumerable<RunnerStandings> runnerStandings,
    SqliteConnection connection,
    SqliteTransaction transaction,
    IEnumerable<Race> races,
    IEnumerable<YearClub> yearClubs,
    IEnumerable<CompetitionCategory> competitionCategories)
{
    foreach (RunnerStandings runnerStanding in runnerStandings)
    {
        foreach (RunnerStanding standing in runnerStanding.Standings)
        {
            int runnerStandingId = connection.QuerySingle<int>(
                "INSERT INTO RunnerStanding (RunnerCategoryId, Name, Surname, Category, Sex, YearClubId, Position, Total, Qualified) " +
                "VALUES (@runnerCategoryId, @name, @surname, @category, @sex, @yearClubId, @position, @total, @qualified);" +
                "SELECT last_insert_rowid();",
                new
                {
                    runnerCategoryId = competitionCategories.First(cc => cc.Category.Equals(runnerStanding.Category, StringComparison.InvariantCultureIgnoreCase)),
                    name = standing.Name,
                    surname = standing.Surname,
                    category = standing.Category,
                    sex = standing.Sex,
                    yearClubId = yearClubs.First(yc => yc.ShortName.Equals(standing.Club, StringComparison.InvariantCultureIgnoreCase)).YearClubId,
                    position = standing.Position,
                    total = standing.Total,
                    qualified = standing.Qualified,
                },
            transaction);

            foreach (RunnerStandingResult result in standing.Results)
            {
                connection.Execute(
                    "INSERT INTO RunnerStandingResult (RunnerStandingId, RaceId, Points, Scoring) " +
                    "VALUES (@runnerStandingId, @raceId, @points, @scoring)",
                    new
                    {
                        runnerStandingId,
                        raceId = races.First(r => r.Name.Equals(result.Race, StringComparison.InvariantCultureIgnoreCase)).RaceId,
                        points = result.Points,
                        scoring = result.Scoring,
                    },
                    transaction);
            }
        }
    }
}
