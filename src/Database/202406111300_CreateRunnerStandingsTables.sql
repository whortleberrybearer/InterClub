DROP TABLE IF EXISTS RunnerStandingResult;
DROP TABLE IF EXISTS RunnerStanding;

CREATE TABLE RunnerStanding (
    RunnerStandingId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER,
    RunnerCategory VARCHAR(25),
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Category VARCHAR(5) NULL,
    Sex VARCHAR(1) NULL,
    Club VARCHAR(25),
    Position INTEGER,
    Total INTEGER,
    Qualified INTEGER NULL
);

CREATE TABLE RunnerStandingResult (
    RunnerStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RunnerStandingId INTEGER,
    RaceId INTEGER,
    Points INTEGER,
    Scoring INTEGER
);


