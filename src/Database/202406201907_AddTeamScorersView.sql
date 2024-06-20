DROP VIEW TeamScorersView;
CREATE VIEW TeamScorersView
AS
SELECT 
    ts.TeamScorerId,
    cr.ClubResultId,
    ccr.Position,
    rr.Name,
    rr.Surname
FROM TeamScorer ts
INNER JOIN ClubResult cr
ON cr.ClubResultId = ts.ClubResultId
INNER JOIN RaceResult rr
ON rr.RaceResultId = ts.RaceResultId
INNER JOIN ClubCategoryResult ccr
ON ccr.RaceResultId == rr.RaceResultId
AND ccr.ClubCategoryId = cr.ClubCategoryId;