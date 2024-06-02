DROP TABLE IF EXISTS TeamScorer;
DROP TABLE IF EXISTS ClubResult;
DROP TABLE IF EXISTS ClubStandingResult;
DROP TABLE IF EXISTS ClubStanding;
DROP TABLE IF EXISTS ClubCategoryResult;
DROP TABLE IF EXISTS RaceResult;
DROP TABLE IF EXISTS Race;
DROP TABLE IF EXISTS Competition;

CREATE TABLE Competition (
    CompetitionId INTEGER PRIMARY KEY AUTOINCREMENT,
    Competition VARCHAR(5),
    Year INTEGER
);

CREATE TABLE Race (
    RaceId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(50),
    CompetitionId INTEGER
);

CREATE TABLE RaceResult (
    RaceResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RaceId INTEGER,
    Position INTEGER,
    RunnerNumber INTEGER NULL,
    Name VARCHAR(50) NULL,
    Surname VARCHAR(50) NULL,
    Category VARCHAR(5) NULL,
    Sex VARCHAR(1) NULL,
    Club VARCHAR(25) NULL,
    Time VARCHAR(8) NULL,
    Comments VARCHAR(50) NULL
);

CREATE TABLE ClubCategoryResult (
    ClubCategoryResult INTEGER PRIMARY KEY AUTOINCREMENT,
    RaceResultId INTEGER,
    Category VARCHAR(25),
    Position INTEGER
);

CREATE TABLE ClubResult (
    ClubResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RaceId INTEGER,
    Category VARCHAR(25),
    Club VARCHAR(25),
    Position INTEGER,
    Score INTEGER
);

CREATE TABLE TeamScorer (
    TeamScorerId INTEGER PRIMARY KEY AUTOINCREMENT,
    ClubResultId INTEGER,
    RaceResultId INTEGER
);

CREATE TABLE ClubStanding (
    ClubStandingId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER,
    Category VARCHAR(25),
    Club VARCHAR(25),
    Position INTEGER,
    Total INTEGER
);

CREATE TABLE ClubStandingResult (
    ClubStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    ClubStandingId INTEGER,
    RaceId INTEGER,
    Points INTEGER
);