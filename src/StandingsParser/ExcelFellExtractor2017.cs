using OfficeOpenXml;

internal class ExcelFellExtractor2017 : IStandingsExtractor
{
    public ExtractedStandings ExtractStandings(Stream stream)
    {
        using (ExcelPackage excelPackage = new ExcelPackage(stream))
        {
            List<RunnerStandings> runnerStandings = new List<RunnerStandings>();

            foreach (ExcelWorksheet worksheet in excelPackage.Workbook.Worksheets)
            {
                runnerStandings.Add(ExtractRunnerStandings(worksheet));
            }


            return new ExtractedStandings()
            {
                RunnerStandings = runnerStandings,
            };
        }
    }

    private RunnerStandings ExtractRunnerStandings(ExcelWorksheet worksheet)
    {
        List<RunnerStanding> runnerStandings = new List<RunnerStanding>();

        for (int rowIndex = 2; rowIndex <= worksheet.Dimension.End.Row; rowIndex++)
        {
            if (string.IsNullOrWhiteSpace(worksheet.Cells[rowIndex, 2].Text))
            {
                break;
            }

            runnerStandings.Add(ExtractRunnerStanding(worksheet, rowIndex));
        }

        return new RunnerStandings()
        {
            Category = worksheet.Name,
            Standings = runnerStandings,
        };
    }

    private RunnerStanding ExtractRunnerStanding(ExcelWorksheet worksheet, int rowIndex)
    {
        string name = ExcelParser.ParseString(worksheet.Cells[rowIndex, 2])!;
        string? sexAndCategory = ExcelParser.ParseString(worksheet.Cells[rowIndex, 4])!;
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
                .Replace("F", string.Empty, StringComparison.InvariantCultureIgnoreCase)
                .Replace("V", string.Empty, StringComparison.InvariantCultureIgnoreCase);

            if (string.IsNullOrWhiteSpace(sexAndCategory))
            {
                category = "SEN";
            }
            else if (int.TryParse(sexAndCategory, out int result))
            {
                category = "V" + result.ToString();
            }
        }

        return new RunnerStanding()
        {
            Position = ExcelParser.ParseNumber(worksheet.Cells[rowIndex, 1]).GetValueOrDefault(),
            Name = name.Split(" ").First(),
            Surname = name.Substring(name.IndexOf(" ") + 1),
            Sex = sex,
            Category = category,
            Club = ExcelParser.ParseString(worksheet.Cells[rowIndex, 3])!,
            Total = ExcelParser.ParseNumber(worksheet.Cells[rowIndex, 9]).GetValueOrDefault(),
            Qualified = null,
            Results = ExtractResults(worksheet, rowIndex),
        };
    }

    private IEnumerable<RunnerStandingResult> ExtractResults(ExcelWorksheet worksheet, int rowIndex)
    {
        List<RunnerStandingResult> results = new List<RunnerStandingResult>();

        for (int columnIndex = 5; columnIndex <= 8; columnIndex++)
        {
            int? points = ExcelParser.ParseNumber(worksheet.Cells[rowIndex, columnIndex]);

            if (!points.HasValue)
            {
                continue;
            }

            RunnerStandingResult result = new RunnerStandingResult()
            {
                Race = ExcelParser.ParseString(worksheet.Cells[1, columnIndex])!,
                Points = points.Value,
                Scoring = null,
            };

            results.Add(result);
        }

        return results;
    }
}