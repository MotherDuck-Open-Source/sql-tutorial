-- Use the query you created in the previous exercise and order the rows by `precipitation` in ascending order.
SELECT name, date, precipitation, (temperature_max + temperature_min) / 2 AS median_temperature 
FROM weather
ORDER BY precipitation ASC;