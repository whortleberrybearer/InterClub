INSERT INTO Competition (Competition, Year)
VALUES ("Road", 2023);

INSERT INTO Race (Name, CompetitionId)
SELECT "Blackpool", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Lytham", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Preston", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Thornton", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Wesham", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Chorley", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Red Rose", CompetitionId
FROM Competition 
WHERE Competition = "Road"
AND Year = 2023;