-- Modify the `LEFT JOIN` query above to filter to only rows that are **NOT** ducks. 

-- Hint: In Python (like in SQL), nothing equals None! 
-- Just like in Python, we use the `IS` keyword to check if a value is missing.
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Beak_Length_Culmen,
    ducks.author
FROM birds
LEFT JOIN ducks ON birds.Species_Common_Name = ducks.name
WHERE 
    ducks.name IS NULL;