-- Select the `temperature_max` and `temperature_min` columns, and 
-- filter down to only see the rows where both of those values are under 60 and above 50.
SELECT 
    temperature_max,
    temperature_min
FROM weather 
WHERE 
    temperature_max > 50
    AND temperature_max < 60
    AND temperature_min > 50
    AND temperature_min < 60
;