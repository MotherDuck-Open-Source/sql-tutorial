# First, connect to the same database that Ibis wrote the csv file to
duck_con = duckdb.connect('whats_quackalackin.duckdb')

# Then, combine all of the Ibis subqueries into a single level SQL statement
duck_con.sql("""
  SELECT
    author,
    count(name) as "Count(name)",
    min(year) as "Min(year)"
  FROM persistent_ducks
  WHERE
    extinct = 0
  GROUP BY
    author
  ORDER BY
    "Count(name)" desc
""").df()
