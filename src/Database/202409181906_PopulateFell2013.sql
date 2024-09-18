INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Wardle Skyline", CompetitionId, "2013-04-13 14:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2013;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Caton Moor", CompetitionId, "2013-05-06 11:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2013;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Harrock Hill", CompetitionId, "2013-06-26 17:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2013;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Farleton Knott", CompetitionId, "2013-08-04 13:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2013;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2013
AND Category = "Female";
