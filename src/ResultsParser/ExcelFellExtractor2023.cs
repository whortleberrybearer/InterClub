using OfficeOpenXml;

internal class ExcelFellExtractor2023 : IResultsExtractor
{
    public ExtractedResults ExtractResults(Stream stream)
    {
        using (ExcelPackage excelPackage = new ExcelPackage(stream))
        {
            ExcelWorksheet positionsWorksheet =
                excelPackage.Workbook.Worksheets["Positions."] ??  // Some docs have it named differently because a duplicate tab.
                excelPackage.Workbook.Worksheets["Positions"] ?? 
                throw new Exception("Positions worksheet missing");
            ExcelWorksheet teamPositionsWorksheet = excelPackage.Workbook.Worksheets["Team Positions"] ?? throw new Exception("Team Positions worksheet missing");
            ExcelWorksheet teamScorersWorksheet = excelPackage.Workbook.Worksheets["Team Scorers"] ?? throw new Exception("Team Scorers worksheet missing");
            ExcelWorksheet seasonTotalsWorksheet = excelPackage.Workbook.Worksheets["Season Totals"] ?? throw new Exception("Season Totals worksheet missing");

            IEnumerable<RaceResult> raceResults = ExtractRaceResults(positionsWorksheet);

            ClubStandings?[] clubStandings = new ClubStandings?[]
            {
                ExtractClubStandings(ClubCategoryNames.Open, seasonTotalsWorksheet, 4),
                ExtractClubStandings(ClubCategoryNames.Female, seasonTotalsWorksheet, 13),
                ExtractClubStandings(ClubCategoryNames.Vet, seasonTotalsWorksheet, 31),
                ExtractClubStandings(ClubCategoryNames.Vet50, seasonTotalsWorksheet, 40),
                ExtractClubStandings(ClubCategoryNames.Vet60, seasonTotalsWorksheet, 49)
            };

            return new ExtractedResults()
            {
                RaceResults = raceResults,
                ClubResults = new ClubResults[]
                {
                    ExtractClubResults(ClubCategoryNames.Open, teamPositionsWorksheet, 1, 3, 9, teamScorersWorksheet, 2, raceResults),
                    ExtractClubResults(ClubCategoryNames.Female, teamPositionsWorksheet, 1, 23, 29, teamScorersWorksheet, 15, raceResults),
                    ExtractClubResults(ClubCategoryNames.Vet, teamPositionsWorksheet, 4, 3, 9, teamScorersWorksheet, 31, raceResults),
                    ExtractClubResults(ClubCategoryNames.Vet50, teamPositionsWorksheet, 1, 13, 19, teamScorersWorksheet, 40, raceResults),
                    ExtractClubResults(ClubCategoryNames.Vet60, teamPositionsWorksheet, 4, 13, 19, teamScorersWorksheet, 47, raceResults)
                },
                ClubStandings = clubStandings.Any(cs => cs is not null) ? clubStandings.Select(cs => cs!) : null,
            };
        }
    }

    private static IEnumerable<RaceResult> ExtractRaceResults(ExcelWorksheet positionsWorksheet)
    {
        List<RaceResult> raceResults = new List<RaceResult>();

        for (int rowIndex = 4; rowIndex <= positionsWorksheet.Dimension.End.Row; rowIndex++)
        {
            // If the position is not set, this must be the end of the file.
            if (string.IsNullOrWhiteSpace(positionsWorksheet.Cells[rowIndex, 2].Value?.ToString()) &&
                string.IsNullOrWhiteSpace(positionsWorksheet.Cells[rowIndex + 1, 2].Value?.ToString()))
            {
                break;
            }

            raceResults.Add(ExtractRaceResult(positionsWorksheet, rowIndex));
        }

        return raceResults;
    }

