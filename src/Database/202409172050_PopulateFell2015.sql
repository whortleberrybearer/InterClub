INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Harrock Hill", CompetitionId, "2015-05-27 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2015;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Great Hill", CompetitionId, "2015-05-20 15:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2015;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "20 Barriers", CompetitionId, "2015-07-07 19:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2015;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Darwen Gala", CompetitionId, "2015-08-15 13:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2015;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2015
AND Category = "Female";
