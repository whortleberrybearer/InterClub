using Cocona;
using OfficeOpenXml;

// Needs to be set to avoid license exception.
ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

CoconaApp.Run(([Option("i")] string inputFile, [Option("o")] string outputPath, int year, string competition, string race) =>
{
    ExtractedResults extractedResults = ExtractResults(inputFile);

    if (extractedResults.RaceResults is not null)
    {
        IRaceResultsRepository raceResultsRepository = new RaceResultsRepository(outputPath);

        raceResultsRepository.Save(year, competition, race, extractedResults.RaceResults);
    }

    if (extractedResults.ClubResults is not null)
    {
        IClubResultsRepository clubResultsRepository = new ClubResultsRepository(outputPath);

        clubResultsRepository.Save(year, competition, race, extractedResults.ClubResults);
    }

    if (extractedResults.ClubStandings is not null)
    {
        IClubStandingsRepository clubStandingsRepository = new ClubStandingsRepository(outputPath);

        clubStandingsRepository.Save(year, competition, extractedResults.ClubStandings);
    }
});

ExtractedResults ExtractResults(string inputFile)
{
    IResultsExtractor resultsExtractor = new ExcelRoadExtractor2024();

    using (Stream fileStream = File.OpenRead(inputFile))
    {
        return resultsExtractor.ExtractResults(fileStream);
    }
}