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

+++ {"id": "1f93ab2e"}

# 3. Combining SQL and Python

## A. Using `duckdb` from Python

DuckDB is released with a native Python client. You can install it with a simple pip install, and there are no dependencies required.

Google Collab even has duckdb pre-installed!

We will also install a few dataframe libraries, but these are optional unless you would like to do some of your analysis outside of DuckDB!

```{code-cell}
:id: d3447ba0

!pip install duckdb>=1.0.0 pandas polars pyarrow
```

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
id: F5ygdoC2eK__
outputId: 881801c2-a0c1-4c88-c5c8-5fa26c7fb496
---
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/ducks.csv -q --show-progress
```

+++ {"id": "5f0871db"}

DuckDB follows the Python DB API spec, so you can use it the same way you would use another database.
fetchall() returns a list of tuples.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
id: afef057d
outputId: 12b44319-2589-442b-cfb3-917ff0b54c64
---
import duckdb

duckdb.execute("SELECT 42 as hello_world").fetchall()
```

+++ {"id": "kc-LQbGSWqao"}

DuckDB also has a .sql method that has some convenience features beyond .execute. We recommend using .sql!

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
id: 5hscoQIZWpHL
outputId: 805e0a4f-07c0-4cb8-87c1-051dba6f8b0b
---
duckdb.sql("SELECT 42 as hello_world").fetchall()
```

+++ {"id": "NuaJl1s6W3we"}

## B. Writing Pandas DataFrames with DuckDB
DuckDB can also return a DataFrame directly using .df(), instead of a list of tuples!

This is much faster for large datasets, and fits nicely into existing dataframe workflows like charting (which we will see later) or machine learning.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 81
id: kEpFSpi1W22M
outputId: 06a3ea22-3de2-4ea3-eb2b-94822b7e6ca6
---
duckdb.sql("SELECT 42 as hello_world").df()
```

+++ {"id": "S76DUjL_XUWO"}

If that output looks familiar, it's because we have been using Pandas DataFrames the entire time we have been using duckdb_magic! duckdb_magic returns a dataframe as the result of each SQL query.

+++ {"id": "8f519ae2"}

## C. Reading Pandas DataFrames
Not only can DuckDB write dataframes, but it can read them as if they were a table!

No copying is required - DuckDB will read the existing Pandas object by scanning the C++ objects underneath Pandas' Python objects.

For example, to create a Pandas dataframe and access it from DuckDB, you can run:

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 424
id: e4e5f7a3
outputId: ecd3d9e5-e105-4970-9a38-24903f54ef82
---
import pandas as pd
ducks_pandas = pd.read_csv('ducks.csv')

duckdb.sql("SELECT * FROM ducks_pandas").df()
```

+++ {"id": "U5g4bqyBdxRb"}

### When to use pd.read_csv?
How would you decide whether to use Pandas or DuckDB to read a CSV file? There are pros to each!

+++ {"id": "bWs78TL1YrG7"}

## D. Reading and Writing Polars and Apache Arrow

In addition to Pandas, DuckDB is also fully interoperable with Polars and Apache Arrow.

Polars is a faster and more modern alternative to Pandas, and has a much smaller API to learn.

Apache Arrow is *the* industry standard tabular data transfer format. Polars is actually built on top of Apache Arrow data types. Apache Arrow and DuckDB types are highly compatible. Apache Arrow has also taken inspiration from DuckDB's `VARCHAR` data type with their new `STRING_VIEW` type.

```{code-cell}
:id: HICaNrEvakXx

