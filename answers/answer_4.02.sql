SELECT
  year::STRING AS year,
  AVG(pm10_concentration) AS pm10_avg,
  AVG(pm25_concentration) AS pm25_avg,
  country_name as avg_pm25
FROM who.ambient_air_quality
WHERE year > 2014 AND country_name='United States of America'
GROUP by year, country_name ORDER by year, country_name;