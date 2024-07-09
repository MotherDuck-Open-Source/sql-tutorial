-- Run a query that gets the `Species_Common_Name`, `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` of birds that are ducks.
SELECT 
    birds.Species_Common_Name,
    birds.Beak_Length_Culmen,
    birds.Wing_Length,
    birds.Tail_Length
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name;