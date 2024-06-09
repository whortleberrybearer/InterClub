INSERT INTO Competition (Competition, Year)
VALUES ("Road", 1985);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 1986);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 1987);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 1988);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 1999);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 2000);

INSERT INTO Competition (Competition, Year)
VALUES ("Road", 2001);

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1985 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1986 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1986 AND Competition = "Road"),
    "Vet",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1987 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1987 AND Competition = "Road"),
    "Vet",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1988 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1988 AND Competition = "Road"),
    "Vet",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1989 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1989 AND Competition = "Road"),
    "Open",
    "Springfields");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1989 AND Competition = "Road"),
    "Vet",
    "Chorley");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1990 AND Competition = "Road"),
    "Open",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1990 AND Competition = "Road"),
    "Vet",
    "Preston");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1991 AND Competition = "Road"),
    "Open",
    "Chorely");

INSERT INTO ClubWinner (CompetitionId, Category, Club)
VALUES (
    (SELECT CompetitionId FROM Competition WHERE Year = 1991 AND Competition = "Road"),
    "Vet",
    "Chorley");