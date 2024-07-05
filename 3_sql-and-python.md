---
jupytext:
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.16.2
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

<a target="_blank" href="https://colab.research.google.com/github/MotherDuck-Open-Source/sql-tutorial">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

# 3. Combining SQL and Python

## A. Using `duckdb` from Python

DuckDB is released with a native Python client. You can install it with a simple pip install, and there are no dependencies required.

Google Collab even has duckdb pre-installed!

We will also install a few dataframe libraries, but these are optional unless you would like to do some of your analysis outside of DuckDB!

```{code-cell}
!pip install duckdb>=1.0.0 pandas polars pyarrow
```

```{code-cell}
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/ducks.csv -q --show-progress
```

DuckDB follows the Python DB API spec, so you can use it the same way you would use another database.
fetchall() returns a list of tuples.

```{code-cell}
import duckdb

duckdb.execute("SELECT 42 as hello_world").fetchall()
```

DuckDB also has a .sql method that has some convenience features beyond .execute. We recommend using .sql!

```{code-cell}
duckdb.sql("SELECT 42 as hello_world").fetchall()
```

## B. Writing Pandas DataFrames with DuckDB
DuckDB can also return a DataFrame directly using .df(), instead of a list of tuples!

This is much faster for large datasets, and fits nicely into existing dataframe workflows like charting (which we will see later) or machine learning.

```{code-cell}
duckdb.sql("SELECT 42 as hello_world").df()
```

If that output looks familiar, it's because we have been using Pandas DataFrames the entire time we have been using duckdb_magic! duckdb_magic returns a dataframe as the result of each SQL query.

## C. Reading Pandas DataFrames
Not only can DuckDB write dataframes, but it can read them as if they were a table!

No copying is required - DuckDB will read the existing Pandas object by scanning the C++ objects underneath Pandas' Python objects.

For example, to create a Pandas dataframe and access it from DuckDB, you can run:

```{code-cell}
import pandas as pd
ducks_pandas = pd.read_csv('ducks.csv')

duckdb.sql("SELECT * FROM ducks_pandas").df()
```

### When to use pd.read_csv?
How would you decide whether to use Pandas or DuckDB to read a CSV file? There are pros to each!

## D. Reading and Writing Polars and Apache Arrow

In addition to Pandas, DuckDB is also fully interoperable with Polars and Apache Arrow.

Polars is a faster and more modern alternative to Pandas, and has a much smaller API to learn.

Apache Arrow is *the* industry standard tabular data transfer format. Polars is actually built on top of Apache Arrow data types. Apache Arrow and DuckDB types are highly compatible. Apache Arrow has also taken inspiration from DuckDB's `VARCHAR` data type with their new `STRING_VIEW` type.

```{code-cell}
import polars as pl
import pyarrow as pa
import pyarrow.csv as pa_csv
```

```{code-cell}
ducks_polars = pl.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_polars""").pl()
```

```{code-cell}
ducks_arrow = pa_csv.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_arrow""").arrow()
```

## 2. Using `ibis` with a DuckDB backend

### A. Introduction to Ibis and DuckDB

We'll show you how to leverage the power of DuckDB without even needing to write a single line of SQL. Instead, we'll use Ibis, a powerful Python library that allows you to interact with databases using a DataFrame-like syntax. We'll also show you how to combine the two so you can get the best of both worlds.

First, let's make sure you have the necessary packages installed. You can install DuckDB and Ibis using pip:

```{code-cell}
!pip install ibis-framework[duckdb,examples] --upgrade --quiet
```

We are using Ibis in interactive mode for demo purposes. This converts Ibis expressions from lazily evaluated to eagerly evaluated, so it is easier to see what is happening at each step. It also converts Ibis results into Pandas dataframes for nice formatting in Jupyter.

For performance and memory reasons, we recommend not using interactive mode in production!

We can connect to a file-based DuckDB database by specifying a file path.

```{code-cell}
import ibis
from ibis import _
ibis.options.interactive = True

con = ibis.duckdb.connect(database='whats_quackalackin.duckdb')
```

We can read in a CSV using Ibis, and it will use the DuckDB `read_csv_auto` function under the hood. This way we get both DuckDB's performance, and clean Python syntax.

```{code-cell}
ducks_ibis = ibis.read_csv('ducks.csv')
ducks_ibis
```

The result of the prior read_csv operation is an Ibis object. It is similar to the result of a SQL query - it is not saved into the database automatically.

To save the result of our read_csv into the DuckDB file, we create a table.

```{code-cell}
persistent_ducks = con.create_table(name='persistent_ducks', obj=ducks_ibis.to_pyarrow(), overwrite=True)
persistent_ducks
```

Now that we have a table set up, let's see how we can query this data using Ibis. With Ibis, you can perform operations on your data without writing SQL. Let's see how similar it feels...

The question we will build up towards answering is, "Who were the most prolific people at finding many new species of non-extinct ducks, and when did they get started finding ducks?"

Use a the `filter` function instead of a `where` clause to choose the rows you are interested in.

