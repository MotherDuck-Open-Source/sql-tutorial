birds_arrow = pa_csv.read_csv('birds.csv')
duckdb.sql("""SELECT max(wing_length) FROM birds_arrow""").arrow()