INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Cake Race", CompetitionId, "2017-04-29 11:00"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2017;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Walsh Two Lads", CompetitionId, "2017-08-08 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2017;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Bull Hill", CompetitionId, "2017-07-06 19:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2017;

INSERT INTO Race (Name, CompetitionId, StartDateTime)
SELECT "Boulsworth", CompetitionId, "2017-08-13 10:30"
FROM CompetitionsView 
WHERE CompetitionType = "Fell"
AND Year = 2017;

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Open";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Female";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Vet";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Vet 50";

INSERT INTO ClubCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Male";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Male Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Male Vet 50";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Male Vet 60";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Female";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Female Vet 40";

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Female Vet 50";

INSERT INTO Category (Category)
VALUES ("Overall");

INSERT INTO RunnerCategory (CompetitionId, CategoryId)
SELECT CompetitionId, CategoryId
FROM CompetitionsView, Category
WHERE CompetitionType = "Fell"
AND Year = 2017
AND Category = "Overall";