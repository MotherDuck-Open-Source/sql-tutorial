-- Instead of individual ducks, find the duck species that _on average_ have a measured beak size 
-- that is larger than the 95<sup>th</sup> percentile of all ducks.
SELECT * 
FROM (
    SELECT 
        birds.Species_Common_Name,
        AVG(birds.Beak_Length_Culmen) as Avg_Beak_Length_Culmen
    FROM birds
    INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
    GROUP BY 
        birds.Species_Common_Name
)
WHERE 
    Avg_Beak_Length_Culmen > (
        SELECT QUANTILE_CONT(birds.Beak_Length_Culmen, 0.95)
        FROM birds 
        INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
    )
;