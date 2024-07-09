-- Run a query that gets the 99<sup>th</sup> percentile of `Wing_Length` by `Species_Common_Name`. 
SELECT 
    Species_Common_Name,
    QUANTILE_CONT(Wing_Length, 0.99),
FROM birds
GROUP BY
    Species_Common_Name;