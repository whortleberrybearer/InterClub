INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Open"),
    (SELECT ClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Female"),
    (SELECT ClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet"),
    (SELECT ClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet 50"),
    (SELECT ClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2022 AND CompetitionType = "Fell" AND Category = "Vet 60"),
    (SELECT ClubId FROM YearClubsView WHERE Year = 2022 AND ShortName = "Chorley"));
/*
INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male",
    "Alek",
    "Walker",
    "Wesham",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male",
    "Christopher",
    "Bridge",
    "Red Rose",
    3);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 40",
    "David",
    "Cowburn",
    "Chorley",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 40",
    "Steve",
    "Myerscough",
    "Wesham",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 50",
    "Darren",
    "McDermott",
    "Preston",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 50",
    "Carl",
    "Groome",
    "Wesham",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 60",
    "Steve",
    "Baker",
    "Chorley",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Male Vet 60",
    "Philip",
    "Butler",
    "Red Rose",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Female",
    "Kay",
    "Twist",
    "Wesham",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Female",
    "Julia",
    "Rolfe",
    "Lytham",
    3);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Female Vet 40",
    "Olga",
    "Wiggins",
    "Preston",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM CompetitionsView WHERE Year = 2022 AND CompetitionType = "Fell"),
    "Female Vet 50",
    "Claire",
    "McDermott",
    "Preston",
    1);*/