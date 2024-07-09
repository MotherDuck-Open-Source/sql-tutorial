-- Run a query that gets the average `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` for all birds.
SELECT 
    AVG(Beak_Length_Culmen),
    AVG(Wing_Length),
    AVG(Tail_Length)
FROM birds