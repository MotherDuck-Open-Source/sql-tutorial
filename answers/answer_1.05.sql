-- Add a new calculated column called `temperature_range` that gets the difference between 
-- `temperature_max` and `temperature_min` columns.
SELECT 
    *,
    temperature_max - temperature_min as temperature_range
FROM weather;