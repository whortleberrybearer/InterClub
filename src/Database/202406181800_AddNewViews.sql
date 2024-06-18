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
    r.StartDateTime
FROM Race r
INNER JOIN Competition c
ON c.CompetitionId = r.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = c.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = c.YearId;

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
ON ca.CategoryId = cc.CategoryId