INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Pendle Hill", CompetitionId, "2011-04-02 14:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2011;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Walsh Two Lads", CompetitionId, "2011-06-16 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2011;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Warton Crag", CompetitionId, "2011-07-09 14:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2011;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Golf Ball", CompetitionId, "2011-08-17 19:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2011;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Overall";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Vet 70";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2011
AND Category = "Female";