    private static RaceResult ExtractRaceResult(ExcelWorksheet positionsWorksheet, int rowIndex)
    {
        string? sexAndCategory = ExcelParser.ParseString(positionsWorksheet.Cells[rowIndex, 11]);
        string? sex = null;
        string? category = null;

        if (sexAndCategory is not null)
        {
            if (sexAndCategory.StartsWith("M", StringComparison.InvariantCultureIgnoreCase))
            {
                sex = "M";
            }
            else if (sexAndCategory.StartsWith("F", StringComparison.InvariantCultureIgnoreCase))
            {
                sex = "F";
            }

            sexAndCategory = sexAndCategory
                .Replace("M", string.Empty, StringComparison.InvariantCultureIgnoreCase)
                .Replace("F", string.Empty, StringComparison.InvariantCultureIgnoreCase);

            if ((string.IsNullOrWhiteSpace(sexAndCategory)) ||
                (sexAndCategory.Equals("S", StringComparison.InvariantCultureIgnoreCase)) ||
                (sexAndCategory.Equals("SEN", StringComparison.InvariantCultureIgnoreCase)))
            {
                category = "SEN";
            }
            else if (int.TryParse(sexAndCategory, out int result)) 
            {
                 category = "V" + result.ToString();
            }
        }

        return new RaceResult()
        {
            RunnerNumber = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 1]),
            Position = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 2]).GetValueOrDefault(),
            Name = ExcelParser.ParseString(positionsWorksheet.Cells[rowIndex, 9]),
            Surname = ExcelParser.ParseString(positionsWorksheet.Cells[rowIndex, 10]),
            Category = category,
            Sex = sex,
            Club = ExcelParser.ParseString(positionsWorksheet.Cells[rowIndex, 14]),
            Time = ExcelParser.ParseTime(positionsWorksheet.Cells[rowIndex, 15]),
            Comments = ExcelParser.ParseString(positionsWorksheet.Cells[rowIndex, 16]),
            ClubCategoryResults = ExtractClubCategoryResults(positionsWorksheet, rowIndex),
        };
    }

    private static IEnumerable<ClubCategoryResult> ExtractClubCategoryResults(ExcelWorksheet positionsWorksheet, int rowIndex)
    {
        List<ClubCategoryResult> clubCategoryResults = new List<ClubCategoryResult>();

        int? openPosition = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 3]);

        if (openPosition.HasValue)
        {
            clubCategoryResults.Add(new ClubCategoryResult()
            {
                Category = ClubCategoryNames.Open,
                Position = openPosition.Value,
            });

            int? femalePosition = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 7]);

            if (femalePosition.HasValue)
            {
                clubCategoryResults.Add(new ClubCategoryResult()
                {
                    Category = ClubCategoryNames.Female,
                    Position = femalePosition.Value,
                });
            }

            int? vetPosition = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 4]);

            if (vetPosition.HasValue)
            {
                clubCategoryResults.Add(new ClubCategoryResult()
                {
                    Category = ClubCategoryNames.Vet,
                    Position = vetPosition.Value,
                });

                int? vet50Position = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 5]);

                if (vet50Position.HasValue)
                {
                    clubCategoryResults.Add(new ClubCategoryResult()
                    {
                        Category = ClubCategoryNames.Vet50,
                        Position = vet50Position.Value,
                    });

                    int? vet60Position = ExcelParser.ParseNumber(positionsWorksheet.Cells[rowIndex, 6]);

                    if (vet60Position.HasValue)
                    {
                        clubCategoryResults.Add(new ClubCategoryResult()
                        {
                            Category = ClubCategoryNames.Vet60,
                            Position = vet60Position.Value,
                        });
                    }
                }
            }
        }

        return clubCategoryResults;
    }

    private static ClubResults ExtractClubResults(
        string category,
        ExcelWorksheet teamPositionsWorksheet,
        int teamPositionsColumnIndex,
        int teamPositionsStartRowIndex,
        int teamPositionsEndRowIndex,
        ExcelWorksheet teamScorersWorksheet,
        int teamScorersRowIndex,
        IEnumerable<RaceResult> raceResults)
    {
        List<ClubResult> clubResults = new List<ClubResult>();

        for (int rowIndex = teamPositionsStartRowIndex; rowIndex <= teamPositionsEndRowIndex; rowIndex++)
        {
            clubResults.Add(ExtractClubResult(teamPositionsWorksheet, teamPositionsColumnIndex, rowIndex, teamScorersWorksheet, teamScorersRowIndex, raceResults, category));
        }

        return new ClubResults()
        {
            Category = category,
            Results = clubResults,
        };
    }

    private static ClubResult ExtractClubResult(
        ExcelWorksheet teamPositionsWorksheet,
        int teamPositionsColumnIndex,
        int teamPositionsRowIndex,
        ExcelWorksheet teamScorersWorksheet,
        int teamScorersRowIndex,
        IEnumerable<RaceResult> raceResults,
        string category)
    {
        string clubName = ExcelParser.ParseString(teamPositionsWorksheet.Cells[teamPositionsRowIndex, teamPositionsColumnIndex])!;

        // Need to find the matching column for the scorers based on the club name.
        int teamScorersColumnIndex = 0;

        for (int columnIndex = 4; columnIndex <= 16; columnIndex++)
        {
            if (teamScorersWorksheet.Cells[1, columnIndex].Text == clubName)
            {
                teamScorersColumnIndex = columnIndex;

                break;
            }
        }

        return new ClubResult()
        {
            Club = clubName,
            Score = ExcelParser.ParseNumber(teamPositionsWorksheet.Cells[teamPositionsRowIndex, teamPositionsColumnIndex + 1]).GetValueOrDefault(),
            Scorers = ExtractTeamScorers(teamScorersWorksheet, teamScorersColumnIndex, teamScorersRowIndex, raceResults, category),
        };
    }

    private static IEnumerable<TeamScorer> ExtractTeamScorers(
        ExcelWorksheet teamScorersWorksheet,
        int teamScorersColumnIndex,
        int teamScorersRowIndex,
        IEnumerable<RaceResult> raceResults,
        string category)
    {
        List<TeamScorer> teamScorers = new List<TeamScorer>();

        // The largest team size is 10, so only scan that may rows.
        for (int rowIndex = teamScorersRowIndex; rowIndex <= teamScorersRowIndex + 10; rowIndex++)
        {
            // The names in the sheet are initial + surname, so need to split that out and re-popular the name at a later point.
            int? position = ExcelParser.ParseNumber(teamScorersWorksheet.Cells[rowIndex, teamScorersColumnIndex - 1]);

            if (!position.HasValue)
            {
                break;
            }

            RaceResult? raceResult = FindRaceResult(category, position.Value, raceResults);

            if (raceResult is null)
            {
                throw new Exception("Result not found");
            }

            TeamScorer teamScorer = new TeamScorer()
            {
                Position = position.Value,
                Name = raceResult.Name,
                Surname = raceResult.Surname,
                Result = raceResult,
            };

            teamScorers.Add(teamScorer);
        }

        return teamScorers;
    }

    private static RaceResult? FindRaceResult(string category, int position, IEnumerable<RaceResult> raceResults)
    {
        foreach (RaceResult raceResult in raceResults)
        {
            ClubCategoryResult? clubCategoryResult = raceResult.ClubCategoryResults.FirstOrDefault(ccr => ccr.Category == category);

            if (clubCategoryResult?.Position == position)
            {
                return raceResult;
            }
        }

        return null;
    }

    private static ClubStandings? ExtractClubStandings(string category, ExcelWorksheet seasonTotalsWorksheet, int startRowIndex)
    {
        List<ClubStanding> clubStandings = new List<ClubStanding>();

        for (int rowIndex = startRowIndex; rowIndex < startRowIndex + 7; rowIndex++)
        {
            // If there are no details, no standings are populated.
            if (ExcelParser.ParseString(seasonTotalsWorksheet.Cells[rowIndex, 1]) is null)
            {
                return null;
            }

            clubStandings.Add(ExtractClubStanding(seasonTotalsWorksheet, rowIndex));
        }

        return new ClubStandings()
        { 
            Category = category,
            Standings = clubStandings,
        };
    }

    private static ClubStanding ExtractClubStanding(ExcelWorksheet seasonTotalsWorksheet, int rowIndex)
    {
        List<ClubStandingResult> results = new List<ClubStandingResult>();

        for (int columnIndex = 2; columnIndex <= 5; columnIndex++)
        {
            int? point = ExcelParser.ParseNumber(seasonTotalsWorksheet.Cells[rowIndex, columnIndex]);

            // Once we find no points, we have found the end so can stop checking.
            if (point is null)
            {
                break;
            }

            results.Add(new ClubStandingResult()
            {
                Race = ExcelParser.ParseString(seasonTotalsWorksheet.Cells[1, columnIndex])!,
                Points = point.Value,
            });
        }

        return new ClubStanding()
        {
            Club = ExcelParser.ParseString(seasonTotalsWorksheet.Cells[rowIndex, 1])!,
            Total = ExcelParser.ParseNumber(seasonTotalsWorksheet.Cells[rowIndex, 6]).GetValueOrDefault(),
            Results = results,
        };
    }
}