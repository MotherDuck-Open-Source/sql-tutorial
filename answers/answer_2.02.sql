-- Create a new table `ducks_species` from the file `ducks.csv`, 
-- which contains species names and common names of ducks.
CREATE TABLE ducks_species AS 
    SELECT * FROM read_csv('ducks.csv');