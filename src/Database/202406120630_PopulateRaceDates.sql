/*ALTER TABLE Race
ADD StartDateTime VARCHAR(20) NULL;
*/

UPDATE Race
SET StartDateTime = "2024-04-10 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Blackpool"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-05-09 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Lytham"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-06-12 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Preston"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-06-25 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Thornton"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-07-22 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Wesham"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-08-14 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Chorley"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2024-09-04 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Red Rose"
    AND c.Year = 2024);

UPDATE Race
SET StartDateTime = "2023-04-07 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Blackpool"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-05-11 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Lytham"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-06-14 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Preston"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-06-27 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Thornton"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-07-17 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Wesham"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-08-09 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Chorley"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-09-06 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Red Rose"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2022-04-06 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Blackpool"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-05-12 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Lytham"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-06-15 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Preston"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-06-28 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Thornton"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-07-18 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Wesham"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-08-10 19:30"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Chorley"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2022-09-07 19:00"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Red Rose"
    AND c.Year = 2022);

UPDATE Race
SET StartDateTime = "2023-04-08"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Wardle Skyline"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-06-22"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Aggies Staircase"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-07-29"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Beetham Sports"
    AND c.Year = 2023);

UPDATE Race
SET StartDateTime = "2023-08-23"
WHERE RaceId = 
    (SELECT RaceId 
    FROM Race r
    INNER JOIN Competition c
    ON r.CompetitionId = c.CompetitionId
    WHERE r.Name = "Golf Ball"
    AND c.Year = 2023);