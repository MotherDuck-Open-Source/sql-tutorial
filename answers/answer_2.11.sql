-- Can you find any duck species that have both a `Wing_Length` _and_ `Beak_Length_Culmen` 
-- larger than the 95<sup>th</sup> percentile of all duck species?
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Wing_Length,
    birds.Beak_Length_Culmen
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
WHERE birds.Wing_Length > (
    SELECT QUANTILE_CONT(birds.Wing_Length, 0.95)
    FROM birds 
    INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
)
AND birds.Beak_Length_Culmen > (
    SELECT QUANTILE_CONT(birds.Beak_Length_Culmen, 0.95)
    FROM birds 
    INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
)
ORDER BY birds.Wing_Length DESC;