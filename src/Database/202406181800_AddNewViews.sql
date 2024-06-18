DROP VIEW RacesView;
CREATE VIEW RacesView
AS
SELECT 
    r.RaceId, 
    c.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    r.Name,
    DATETIME(r.StartDateTime) StartDateTime
FROM Race r
INNER JOIN Competition c
ON c.CompetitionId = r.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = c.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = c.YearId;

DROP VIEW ClubCategoriesView;
CREATE VIEW ClubCategoriesView
AS
SELECT 
    cc.ClubCategoryId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    ca.CategoryId,
    ca.Category
FROM ClubCategory cc
INNER JOIN Competition co
ON co.CompetitionId = cc.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN Category ca
ON ca.CategoryId = cc.CategoryId;

DROP VIEW RaceResultsView;
CREATE VIEW RaceResultsView
AS
SELECT 
    rr.RaceResultId, 
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    r.RaceId,
    r.Name RaceName,
    rr.Position,
    rr.RunnerNumber,
    rr.Name,
    rr.Surname,
    rr.Category,
    rr.Sex, 
    rr.Club, 
    yc.YearClubId,
    cl.ClubId,
    cl.ShortName ClubShortName,
    TIME(rr.Time) Time,
    rr.Comments
FROM RaceResult rr
INNER JOIN Race r
ON r.RaceId = rr.RaceId
INNER JOIN Competition co
ON co.CompetitionId = r.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN YearClub yc
ON yc.YearClubId = rr.YearClubId
INNER JOIN Club cl
ON cl.ClubId = yc.ClubId;
