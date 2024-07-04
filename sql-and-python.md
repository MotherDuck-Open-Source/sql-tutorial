---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.16.2
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---

<!-- #region id="1f93ab2e" -->
# 3. Combining SQL and Python

## A. Using `duckdb` from Python

DuckDB is released with a native Python client. You can install it with a simple pip install, and there are no dependencies required.

Google Collab even has duckdb pre-installed!

We will also install a few dataframe libraries, but these are optional unless you would like to do some of your analysis outside of DuckDB!
<!-- #endregion -->

```python
!pip install duckdb>=1.0.0 pandas polars pyarrow
```

```python
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/ducks.csv -q --show-progress
```

<!-- #region id="5f0871db" -->
DuckDB follows the Python DB API spec, so you can use it the same way you would use another database.
fetchall() returns a list of tuples.
<!-- #endregion -->

```python
import duckdb

duckdb.execute("SELECT 42 as hello_world").fetchall()
```

<!-- #region id="kc-LQbGSWqao" -->
DuckDB also has a .sql method that has some convenience features beyond .execute. We recommend using .sql!
<!-- #endregion -->

```python
duckdb.sql("SELECT 42 as hello_world").fetchall()
```

<!-- #region id="NuaJl1s6W3we" -->
## B. Writing Pandas DataFrames with DuckDB
DuckDB can also return a DataFrame directly using .df(), instead of a list of tuples!

This is much faster for large datasets, and fits nicely into existing dataframe workflows like charting (which we will see later) or machine learning.
<!-- #endregion -->

```python
duckdb.sql("SELECT 42 as hello_world").df()
```

<!-- #region id="S76DUjL_XUWO" -->
If that output looks familiar, it's because we have been using Pandas DataFrames the entire time we have been using duckdb_magic! duckdb_magic returns a dataframe as the result of each SQL query.
<!-- #endregion -->

<!-- #region id="8f519ae2" -->
## C. Reading Pandas DataFrames
Not only can DuckDB write dataframes, but it can read them as if they were a table!

No copying is required - DuckDB will read the existing Pandas object by scanning the C++ objects underneath Pandas' Python objects.

For example, to create a Pandas dataframe and access it from DuckDB, you can run:
<!-- #endregion -->

```python
import pandas as pd
ducks_pandas = pd.read_csv('ducks.csv')

duckdb.sql("SELECT * FROM ducks_pandas").df()
```

<!-- #region id="U5g4bqyBdxRb" -->
### When to use pd.read_csv?
How would you decide whether to use Pandas or DuckDB to read a CSV file? There are pros to each!
<!-- #endregion -->

<!-- #region id="bWs78TL1YrG7" -->
## D. Reading and Writing Polars and Apache Arrow

In addition to Pandas, DuckDB is also fully interoperable with Polars and Apache Arrow.

Polars is a faster and more modern alternative to Pandas, and has a much smaller API to learn.

Apache Arrow is *the* industry standard tabular data transfer format. Polars is actually built on top of Apache Arrow data types. Apache Arrow and DuckDB types are highly compatible. Apache Arrow has also taken inspiration from DuckDB's `VARCHAR` data type with their new `STRING_VIEW` type.
<!-- #endregion -->

```python
import polars as pl
import pyarrow as pa
import pyarrow.csv as pa_csv
```

```python
ducks_polars = pl.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_polars""").pl()
```

```python
ducks_arrow = pa_csv.read_csv('ducks.csv')
duckdb.sql("""SELECT * FROM ducks_arrow""").arrow()
```

<!-- #region id="b673f96d" -->
## 2. Using `ibis` with a DuckDB backend

We'll show you how to leverage the power of DuckDB without even needing to write a single line of SQL. Instead, we'll use Ibis, a powerful Python library that allows you to interact with databases using a DataFrame-like syntax. We'll also show you how to combine the two so you can get the best of both worlds.

First, let's make sure you have the necessary packages installed. You can install DuckDB and Ibis using pip:
<!-- #endregion -->

```python
pip install ibis-framework[duckdb,examples] --upgrade --quiet
```

<!-- #region id="DFlOOkIEgMTG" -->
We are using Ibis in interactive mode for demo purposes. This converts Ibis expressions from lazily evaluated to eagerly evaluated, so it is easier to see what is happening at each step. It also converts Ibis results into Pandas dataframes for nice formatting in Jupyter.

For performance and memory reasons, we recommend not using interactive mode in production!

We can connect to a file-based DuckDB database by specifying a file path.
<!-- #endregion -->

```python
import ibis
ibis.options.interactive = True

con = ibis.duckdb.connect(database='whats_quackalackin.duckdb')
```

<!-- #region id="a50cdf52" -->
We can read in a CSV using Ibis, and it will use the DuckDB `read_csv_auto` function under the hood. This way we get both DuckDB's performance, and clean Python syntax.
<!-- #endregion -->

```python
ducks_ibis = ibis.read_csv('ducks.csv')
ducks_ibis
```

<!-- #region id="TuayvGkciKrw" -->
The result of the prior read_csv operation is an Ibis object. It is similar to the result of a SQL query - it is not saved into the database automatically.

To save the result of our read_csv into the DuckDB file, we create a table.
<!-- #endregion -->

```python
persistent_ducks = con.create_table(name='ducks', obj=ducks_ibis.to_pyarrow(), overwrite=True)
persistent_ducks
```

<!-- #region id="f9212aab" -->
Now that we have a table set up, let's see how we can query this data using Ibis. With Ibis, you can perform operations on your data without writing SQL. Let's see how similar it feels...
<!-- #endregion -->

```python
persistent_ducks.filter(persistent_ducks.extinct == 0)
```

```python
(persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
)
```

```python
duck_legends = (persistent_ducks
  .filter(persistent_ducks.extinct == 0)
  .select("name", "author", "year")
  .group_by("author")
  .aggregate([persistent_ducks.name.count(), persistent_ducks.year.min()])
  .order_by([ibis.desc("Count(name)")])
)
duck_legends
```

```python
ibis.to_sql(duck_legends)
```

<!-- #region id="8b2522bd" -->
And there you go! You've learned:
* How to read and write Pandas, Polars, and Apache Arrow with DuckDB
* How to use Ibis to run dataframe queries on top of DuckDB
* How to see the SQL that Ibis is running on your behalf
* How to mix and match SQL and Ibis
<!-- #endregion -->

```python
```
