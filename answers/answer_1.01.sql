-- Create a new table called `weather` by selecting all columns in the 
-- [washington_weather.csv](https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/washington_weather.csv) file.
CREATE OR REPLACE TABLE weather AS 
    SELECT * from 'washington_weather.csv'
;