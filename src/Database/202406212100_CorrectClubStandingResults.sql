/*DELETE FROM ClubStandingResult
WHERE ClubStandingResultId IN (
    SELECT csr.ClubStandingResultId
    FROM ClubStandingResult csr
    LEFT OUTER JOIN ClubStanding cs
    ON cs.ClubStandingId = csr.ClubStandingId
    WHERE cs.ClubStandingId IS NULL);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Female Vet 40" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 50" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Chorley"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    1
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Lytham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    2
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    3
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Thornton"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    4
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Red Rose"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Blackpool"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Lytham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Preston"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Thornton"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Wesham"),
    6
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2022" AND Category = "Vet 60" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2022" AND Name = "Chorley"),
    5
);
*/
