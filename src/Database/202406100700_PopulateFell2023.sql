INSERT INTO Competition (Competition, Year)
VALUES ("Fell", 2023);

INSERT INTO Race (Name, CompetitionId)
SELECT "Wardle Skyline", CompetitionId
FROM Competition 
WHERE Competition = "Fell"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Aggies Staircase", CompetitionId
FROM Competition 
WHERE Competition = "Fell"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Beetham Sports", CompetitionId
FROM Competition 
WHERE Competition = "Fell"
AND Year = 2023;

INSERT INTO Race (Name, CompetitionId)
SELECT "Golf Ball", CompetitionId
FROM Competition 
WHERE Competition = "Fell"
AND Year = 2023;