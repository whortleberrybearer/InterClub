INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2023 AND CompetitionType = "Fell" AND Category = "Male"),
    "Darren",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2023 AND CompetitionType = "Fell" AND Category = "Female"),
    "Claire",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2023 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Kay",
    "Twist",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham"),
    2);