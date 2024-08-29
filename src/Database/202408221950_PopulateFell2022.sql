INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Mearley Clough", CompetitionId, "2022-05-10 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2022;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Hutton Roof Crags", CompetitionId, "2022-05-28 14:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2022;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Two Lads", CompetitionId, "2022-06-09 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2022;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Ingleborough", CompetitionId, "2022-07-16 15:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2022;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Male";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Male Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Male Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Male Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Female";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Female Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2022
AND Category = "Female Vet 50";