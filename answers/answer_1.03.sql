-- Run a `DESCRIBE` query on the `weather` table to inspect the column names, and try selecting a few different ones! 
-- For example, select the `name`, `date`, `elevation`, `precipitation`, and/or `temperature_obs` columns.

DESCRIBE weather;

SELECT 
    name,
    date,
    elevation,
    precipitation,
    temperature_obs
from weather;