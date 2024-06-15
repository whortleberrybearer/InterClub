UPDATE ClubStanding
SET Total = 26
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Chorley");

UPDATE ClubStanding
SET Total = 23
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham");

UPDATE ClubStanding
SET Total = 21
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Red Rose");

UPDATE ClubStanding
SET Total = 18
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston");

UPDATE ClubStanding
SET Total = 9
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Blackpool");

UPDATE ClubStanding
SET Total = 7
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Lytham");

UPDATE ClubStanding
SET Total = 2
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Open"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Thornton");

UPDATE ClubStanding
SET Total = 26
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Red Rose");

UPDATE ClubStanding
SET Total = 19
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham");

UPDATE ClubStanding
SET Total = 18
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Chorley");

UPDATE ClubStanding
SET Total = 17
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston");

UPDATE ClubStanding
SET Total = 9
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Lytham");

UPDATE ClubStanding
SET Total = 9
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Blackpool");

UPDATE ClubStanding
SET Total = 2
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Female"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Thornton");

UPDATE ClubStanding
SET Total = 27
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Chorley");

UPDATE ClubStanding
SET Total = 21
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Red Rose");

UPDATE ClubStanding
SET Total = 20
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham");

UPDATE ClubStanding
SET Total = 17
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston");

UPDATE ClubStanding
SET Total = 12
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Blackpool");

UPDATE ClubStanding
SET Total = 7
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Lytham");

UPDATE ClubStanding
SET Total = 2
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Thornton");

UPDATE ClubStanding
SET Total = 27
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Chorley");

UPDATE ClubStanding
SET Total = 23
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Red Rose");

UPDATE ClubStanding
SET Total = 19
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham");

UPDATE ClubStanding
SET Total = 18
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston");

UPDATE ClubStanding
SET Total = 9
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Blackpool");

UPDATE ClubStanding
SET Total = 6
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Lytham");

UPDATE ClubStanding
SET Total = 3
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 50"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Thornton");

UPDATE ClubStanding
SET Total = 26
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Red Rose");

UPDATE ClubStanding
SET Total = 22
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Chorley");

UPDATE ClubStanding
SET Total = 12
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Lytham");

UPDATE ClubStanding
SET Total = 11
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Preston");

UPDATE ClubStanding
SET Total = 11
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Blackpool");

UPDATE ClubStanding
SET Total = 7
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Wesham");

UPDATE ClubStanding
SET Total = 0
WHERE CompetitionId = (SELECT CompetitionId FROM CompetitionsView WHERE CompetitionType = "Fell" AND Year = 2023)
AND Category = "Vet 60"
AND YearClubId = (SELECT YearClubId FROM YearClubsView WHERE Year = 2023 AND ShortName = "Thornton");