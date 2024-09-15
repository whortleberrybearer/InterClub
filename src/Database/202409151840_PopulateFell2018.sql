INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Mearley Clough", CompetitionId, "2018-05-08 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2018;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Austwick Amble", CompetitionId, "2018-05-28 13:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2018;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Settle Hill", CompetitionId, "2018-06-17 10:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2018;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Tockholes Evening", CompetitionId, "2018-07-05 19:15"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2018;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Male";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Male Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Male Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Male Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Female";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Female Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2018
AND Category = "Female Vet 50";