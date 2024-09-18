INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Great Hameldon", CompetitionId, "2014-05-04 12:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2014;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Aggie's Staircase", CompetitionId, "2014-06-19 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2014;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Warton Crag", CompetitionId, "2014-07-19 14:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2014;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Harrock Hill", CompetitionId, "2014-08-27 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2014;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2014
AND Category = "Female";
