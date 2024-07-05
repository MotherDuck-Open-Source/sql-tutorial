---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.5
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

<a target="_blank" href="https://colab.research.google.com/github/MotherDuck-Open-Source/sql-tutorial">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

# 1. Learn to quack SQL with DuckDB: The Basics

Today, we'll cover some basic operations in DuckDB SQL. DuckDB is a high-performance analytical database system designed for easy integration with data science workflows. It is particularly well-suited for in-memory processing and can handle complex queries efficiently. Learning SQL is a great skill because it allows you to manage and analyze large datasets quickly and effectively.

Let's dive in and learn how to load data, grab a whole table, pick specific columns, add a calculated column, and filter rows using the `WHERE` clause.

To start off, install the latest version of `duckdb` and `magic-duckdb` to run this notebook.

```{code-cell}
!pip install --upgrade duckdb magic-duckdb --quiet
%load_ext magic_duckdb
```

```{Note}
If you are in Google Collab or a Jupyter notebook, remember to put the magic `%%dql` directive in the beginning of each SQL cell.
```

+++ {"cell_type": "markdown"}

## Basic operations

Let's get started with inspecting some data! We'll use the {Download}`washington_weather.csv<./data/washington_weather.csv>` dataset.

To download the dataset directly from GitHub, run:

```{code-cell}
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/washington_weather.csv -q
```

## Create a new table from a CSV file

DuckDB makes it very easy to load data from a CSV file. To create a new table from a file, run:

```{code-cell}
%%dql
CREATE TABLE weather AS SELECT * FROM read_csv('washington_weather.csv');
```

In general, it's easy to create a new table! The syntax `CREATE TABLE <name> AS ...` lets you create a new table using any query. If you want to overwrite an existing table, you can use the `CREATE OR REPLACE TABLE <name> AS ...` syntax. For more information about the `CREATE TABLE` syntax, see the <a href="https://duckdb.org/docs/sql/statements/create_table" target="_blank">docs</a>.

```{admonition} Exercise
Create a new table called `weather` by selecting all columns in the {Download}`washington_weather.csv<./data/washington_weather.csv>` file.
```

## Describe the table

You can now describe the table to learn its structure:

```{code-cell}
%%dql
DESCRIBE weather;
```

This returns a table that shows you details about the columns, such as the column name and its type.

### Grab the Whole Table

To see all the data in the `weather` table, you can use the following SQL query:

```{code-cell}
%%dql
SELECT * FROM weather;
```

This query selects all columns and rows from the `weather` table.

### Filter Rows (WHERE Clause)

To filter rows based on certain conditions, you can use the `WHERE` clause. For example, if you only want to see the dates where a temperature higher than 75 was observed, you can run this query:

```{code-cell}
%%dql
SELECT * FROM weather WHERE temperature_obs > 82;
```

This command selects all columns from the weather table, but only includes rows where the observed temperature is greater than 82°F.

To combine filters for two or more different columns, you can use `AND` or `OR`:

```{code-cell}
%%dql
SELECT * FROM weather WHERE precipitation > 2.5 OR elevation > 600;
```

```{note}
In DuckDB, strings are indicated with single quotes, like so: `'my string value'`, and column names with double quotes, like so: `"my column name"`. You'll only need to use double quotes for your column names if they contain spaces or special characters.
```

```{admonition} Exercise
Filter rows where the station name is `'TACOMA NUMBER 1, WA US'`.
```


### Pick the Columns that You Want

Sometimes, you may only want to see specific columns. For example, if you only want to see the `temperature_max` and `temperature_min` columns, you can run this query:

```{code-cell}
%%dql
SELECT name, date, temperature_min, temperature_max FROM weather;
```

```{admonition} Exercise
Run a `DESCRIBE` query on the `weather` table to inspect the column names, and try selecting a few different ones! For example, select the `name`, `date`, `elevation`, `precipitation`, and/or `temperature_obs` columns.
```

```{admonition} Exercise
Select the `temperature_max` and `temperature_min` columns, and filter down to only see the rows where both of those values are under 60 and above 50.
```

### Add a calculated Column

You can also add a calculated column to your results. For example, if you want to calculate the average of two columns, `temperature_max` and `temperature_min`, you can do this:

```{code-cell}
%%dql
SELECT name, date, (temperature_max + temperature_min) / 2 AS median_temperature 
FROM weather;
```

This command creates a new column called `median_temperature` that contains the average of `temperature_min` and `temperature_max`.

```{admonition} Exercise
Add a new calculated column called `temperature_range` that gets the difference between `temperature_max` and `temperature_min` columns.
```

```{admonition} Exercise
Create a new calculated column, `temperature_obs_celcius`, that converts the observed temperature to °C using the equation: `(32°F − 32) × 5/9 = 0°C`.
```

### Order Rows (ORDER BY Clause)
To sort the rows based on a specific column, you can use the ORDER BY clause. For example, if you want to order the students by their average_score in descending order, you can run this query:

```{code-cell}
%%dql
SELECT name, date, precipitation, (temperature_max + temperature_min) / 2 AS median_temperature 
FROM weather
ORDER BY precipitation DESC;
```

This command sorts the rows by the `precipitation` column in descending order.

```{admonition} Exercise
Use the query you created in the previous exercise and order the rows by `precipitation` in ascending order.
```

```{admonition} Exercise
Get the station `name`, `date`, `temperature_obs` and `precipitation`, and sort the table such that the row with the lowest temperature observed is at the top of the result table.
```
