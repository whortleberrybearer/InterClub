INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Open"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet 50"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet 60"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male"),
    "Darren",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male"),
    "Steve",
    "Baker",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male"),
    "Paul",
    "Lancashire",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Wesham"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "John",
    "Naylor",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Red Rose"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "Paul",
    "Lancashire",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Wesham"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "Darren",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "Mark",
    "Ellithorn",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Male Vet 60"),
    "Steve",
    "Baker",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female"),
    "Claire",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female"),
    "Claire",
    "Markham",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Lytham"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female"),
    "Amanda",
    "Fuller",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Blackpool"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Claire",
    "Markham",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Lytham"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Olga",
    "Wiggins",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Claire",
    "McDermott",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Pamela",
    "Hardman",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Lytham"),
    2);