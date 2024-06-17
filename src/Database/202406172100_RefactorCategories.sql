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
*/