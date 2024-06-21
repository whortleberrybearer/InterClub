/*DELETE FROM ClubStandingResult
WHERE ClubStandingResultId IN (
    SELECT csr.ClubStandingResultId
    FROM ClubStandingResult csr
    LEFT OUTER JOIN ClubStanding cs
    ON cs.ClubStandingId = csr.ClubStandingId
    WHERE cs.ClubStandingId IS NULL);
*/

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Preston"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    7
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Blackpool"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    5
);

INSERT INTO ClubStandingResult (ClubStandingId, RaceId, Points)
VALUES (
    (SELECT ClubStandingId FROM ClubStandingsView WHERE CompetitionType = "Road" AND Year = "2024" AND Category = "Open" AND ClubShortName = "Wesham"),
    (SELECT RaceId FROM RacesView WHERE CompetitionType = "Road" AND Year = "2024" AND Name = "Blackpool"),
    6
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