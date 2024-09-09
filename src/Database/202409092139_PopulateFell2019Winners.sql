INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Open"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Vet"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Vet 50"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Vet 60"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"));

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male"),
    "Daniel",
    "Hughes",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male"),
    "Barry",
    "Wheeler",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male"),
    "Stephen",
    "Woodruff",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "Neil",
    "Whipp",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Wesham"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "Chris",
    "Charnley",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "Stephen",
    "Woodruff",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "Frank",
    "Nightingale",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Male Vet 60"),
    "Graham",
    "Schofield",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Chorley"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female"),
    "Nicola",
    "Hughes",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female"),
    "Vicki",
    "Sherrington",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female"),
    "Paula",
    "Plowman",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Vicki",
    "Sherrington",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Amanda",
    "Fuller",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Blackpool"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2019 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Paula",
    "Plowman",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2019 AND ShortName = "Red Rose"),
    1);