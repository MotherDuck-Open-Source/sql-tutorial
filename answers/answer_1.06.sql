-- Create a new calculated column, `temperature_obs_celcius`, that converts the observed temperature to °C using the equation: 
-- `(32°F − 32) × 5/9 = 0°C`.
SELECT 
    *,
    (temperature_obs - 32) * (5/9) as temperature_obs_celcius
FROM weather;