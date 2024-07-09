-- Get the station `name`, `date`, `temperature_obs` and `precipitation`, and 
-- sort the table such that the row with the lowest temperature observed is at the top of the result table.
SELECT 
    name, 
    date,
    temperature_obs,
    precipitation
FROM weather 
ORDER BY temperature_obs ASC;