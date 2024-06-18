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

ALTER TABLE CompetitionClubCategory 
RENAME TO ClubCategory;

ALTER TABLE ClubCategory 
RENAME COLUMN CompetitionClubCategoryId TO ClubCategoryId;

ALTER TABLE ClubStanding 
RENAME COLUMN CompetitionClubCategoryId TO ClubCategoryId;

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
    cs.ClubCategoryId,
    ca.CategoryId,
    ca.Category,
    cs.Position,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName,
    cs.Total
FROM ClubStanding cs
INNER JOIN ClubCategory cc
ON cc.ClubCategoryId = cs.ClubCategoryId
INNER JOIN Competition co
ON co.CompetitionId = cc.CompetitionId
INNER JOIN Category ca
ON ca.CategoryId = cc.CategoryId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = cs.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;

DROP TABLE OldClubStanding;

ALTER TABLE ClubWinner 
RENAME TO OldClubWinner;

CREATE TABLE ClubWinner (
    ClubWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    ClubCategoryId INTEGER NOT NULL,
    YearClubId INTEGER NOT NULL, 
    FOREIGN KEY (ClubCategoryId) REFERENCES ClubCategory (ClubCategoryId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(ClubCategoryId, YearClubId)
);

INSERT OR IGNORE INTO ClubCategory (CompetitionId, CategoryId)
SELECT ocw.CompetitionId, c.CategoryId
FROM OldClubWinner ocw
INNER JOIN Category c
ON c.Category = ocw.Category
GROUP BY ocw.CompetitionId, c.CategoryId;

INSERT INTO ClubWinner (ClubWinnerId, ClubCategoryId, YearClubId)
SELECT ocw.ClubWinnerId, cc.ClubCategoryId, ocw.YearClubId
FROM OldClubWinner ocw
INNER JOIN ClubCategory cc
ON cc.CompetitionId = ocw.CompetitionId
INNER JOIN Category c
ON c.CategoryId = cc.CategoryId
AND c.Category = ocw.Category;

DROP VIEW ClubWinnersView;
CREATE VIEW ClubWinnersView
AS
SELECT 
    cw.ClubWinnerId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    cc.ClubCategoryId,
    ca.CategoryId,
    ca.Category,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName
FROM ClubWinner cw
INNER JOIN ClubCategory cc
ON cc.ClubCategoryId = cw.ClubCategoryId
INNER JOIN Competition co
ON co.CompetitionId = cc.CompetitionId
INNER JOIN Category ca
ON ca.CategoryId = cc.CategoryId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = cw.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;

DROP TABLE OldClubWinner;

ALTER TABLE ClubResult
RENAME TO OldClubResult;

CREATE TABLE ClubResult (
    ClubResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RaceId INTEGER NOT NULL,
    ClubCategoryId INTEGER NOT NULL,
    YearClubId INTEGER NOT NULL, 
    Position INTEGER NOT NULL,
    Score INTEGER NOT NULL,
    FOREIGN KEY (RaceId) REFERENCES Race (RaceId),
    FOREIGN KEY (ClubCategoryId) REFERENCES ClubCategory (ClubCategoryId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(RaceId, ClubCategoryId, Position),
    UNIQUE(RaceId, ClubCategoryId, YearClubId)
);

INSERT INTO ClubResult (
    ClubResultId, 
    RaceId, 
    ClubCategoryId, 
    YearClubId, 
    Position, 
    Score)
SELECT 
    ocr.ClubResultId,
    ocr.RaceId,
    cc.ClubCategoryId,
    ocr.YearClubId,
    ocr.Position,
    ocr.Score
FROM OldClubResult ocr
INNER JOIN Race r
ON r.RaceId = ocr.RaceId
INNER JOIN ClubCategory cc
ON cc.CompetitionId = r.CompetitionId
INNER JOIN Category c
ON c.CategoryId = cc.CategoryId
AND c.Category = ocr.Category;

DROP VIEW ClubResultsView;
CREATE VIEW ClubResultsView
AS
SELECT 
    cr.ClubResultId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    r.RaceId,
    r.Name RaceName,
    cc.ClubCategoryId,
    ca.CategoryId,
    ca.Category,
    cr.Position,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName,
    cr.Score
FROM ClubResult cr
INNER JOIN Race r
ON r.RaceId = cr.RaceId
INNER JOIN Competition co
ON co.CompetitionId = r.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = cr.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId
INNER JOIN ClubCategory cc
ON cc.ClubCategoryId = cr.ClubCategoryId
INNER JOIN Category ca
ON ca.CategoryId = cc.CategoryId;
*/