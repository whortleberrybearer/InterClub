INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2017 AND CompetitionType = "Fell" AND Category = "Open"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2017 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2017 AND CompetitionType = "Fell" AND Category = "Female"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2017 AND ShortName = "Red Rose"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2017 AND CompetitionType = "Fell" AND Category = "Vet"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2017 AND ShortName = "Chorley"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2017 AND CompetitionType = "Fell" AND Category = "Vet 50"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2017 AND ShortName = "Preston"));

INSERT INTO ClubWinner (ClubCategoryId, YearClubId)
VALUES (
    (SELECT ClubCategoryId FROM ClubCategoriesView WHERE Year = 2017 AND CompetitionType = "Fell" AND Category = "Vet 60"),
    (SELECT YearClubId FROM YearClubsView WHERE Year = 2017 AND ShortName = "Preston"));