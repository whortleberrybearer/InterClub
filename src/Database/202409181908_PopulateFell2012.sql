INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Great Hameldon", CompetitionId, "2012-05-06 12:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2012;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Aggie's Staircase", CompetitionId, "2012-06-21 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2012;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Bull Hill", CompetitionId, "2012-07-12 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2012;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Chipping Show", CompetitionId, "2012-08-25 14:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2012;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2012
AND Category = "Female";
