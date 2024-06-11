DROP TABLE IF EXISTS RunnerStandingResult;
DROP TABLE IF EXISTS RunnerStanding;

CREATE TABLE RunnerStanding (
    RunnerStandingId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER,
    Category VARCHAR(25),
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Club VARCHAR(25),
    Position INTEGER,
    Total INTEGER,
    Qualified INTEGER
);

CREATE TABLE RunnerStandingResult (
    RunnerStandingResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    RunnerStandingId INTEGER,
    RaceId INTEGER,
    Points INTEGER,
    Scoring INTEGER
);