import polars as pl
import pyarrow as pa
import pyarrow.csv as pa_csv
```

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 882
id: q_LZkKRaakJr
outputId: 06e30ed3-7a60-45af-e965-9527fa0e423e
---
ducks_polars = pl.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_polars""").pl()
```

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
id: 6agVDr68akEg
outputId: 8af560b9-2b25-4c94-b1b1-5dc81b0dd785
---
ducks_arrow = pa_csv.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_arrow""").arrow()
```

+++ {"id": "b673f96d"}

## 2. Using `ibis` with a DuckDB backend

### A. Introduction to Ibis and DuckDB

We'll show you how to leverage the power of DuckDB without even needing to write a single line of SQL. Instead, we'll use Ibis, a powerful Python library that allows you to interact with databases using a DataFrame-like syntax. We'll also show you how to combine the two so you can get the best of both worlds.

First, let's make sure you have the necessary packages installed. You can install DuckDB and Ibis using pip:

```{code-cell}
:id: 8PHlSQZOayyJ

!pip install ibis-framework[duckdb,examples] --upgrade --quiet
```

+++ {"id": "DFlOOkIEgMTG"}

We are using Ibis in interactive mode for demo purposes. This converts Ibis expressions from lazily evaluated to eagerly evaluated, so it is easier to see what is happening at each step. It also converts Ibis results into Pandas dataframes for nice formatting in Jupyter.

For performance and memory reasons, we recommend not using interactive mode in production!

We can connect to a file-based DuckDB database by specifying a file path.

```{code-cell}
:id: 0a191aac

import ibis
from ibis import _
ibis.options.interactive = True

con = ibis.duckdb.connect(database='whats_quackalackin.duckdb')
```

+++ {"id": "a50cdf52"}

We can read in a CSV using Ibis, and it will use the DuckDB `read_csv_auto` function under the hood. This way we get both DuckDB's performance, and clean Python syntax.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: b6d4910f
outputId: 65957a2c-44a4-486a-8364-80761d2d2556
---
ducks_ibis = ibis.read_csv('ducks.csv')
ducks_ibis
```

+++ {"id": "TuayvGkciKrw"}

The result of the prior read_csv operation is an Ibis object. It is similar to the result of a SQL query - it is not saved into the database automatically.

To save the result of our read_csv into the DuckDB file, we create a table.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: tBXnfiBeiwyJ
outputId: 3685d19c-c607-49ee-d009-1ef37f6ea2f1
---
persistent_ducks = con.create_table(name='persistent_ducks', obj=ducks_ibis.to_pyarrow(), overwrite=True)
persistent_ducks
```

+++ {"id": "f9212aab"}

Now that we have a table set up, let's see how we can query this data using Ibis. With Ibis, you can perform operations on your data without writing SQL. Let's see how similar it feels...

The question we will build up towards answering is, "Who were the most prolific people at finding many new species of non-extinct ducks, and when did they get started finding ducks?"

Use a the `filter` function instead of a `where` clause to choose the rows you are interested in.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: 2sWBg4dIjtFH
outputId: c7efefed-d703-4a01-f289-63c46ab52a08
---
persistent_ducks.filter(persistent_ducks.extinct == 0)
```

+++ {"id": "ZNtv-DsOYvyG"}

Pick your columns using the conveniently named `select` function!

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: QNyeEOV5lWdk
outputId: 9c7f1bf6-69df-4925-c79e-a9bdbdfcc843
---
(persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
)
```

+++ {"id": "KgRYCsXfY1X6"}

The `group_by` functions matches well with the `group by` clause.

However, Ibis splits the `select` clause into the `select` function and the `aggregate` function when working with a group by. This aligns with the SQL best practice to organize your `select` clause with non-aggregate expressions first, then aggregate expressions.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: 6jRseCsrly0L
outputId: 1e534133-ebf7-43ba-94dd-47e8e48e7539
---
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
---
colab:
  base_uri: https://localhost:8080/
  height: 382
id: paAq7b0_nFx5
outputId: 8ddf7143-5d49-4793-83cf-0b4123af6261
---
ibis.to_sql(duck_legends)
```

+++ {"id": "7iWMxCWmX-Le"}

### B. Mixing and matching SQL and Ibis

If you have existing SQL queries, or want to use dialect-specific features of a specific SQL database, Ibis allows you to use SQL directly!

If you want to begin your Ibis query with SQL, you can use `Table.sql` directly.

However, we can no longer refer directly to the `persistent_ducks` object later in the expression. We instead need to use the `_` (which we imported earlier with `from ibis import _`), which is a way to build expressions using Ibis's deferred expression API. So instead of `persistent_ducks.column.function()`, we can say `_.column.function()`

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: cUDfW0vBaBLo
outputId: 292e12a5-0988-4257-9187-d3ba3c2347c4
---
duck_legends = (persistent_ducks
  .sql("""SELECT name, author, year FROM persistent_ducks WHERE extinct = 0""")
  .group_by("author")
  .aggregate([_.name.count(), _.year.min()]) # Use _ instead of persistent_ducks
  .order_by([ibis.desc("Count(name)")])
)
duck_legends
```

+++ {"id": "HDVzVRwfb4vE"}

If you want to begin with Ibis, but transition to SQL, first give the Ibis expression a name using the `alias` function. Then you can refer to that as a table in your `Table.sql` call.

```{code-cell}
---
colab:
  base_uri: https://localhost:8080/
  height: 298
id: 6WMhItcscEiN
outputId: 854c53ba-101c-4ca2-cad5-bd691156c156
---
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

+++ {"id": "8b2522bd"}

And there you go! You've learned:
* How to read and write Pandas, Polars, and Apache Arrow with DuckDB
* How to use Ibis to run dataframe queries on top of DuckDB
* How to see the SQL that Ibis is running on your behalf
* How to mix and match SQL and Ibis

+++ {"id": "tOJr0_Adw82g"}

# Exercise 1: Apache Arrow to SQL
Read in the birds.csv file using Apache Arrow, then use the DuckDB Python library to execute a SQL statement on that Apache Arrow table to find the maximum `wing_length` in the dataset. Output that result as an Apache Arrow table.

```{code-cell}
:id: xkY3G3kxw_Um


```

+++ {"id": "ugg2jn7Hw8uO"}

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
:id: Vag3GISOw_t_


```

+++ {"id": "b5RLhe68w8mq"}

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
:id: dH2W927lxAJF


```

+++ {"id": "OtTQ6LQqw8d3"}

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
:id: l1DaOGl7kIi-


```
