-- Find the duck species that have an average `Wing_Length` larger than the 95<sup>th</sup> percentile of all duck species.
WITH
    duck_wings AS (
        SELECT
            Species_Common_Name,
            AVG(Wing_Length) as Avg_Wing_Length
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
        GROUP BY 
            Species_Common_Name
    ),

    pc99_beak_len AS (
        SELECT QUANTILE_CONT(Wing_Length, 0.95) AS Top_Wing_Length 
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
    )

SELECT
    duck_wings.Species_Common_Name,
    duck_wings.Avg_Wing_Length
FROM duck_wings
INNER JOIN pc99_beak_len ON duck_wings.Avg_Wing_Length > pc99_beak_len.Top_Wing_Length
ORDER BY duck_wings.Avg_Wing_Length DESC;