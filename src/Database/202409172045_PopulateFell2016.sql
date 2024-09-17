INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Hutton Roof Craggs", CompetitionId, "2016-05-28 14:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2016;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Aggie's Staircase", CompetitionId, "2016-06-16 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2016;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "20 Barriers", CompetitionId, "2016-07-05 19:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2016;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Harrock Hill", CompetitionId, "2016-08-24 19:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2016;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 60";

INSERT INTO Category (Category)
VALUES ("Vet 70");

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2016
AND Category = "Female";
