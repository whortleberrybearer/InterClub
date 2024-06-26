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

DROP TABLE OldClubResult;

ALTER TABLE ClubStandingResult
RENAME TO OldClubStandingResult;

CREATE TABLE ClubStandingResult (
    ClubStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    ClubStandingId INTEGER NOT NULL,
    RaceId INTEGER NOT NULL,
    Points INTEGER NOT NULL,
    UNIQUE(ClubStandingId, RaceId)
);

INSERT INTO ClubStandingResult (
    ClubStandingResultId,
    ClubStandingId,
    RaceId,
    Points)
SELECT 
    ocsr.ClubStandingResultId,
    ocsr.ClubStandingId,
    ocsr.RaceId,
    ocsr.Points
FROM OldClubStandingResult ocsr;

DROP TABLE OldClubStandingResult;

ALTER TABLE ClubCategoryResult
RENAME TO OldClubCategoryResult;

CREATE TABLE ClubCategoryResult (
    ClubCategoryResult INTEGER PRIMARY KEY AUTOINCREMENT,
    RaceResultId INTEGER NOT NULL,
    ClubCategoryId INTEGER NOT NULL,
    Position INTEGER NOT NULL,
    FOREIGN KEY (RaceResultId) REFERENCES RaceResult (RaceResultId),
    FOREIGN KEY (ClubCategoryId) REFERENCES ClubCategory (ClubCategoryId), 
    UNIQUE(RaceResultId, ClubCategoryId, Position)
);

INSERT INTO ClubCategoryResult (
    ClubCategoryResult,
    RaceResultId,
    ClubCategoryId,
    Position)
SELECT 
    occr.ClubCategoryResult,
    occr.RaceResultId,
    cc.ClubCategoryId,
    occr.Position
FROM OldClubCategoryResult occr
INNER JOIN RaceResult rr
ON rr.RaceResultId = occr.RaceResultId
INNER JOIN Race r
ON r.RaceId = rr.RaceId
INNER JOIN ClubCategory cc
ON cc.CompetitionId = r.CompetitionId
INNER JOIN Category c
ON c.CategoryId = cc.CategoryId
AND c.Category = occr.Category;

ALTER TABLE ClubCategoryResult
RENAME COLUMN ClubCategoryResult TO ClubCategoryResultId;

DROP TABLE OldClubCategoryResult;

ALTER TABLE ClubStandingResult
RENAME TO OldClubStandingResult;

CREATE TABLE ClubStandingResult (
    ClubStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    ClubStandingId INTEGER NOT NULL,
    RaceId INTEGER NOT NULL,
    Points INTEGER NOT NULL,
    FOREIGN KEY (ClubStandingId) REFERENCES ClubStanding (ClubStandingId),
    FOREIGN KEY (RaceId) REFERENCES Race (RaceId), 
    UNIQUE(ClubStandingId, RaceId)
);

INSERT INTO ClubStandingResult (
    ClubStandingResultId,
    ClubStandingId,
    RaceId,
    Points)
SELECT 
    ocsr.ClubStandingResultId,
    ocsr.ClubStandingId,
    ocsr.RaceId,
    ocsr.Points
FROM OldClubStandingResult ocsr;

DROP TABLE OldClubStandingResult;

CREATE TABLE RunnerCategory (
    RunnerCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    CategoryId INTEGER NOT NULL,
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (CategoryId) REFERENCES Category (CategoryId), 
    UNIQUE(CompetitionId, CategoryId)
);

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT rw.CompetitionId, ca.CategoryId
FROM RunnerWinner rw
INNER JOIN Category ca
ON ca.Category = rw.Category
GROUP BY rw.CompetitionId, ca.Category;

ALTER TABLE RunnerWinner 
RENAME TO OldRunnerWinner;

