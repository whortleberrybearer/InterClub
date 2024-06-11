INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Open",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Female",
    "Red Rose");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Vet",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Vet 50",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Vet 60",
    "Red Rose");

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male",
    "Alek",
    "Walker",
    "Wesham",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male",
    "Christopher",
    "Bridge",
    "Red Rose",
    3);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 40",
    "David",
    "Cowburn",
    "Chorley",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 40",
    "Steve",
    "Myerscough",
    "Wesham",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 50",
    "Darren",
    "McDermott",
    "Preston",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 50",
    "Carl",
    "Groome",
    "Wesham",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 60",
    "Steve",
    "Baker",
    "Chorley",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Male Vet 60",
    "Philip",
    "Butler",
    "Red Rose",
    2);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Female",
    "Kay",
    "Twist",
    "Wesham",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Female",
    "Julia",
    "Rolfe",
    "Lytham",
    3);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Female Vet 40",
    "Olga",
    "Wiggins",
    "Preston",
    1);

INSERT INTO RunnerWinner (CompetitionId, Category, Name, Surname, Club, Position)
VALUES 
    ((SELECT CompetitionId FROM Competition WHERE Year = 2023 AND Competition = "Fell"),
    "Female Vet 50",
    "Claire",
    "McDermott",
    "Preston",
    1);