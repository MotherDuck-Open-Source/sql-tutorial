-- Let's run a similar query, but group the ducks by species. 
-- Run a query that gets the `Species_Common_Name`, _average_ `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` of
-- birds that are ducks, and sort the results by `Species_Common_Name`.
SELECT 
    birds.Species_Common_Name,
    AVG(birds.Beak_Length_Culmen),
    AVG(birds.Wing_Length),
    AVG(birds.Tail_Length)
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
GROUP BY 
    birds.Species_Common_Name
ORDER BY 
    birds.Species_Common_Name;