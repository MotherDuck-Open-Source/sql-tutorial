-- What about the duck species that have a `Wing_Length` _or_ `Beak_Length_Culmen` 
-- larger than the 95<sup>th</sup> percentile of all duck species?
WITH
    duck_wings AS (
        SELECT
            Species_Common_Name,
            AVG(Wing_Length) as Avg_Wing_Length,
            AVG(Beak_Length_Culmen) as Avg_Beak_Length
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
        GROUP BY 
            Species_Common_Name
    ),

    pc95 AS (
        SELECT 
            QUANTILE_CONT(Wing_Length, 0.95) AS Top_Wing_Length,
            QUANTILE_CONT(Beak_Length_Culmen, 0.95) AS Top_Beak_Length,
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
    )


SELECT
    duck_wings.Species_Common_Name,
    duck_wings.Avg_Wing_Length
FROM duck_wings
INNER JOIN pc95 
    ON duck_wings.Avg_Wing_Length > pc95.Top_Wing_Length
    OR duck_wings.Avg_Beak_Length > pc95.Top_Beak_Length
ORDER BY duck_wings.Avg_Wing_Length DESC;
