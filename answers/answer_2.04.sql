-- Run a query that finds the average `Tail_Length` by `Species_Common_Name` and by `Country_WRI`.
SELECT 
    AVG(Tail_Length)
FROM birds
GROUP BY
    Species_Common_Name,
    Country_WRI