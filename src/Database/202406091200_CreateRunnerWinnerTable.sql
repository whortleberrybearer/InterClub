DROP TABLE IF EXISTS RunnerWinner;

CREATE TABLE RunnerWinner (
    RunnerWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER,
    Category VARCHAR(25),
    Name VARCHAR(50),
    Surname VARCHAR(50),
    Club VARCHAR(25),
    Position INTEGER
);
