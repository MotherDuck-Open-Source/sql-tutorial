-- Find the duck species that have a `Wing_Length` larger than the 99<sup>th</sup> percentile of all ducks.
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Wing_Length
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
WHERE birds.Wing_Length > (
    SELECT QUANTILE_CONT(birds.Wing_Length, 0.99)
    FROM birds 
    INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
)
ORDER BY birds.Wing_Length DESC;