INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Pendle", CompetitionId, "2019-04-06 14:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2019;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Leo Pollard Memorial", CompetitionId, "2019-06-06 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2019;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Clougha Pike", CompetitionId, "2019-06-22 15:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2019;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Lee Mill", CompetitionId, "2019-07-31 19:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2019;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Male";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Male Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Male Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Male Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Female";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Female Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2019
AND Category = "Female Vet 50";