```{code-cell}
persistent_ducks.filter(persistent_ducks.extinct == 0)
```

Pick your columns using the conveniently named `select` function!

```{code-cell}
(persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
)
```

The `group_by` functions matches well with the `group by` clause.

However, Ibis splits the `select` clause into the `select` function and the `aggregate` function when working with a group by. This aligns with the SQL best practice to organize your `select` clause with non-aggregate expressions first, then aggregate expressions.

```{code-cell}
duck_legends = (persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
  .group_by("author")
  .aggregate([persistent_ducks.name.count(), persistent_ducks.year.min()])
  .order_by([ibis.desc("Count(name)")])
)
duck_legends
```

```{code-cell}
ibis.to_sql(duck_legends)
```

### B. Mixing and matching SQL and Ibis

If you have existing SQL queries, or want to use dialect-specific features of a specific SQL database, Ibis allows you to use SQL directly!

If you want to begin your Ibis query with SQL, you can use `Table.sql` directly.

However, we can no longer refer directly to the `persistent_ducks` object later in the expression. We instead need to use the `_` (which we imported earlier with `from ibis import _`), which is a way to build expressions using Ibis's deferred expression API. So instead of `persistent_ducks.column.function()`, we can say `_.column.function()`

```{code-cell}
duck_legends = (persistent_ducks
  .sql("""SELECT name, author, year FROM persistent_ducks WHERE extinct = 0""")
  .group_by("author")
  .aggregate([_.name.count(), _.year.min()]) # Use _ instead of persistent_ducks
  .order_by([ibis.desc("Count(name)")])
)
duck_legends
```

If you want to begin with Ibis, but transition to SQL, first give the Ibis expression a name using the `alias` function. Then you can refer to that as a table in your `Table.sql` call.

```{code-cell}
duck_legends = (persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
  .group_by("author")
  .aggregate([persistent_ducks.name.count(), persistent_ducks.year.min()])
  .alias('ibis_duck') # Rename the result of all Ibis expressions up to this point
  .sql("""SELECT * from ibis_duck ORDER BY "Count(name)" desc""")
)
duck_legends
```


And there you go! You've learned:
* How to read and write Pandas, Polars, and Apache Arrow with DuckDB
* How to use Ibis to run dataframe queries on top of DuckDB
* How to see the SQL that Ibis is running on your behalf
* How to mix and match SQL and Ibis

# Exercise 1: Apache Arrow to SQL
Read in the birds.csv file using Apache Arrow, then use the DuckDB Python library to execute a SQL statement on that Apache Arrow table to find the maximum `wing_length` in the dataset. Output that result as an Apache Arrow table.

```{code-cell}


```


# Exercise 2: Output the result of this SQL statement to a Polars dataframe

Use the DuckDB Python client to return these results as a Polars dataframe.

```sql
SELECT
    Species_Common_Name,
    AVG(Beak_Width) AS Avg_Beak_Width,
    AVG(Beak_Depth) AS Avg_Beak_Depth,
    AVG(Beak_Length_Culmen) AS Avg_Beak_Length_Culmen
FROM 'birds.csv'
GROUP BY Species_Common_Name
```

```{code-cell}


```


# Exercise 3: Simplify the SQL that was auto-generated by Ibis

The SQL that Ibis generated to find the people who discovered the most duck species is not the most concise. Can you re-write the Ibis SQL (listed below) to its simplest possible form, using DuckDB's Python client?

Hint: as a first step, connect to the same database that Ibis connected to.
```sql
SELECT
  *
FROM (
  SELECT
    "t1"."author",
    COUNT("t1"."name") AS "Count(name)",
    MIN("t1"."year") AS "Min(year)"
  FROM (
    SELECT
      "t0"."name",
      "t0"."author",
      "t0"."year"
    FROM "whats_quackalackin"."main"."persistent_ducks" AS "t0"
    WHERE
      "t0"."extinct" = CAST(0 AS TINYINT)
  ) AS "t1"
  GROUP BY
    1
) AS "t2"
ORDER BY
  "t2"."Count(name)" DESC
```

```{code-cell}


```

# Exercise 4: Convert this SQL query into an Ibis expression

Convert the SQL query below into an Ibis expression. You are welcome to ignore the column renaming - think of it as a "stretch-goal" if you have time! We did not cover how to do that yet.
```sql
SELECT
    Species_Common_Name,
    AVG(Beak_Width) AS Avg_Beak_Width,
    AVG(Beak_Depth) AS Avg_Beak_Depth,
    AVG(Beak_Length_Culmen) AS Avg_Beak_Length_Culmen
FROM 'birds.csv'
GROUP BY Species_Common_Name
```

Hint: Read directly from a csv file - no need to create a persistent table!

Hint 2: Ibis uses `mean` instead of `avg`!

Hint 3: Ibis aggregate documentation: https://ibis-project.org/reference/expression-tables#ibis.expr.types.relations.Table.aggregate

```{code-cell}


```
