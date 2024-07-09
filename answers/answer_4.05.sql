SELECT
  release_date,
  version_number,
  duck_species_secondary,
  scientific_name,
  category
FROM duckdb_ducks JOIN animals ON duckdb_ducks.duck_species_primary = animals.scientific_name;