INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Open"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Vet"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Vet 50"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Vet 60"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"));

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male"),
    "Richard",
    "Smith",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male"),
    "Jon",
    "Green",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male"),
    "Simon",
    "Collins",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "Jon",
    "Green",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 40"),
    "Andy",
    "Whaley",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "John",
    "Rainford",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 50"),
    "Frank",
    "Nightingale",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 60"),
    "Peter",
    "Singleton",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Blackpool"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Male Vet 60"),
    "Alan",
    "Appleby",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female"),
    "Vicki",
    "Sherrington",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female"),
    "Olga",
    "Wiggins",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female"),
    "Alison",
    "Mercer",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"),
    3);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Vicki",
    "Sherrington",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Preston"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female Vet 40"),
    "Debbie",
    "Porter",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"),
    2);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Alison",
    "Mercer",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"),
    1);

INSERT INTO RunnerWinner (RunnerCategoryId, Name, Surname, YearClubId, Position)
VALUES 
    ((SELECT RunnerCategoryId FROM RunnerCategoriesView WHERE Year = 2018 AND CompetitionType = "Fell" AND Category = "Female Vet 50"),
    "Lynn",
    "Melvin",
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2018 AND ShortName = "Red Rose"),
    2);