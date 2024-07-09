-- Create a new table `birds_measurements` from the file `birds.csv`, 
-- which contains the names and measurements of individuals from over 10k bird species.
CREATE TABLE birds_measurements AS 
    SELECT * FROM read_csv('birds.csv');