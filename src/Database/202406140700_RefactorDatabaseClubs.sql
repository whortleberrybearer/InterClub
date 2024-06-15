/*DROP TABLE IF EXISTS Club;
DROP TABLE IF EXISTS YearClub;

CREATE TABLE Club (
    ClubId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(50) UNIQUE NOT NULL,
    ShortName VARCHAR(15) NOT NULL,
    Abbreviation VARCHAR(5) NOT NULL
);

INSERT INTO Club (Name, ShortName, Abbreviation)
VALUES 
    ("Chorley AC", "Chorley", "C"),
    ("Preston Harriers & AC", "Preston", "PH"),
    ("Springfields AC", "Springfields", "S"),
    ("Wesham Road Runners", "Wesham", "W"),
    ("North Fylde AC", "North Fylde", "NF"),
    ("Red Rose Road Runners", "Red Rose", "RR"),
    ("Lytham St Annes Road Runners", "Lytham", "L"),
    ("Blackpool & Fylde AC", "Blackpool", "BF"),
    ("Blackpool, Wyre & Fylde AC", "Blackpool", "BWF"),
    ("Chorley Athletic and Triathlon Club", "Chorley", "C"),
    ("Thornton Cleveleys Road Runners", "Thornton", "TC");

CREATE TABLE YearClub (
    YearClubId INTEGER PRIMARY KEY AUTOINCREMENT,
    YearId INTEGER NOT NULL, 
    ClubId INTEGER NOT NULL,
    FOREIGN KEY (YearId) REFERENCES Year (YearId),
    FOREIGN KEY (ClubId) REFERENCES Club (ClubId), 
    UNIQUE(YearId, ClubId)
);

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 1985 AND Year < 1988
AND Name IN (
    "Chorley AC",
    "Preston Harriers & AC",
    "Springfields AC")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 1988 AND Year < 1992
AND Name IN (
    "Chorley AC",
    "Preston Harriers & AC",
    "Springfields AC",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 1992 AND Year < 1993
AND Name IN (
    "Chorley AC",
    "North Fylde AC",
    "Preston Harriers & AC",
    "Springfields AC",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 1993 AND Year < 1995
AND Name IN (
    "Chorley AC",
    "North Fylde AC",
    "Preston Harriers & AC",
    "Springfields AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 1995 AND Year < 2000
AND Name IN (
    "Chorley AC",
    "North Fylde AC",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 2000 AND Year < 2003
AND Name IN (
    "Chorley AC",
    "Lytham St Annes Road Runners",
    "North Fylde AC",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 2003 AND Year < 2007
AND Name IN (
    "Blackpool & Fylde AC",
    "Chorley AC",
    "Lytham St Annes Road Runners",
    "North Fylde AC",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 2007 AND Year < 2012
AND Name IN (
    "Blackpool, Wyre & Fylde AC,",
    "Chorley AC",
    "Lytham St Annes Road Runners",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 2012 AND Year < 2015
AND Name IN (
    "Blackpool, Wyre & Fylde AC,",
    "Chorley Athletic and Triathlon Club",
    "Lytham St Annes Road Runners",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year > 2015
AND Name IN (
    "Blackpool, Wyre & Fylde AC,",
    "Chorley Athletic and Triathlon Club",
    "Lytham St Annes Road Runners",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Thornton Cleveleys Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year >= 2007
AND Name = "Blackpool, Wyre & Fylde AC"
ORDER BY Year;


INSERT INTO YearClub (YearId, ClubId)
SELECT YearId, ClubId
FROM Year, Club
WHERE Year = 2015
AND Name IN (
    "Chorley Athletic and Triathlon Club",
    "Lytham St Annes Road Runners",
    "Preston Harriers & AC",
    "Red Rose Road Runners",
    "Thornton Cleveleys Road Runners",
    "Wesham Road Runners")
ORDER BY Year;

CREATE VIEW YearClubsView
AS
SELECT 
    yc.YearClubId,
    y.YearId,
    y.Year,
    c.ClubId,
    c.Name,
    c.ShortName,
    c.Abbreviation
FROM YearClub yc
INNER JOIN Year y
ON yc.YearId = y.YearId
INNER JOIN Club c
ON yc.ClubId = c.ClubId
ORDER BY Year, c.Name;

ALTER TABLE ClubWinner 
RENAME TO OldClubWinner;

CREATE TABLE ClubWinner (
    ClubWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    Category VARCHAR(25) NOT NULL,
    ClubId INTEGER NOT NULL, 
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (ClubId) REFERENCES Club (ClubId), 
    UNIQUE(CompetitionId, Category)
);

UPDATE OldClubWinner
SET Club = "Blackpool"
WHERE Club = "Blackpool and Fylde";

DROP TABLE ClubWinner;
CREATE TABLE ClubWinner (
    ClubWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    Category VARCHAR(25) NOT NULL,
    YearClubId INTEGER NOT NULL, 
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(CompetitionId, Category)
);

UPDATE OldClubWinner
SET CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE Year = 1989 AND CompetitionType = "Road")
WHERE ClubWinnerId IN (112, 113, 114);

UPDATE OldClubWinner
SET CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE Year = 1990 AND CompetitionType = "Road")
WHERE ClubWinnerId IN (115, 116);

UPDATE OldClubWinner
SET CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE Year = 1991 AND CompetitionType = "Road")
WHERE ClubWinnerId IN (117, 118);

UPDATE OldClubWinner
SET Club = "Chorley"
WHERE Club = "Chorely";

DROP TABLE ClubWinner;
CREATE TABLE ClubWinner (
    ClubWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    Category VARCHAR(25) NOT NULL,
    YearClubId INTEGER NOT NULL, 
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(CompetitionId, Category, YearClubId)
);

INSERT INTO ClubWinner (ClubWinnerId, CompetitionId, Category, YearClubId)
SELECT 
    ocw.ClubWinnerId,
    ocw.CompetitionId,
    ocw.Category,
    yc.YearClubId
FROM OldClubWinner ocw
INNER JOIN Competition co
ON co.CompetitionId = ocw.CompetitionId
INNER JOIN Club cl
ON cl.ShortName = ocw.Club
INNER JOIN YearClub yc
ON yc.ClubId = cl.ClubId
AND yc.YearId = co.YearId;

DROP TABLE OldClubWinner;

CREATE VIEW ClubWinnersView
AS
SELECT 
    cw.ClubWinnerId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    cw.Category,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName
FROM ClubWinner cw
INNER JOIN Competition co
ON co.CompetitionId = cw.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = cw.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;

-- There are some errors in the population based on the details in the interclub history document.
INSERT INTO ClubWinner (CompetitionId, Category, YearClubId)
VALUES (
    (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Road" AND Year = 1998),
    "Female",
    (SELECT YearClubId FROM YearClubsView WHERE ShortName = "Red Rose" AND Year = 1998));

UPDATE ClubWinner
SET YearClubId =  (SELECT YearClubId FROM YearClubsView WHERE ShortName = "Red Rose" AND Year = 2014)
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Road" AND Year = 2014)
AND Category = "Vet 50";

ALTER TABLE RunnerWinner 
RENAME TO OldRunnerWinner;

CREATE TABLE RunnerWinner (
    RunnerWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER NOT NULL,
    Category VARCHAR(25) NOT NULL,
    Name VARCHAR(50),
    Surname VARCHAR(50),
    YearClubId INTEGER NOT NULL, 
    Position INTEGER NOT NULL,
    FOREIGN KEY (CompetitionId) REFERENCES Competition (CompetitionId),
    FOREIGN KEY (YearClubId) REFERENCES YearClub (YearClubId), 
    UNIQUE(CompetitionId, Category, Position)
);

UPDATE OldRunnerWinner
SET Club = "Blackpool"
WHERE Club = "Blackpool and Fylde";

UPDATE OldRunnerWinner
SET  Club = "Blackpool"
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Road" AND Year = 2007)
AND Category = "Female"
AND Position = 1;

UPDATE OldRunnerWinner
SET CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Road" AND Year = 2006)
WHERE Name = "A"
AND Surname = "Sutton"
AND Category = "Open"
AND CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Road" AND Year = 2005);

INSERT INTO RunnerWinner (RunnerWinnerId, CompetitionId, Category, Name, Surname, YearClubId, Position)
SELECT 
    orw.RunnerWinnerId,
    orw.CompetitionId,
    orw.Category,
    orw.Name,
    orw.Surname,
    yc.YearClubId,
    orw.Position
FROM OldRunnerWinner orw
INNER JOIN Competition co
ON co.CompetitionId = orw.CompetitionId
INNER JOIN Club cl
ON cl.ShortName = orw.Club
INNER JOIN YearClub yc
ON yc.ClubId = cl.ClubId
AND yc.YearId = co.YearId;

DROP TABLE OldRunnerWinner;

CREATE VIEW RunnerWinnersView
AS
SELECT 
    rw.RunnerWinnerId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    rw.Category,
    rw.Position,
    rw.Name,
    rw.Surname,
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName
FROM RunnerWinner rw
INNER JOIN Competition co
ON co.CompetitionId = rw.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = rw.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;
*/
