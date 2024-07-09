-- Run a query that gets the 95<sup>th</sup> percentile and 99<sup>th</sup> percentile of `Beak_Length_Culmen` for all birds.
SELECT 
    QUANTILE_CONT(Beak_Length_Culmen, 0.95),
    QUANTILE_CONT(Beak_Length_Culmen, 0.99)
FROM birds;