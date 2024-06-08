DROP TABLE IF EXISTS ClubWinner;

CREATE TABLE ClubWinner (
    ClubWinnerId INTEGER PRIMARY KEY AUTOINCREMENT,
    CompetitionId INTEGER,
    Category VARCHAR(25),
    Club VARCHAR(25)
);
