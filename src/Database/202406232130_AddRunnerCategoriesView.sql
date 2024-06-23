CREATE VIEW RunnerCategoriesView
AS
SELECT 
    rc.RunnerCategoryId,
    co.CompetitionId,
    ct.CompetitionTypeId,
    ct.CompetitionType,
    y.YearId,
    y.Year,
    ca.CategoryId,
    ca.Category
FROM RunnerCategory rc
INNER JOIN Competition co
ON co.CompetitionId = rc.CompetitionId
INNER JOIN CompetitionType ct
ON ct.CompetitionTypeId = co.CompetitionTypeId
INNER JOIN Year y
ON y.YearId = co.YearId
INNER JOIN Category ca
ON ca.CategoryId = rc.CategoryId;
