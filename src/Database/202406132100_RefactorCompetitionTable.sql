DROP TABLE IF EXISTS Year;
DROP TABLE IF EXISTS CompetitionType;

CREATE TABLE Year (
    YearId INTEGER PRIMARY KEY AUTOINCREMENT,
    Year INTEGER UNIQUE NOT NULL,
    Cancelled INTEGER NOT NULL DEFAULT(0),
    Comment VARCHAR(50) NULL
);

INSERT INTO Year (Year)
SELECT DISTINCT(Year)
FROM Competition;

CREATE TABLE CompetitionType (
    CompetitionTypeId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionType VARCHAR(5) UNIQUE NOT NULL
);

INSERT INTO CompetitionType (CompetitionType)
SELECT DISTINCT(Competition)
FROM Competition;

ALTER TABLE Competition 
RENAME TO OldCompetition;

CREATE TABLE Competition (
    CompetitionId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionTypeId INTEGER NOT NULL,
    YearId INTEGER NOT NULL,
    FOREIGN KEY (CompetitionTypeId) REFERENCES CompetitionType (CompetitionTypeId), 
    FOREIGN KEY (YearId) REFERENCES Year (YearId),
    UNIQUE(CompetitionTypeId, YearId)
);

-- There are some duplcate competitions due to incorrect population.
DELETE FROM OldCompetition
WHERE CompetitionId IN (
    SELECT oc.CompetitionId
    FROM OldCompetition oc
    LEFT OUTER JOIN ClubWinner cw
    ON oc.CompetitionId = cw.CompetitionId
    WHERE cw.ClubWinnerId IS NULL
    AND Year < 2023);

INSERT INTO Competition (CompetitionId, CompetitionTypeId, YearId)
SELECT oc.CompetitionId, ct.CompetitionTypeId, y.YearId
FROM OldCompetition oc
INNER JOIN CompetitionType ct
ON oc.Competition = ct.CompetitionType
INNER JOIN Year y
ON oc.Year = y.Year;

DROP TABLE OldCompetition;

CREATE VIEW CompetitionsView
AS
SELECT 
    c.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    y.Cancelled,
    y.Comment
FROM Competition c
INNER JOIN CompetitionType ct
ON c.CompetitionTypeId = ct.CompetitionTypeId
INNER JOIN Year y
ON c.YearId = y.YearId;

INSERT INTO Year (Year)
VALUES (2020), (2021);

UPDATE Year
SET Cancelled = 1,
    Comment = "Cancelled due to Covid"
WHERE Year IN (2020, 2021);

INSERT INTO Competition (CompetitionTypeId, YearId)
SELECT CompetitionTypeId, YearId
FROM CompetitionType, Year
WHERE CompetitionType = "Fell"
AND Year >= 2010 AND Year < 2023;

INSERT INTO Year (Year)
VALUES (1989), (1990), (1991);

INSERT INTO Competition (CompetitionTypeId, YearId)
SELECT CompetitionTypeId, YearId
FROM CompetitionType, Year
WHERE CompetitionType = "Road"
AND Year >= 1989 AND Year < 1992;

DELETE FROM Competition
WHERE YearId IN (
    SELECT YearId
    FROM Year
    WHERE Cancelled = 1);

DROP VIEW CompetitionsView;
CREATE VIEW CompetitionsView
AS
SELECT 
    c.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year
FROM Competition c
INNER JOIN CompetitionType ct
ON c.CompetitionTypeId = ct.CompetitionTypeId
INNER JOIN Year y
ON c.YearId = y.YearId;