CREATE TABLE RunnerWinner (
    RunnerWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    RunnerCategoryId INTEGER NOT NULL,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    YearClubId INTEGER NOT NULL, 
    Position INTEGER NOT NULL,
    FOREIGN KEY (RunnerCategoryId) REFERENCES RunnerCategory (RunnerCategoryId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(RunnerCategoryId, Position)
);

INSERT INTO RunnerWinner (
    RunnerWinnerId, 
    RunnerCategoryId, 
    Name, 
    Surname, 
    YearClubId, 
    Position)
SELECT 
    orw.RunnerWinnerId, 
    rc.RunnerCategoryId, 
    orw.Name, 
    orw.Surname, 
    orw.YearClubId, 
    orw.Position
FROM OldRunnerWinner orw
INNER JOIN Competition co
ON co.CompetitionId = orw.CompetitionId
INNER JOIN Category ca
ON ca.Category = orw.Category
INNER JOIN RunnerCategory rc
ON rc.CompetitionId = co.CompetitionId
AND rc.CategoryId = ca.CategoryId;

DROP TABLE OldRunnerWinner;

DROP VIEW RunnerWinnersView;
CREATE VIEW RunnerWinnersView
AS
SELECT 
    rw.RunnerWinnerId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    rc.RunnerCategoryId,
    ca.CategoryId,
    ca.Category,
    rw.Position,
    rw.Name,
    rw.Surname,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName
FROM RunnerWinner rw
INNER JOIN RunnerCategory rc
ON rc.RunnerCategoryId = rw.RunnerCategoryId
INNER JOIN Category ca
ON ca.CategoryId = rc.CategoryId
INNER JOIN Competition co
ON co.CompetitionId = rc.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = rw.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;

ALTER TABLE RunnerStanding
RENAME TO OldRunnerStanding;

CREATE TABLE RunnerStanding (
    RunnerStandingId INTEGER PRIMARY KEY AUTOINCREMENT,
    RunnerCategoryId INTEGER NOT NULL,
    Name VARCHAR(50) NULL,
    Surname VARCHAR(50) NULL,
    Category VARCHAR(5) NULL,
    Sex VARCHAR(1) NULL,
    YearClubId INTEGER NOT NULL, 
    Position INTEGER NOT NULL,
    Total INTEGER NOT NULL,
    Qualified INTEGER NULL,
    FOREIGN KEY (RunnerCategoryId) REFERENCES RunnerCategory (RunnerCategoryId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId),
    UNIQUE (RunnerCategoryId, Position)
);

INSERT INTO RunnerStanding (
    RunnerStandingId,
    RunnerCategoryId,
    Name,
    Surname, 
    Category, 
    Sex, 
    YearClubId, 
    Position, 
    Total,
    Qualified)
SELECT 
    ors.RunnerStandingId, 
    rc.RunnerCategoryId, 
    ors.Name, 
    ors.Surname, 
    ors.Category, 
    ors.Sex, 
    ors.YearClubId, 
    ors.Position, 
    ors.Total, 
    ors.Qualified
FROM OldRunnerStanding ors
INNER JOIN Competition co
ON co.CompetitionId = ors.CompetitionId
INNER JOIN Category ca
ON ca.Category = ors.RunnerCategory
INNER JOIN RunnerCategory rc
ON rc.CompetitionId = co.CompetitionId
AND rc.CategoryId = ca.CategoryId;

DROP VIEW RunnerStandingsView;
CREATE VIEW RunnerStandingsView
AS
SELECT 
    rs.RunnerStandingId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    rc.RunnerCategoryId,
    ca.CategoryId,
    ca.Category,
    rs.Position,
    rs.Name,
    rs.Surname,
    rs.Sex,
    rs.Category AgeCategory,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName,
    rs.Total,
    rs.Qualified
FROM RunnerStanding rs
INNER JOIN RunnerCategory rc
ON rs.RunnerCategoryId = rc.RunnerCategoryId
INNER JOIN Category ca
ON ca.CategoryId = rc.CategoryId
INNER JOIN Competition co
ON co.CompetitionId = rc.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = rs.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;

ALTER TABLE RunnerStandingResult
RENAME TO OldRunnerStandingResult;

CREATE TABLE RunnerStandingResult (
    RunnerStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RunnerStandingId INTEGER NOT NULL,
    RaceId INTEGER NOT NULL,
    Points INTEGER NOT NULL,
    Scoring INTEGER NULL,
    FOREIGN KEY (RunnerStandingId) REFERENCES RunnerStanding (RunnerStandingId),
    FOREIGN KEY (RaceId) REFERENCES Race (RaceId),
    UNIQUE (RunnerStandingId, RaceId)
);

INSERT INTO RunnerStandingResult (
    RunnerStandingResultId, 
    RunnerStandingId, 
    RaceId, 
    Points, 
    Scoring)
SELECT 
    orsr.RunnerStandingResultId, 
    orsr.RunnerStandingId, 
    orsr.RaceId, 
    orsr.Points, 
    orsr.Scoring
FROM OldRunnerStandingResult orsr;

DROP TABLE OldRunnerStanding;
DROP TABLE OldRunnerStandingResult;
