/*
DROP TABLE IF EXISTS Category;

CREATE TABLE Category (
    CategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
    Category VARCHAR(25) NOT NULL,
    UNIQUE(Category)
);

INSERT INTO Category (Category)
SELECT DISTINCT(Category)
FROM ClubCategoryResult
UNION
SELECT DISTINCT(Category)
FROM ClubResult
UNION 
SELECT DISTINCT(Category)
FROM ClubStanding
UNION
SELECT DISTINCT(Category)
FROM ClubWinner
UNION
SELECT DISTINCT(RunnerCategory)
FROM RunnerStanding
UNION
SELECT DISTINCT(Category)
FROM RunnerWinner;

CREATE TABLE CompetitionClubCategory (
    CompetitionClubCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    CategoryId INTEGER NOT NULL,
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (CategoryId) REFERENCES Category (CategoryId), 
    UNIQUE(CompetitionId, CategoryId)
);

INSERT INTO CompetitionClubCategory (CompetitionId, CategoryId)
SELECT cs.CompetitionId, ca.CategoryId
FROM ClubStanding cs
INNER JOIN Category ca
ON ca.Category = cs.Category
GROUP BY cs.CompetitionId, ca.Category;

ALTER TABLE ClubStanding 
RENAME TO OldClubStanding;

CREATE TABLE ClubStanding (
    ClubStandingId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionClubCategoryId INTEGER NOT NULL,
    YearClubId INTEGER NOT NULL, 
    Position INTEGER NOT NULL,
    Total INTEGER NOT NULL,
    FOREIGN KEY (CompetitionClubCategoryId) REFERENCES CompetitionClubCategory (CompetitionClubCategoryId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(CompetitionClubCategoryId, YearClubId),
    UNIQUE(CompetitionClubCategoryId, Position)
);

INSERT INTO ClubStanding (
    ClubStandingId,
    CompetitionClubCategoryId,
    YearClubId,
    Position,
    Total)
SELECT 
    ocs.ClubStandingId,
    ccc.CompetitionClubCategoryId,
    ocs.YearClubId,
    ocs.Position,
    ocs.Total
FROM OldClubStanding ocs
INNER JOIN CompetitionClubCategory ccc
ON ccc.CompetitionId = ocs.CompetitionId
INNER JOIN Category c
ON c.CategoryId = ccc.CategoryId
AND ocs.Category = c.Category;

DROP VIEW ClubStandingsView;
CREATE VIEW ClubStandingsView
AS
SELECT 
    cs.ClubStandingId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    cs.CompetitionClubCategoryId,
    ca.CategoryId,
    ca.Category,
    cs.Position,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName,
    cs.Total
FROM ClubStanding cs
INNER JOIN CompetitionClubCategory ccc
ON ccc.CompetitionClubCategoryId = cs.CompetitionClubCategoryId
INNER JOIN Competition co
ON co.CompetitionId = ccc.CompetitionId
INNER JOIN Category ca
ON ca.CategoryId = ccc.CategoryId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = cs.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;
*/