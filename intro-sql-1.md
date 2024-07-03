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

# 1. Learn to quack SQL with DuckDB: The Basics

Today, we'll cover some basic operations in DuckDB SQL. DuckDB is a high-performance analytical database system designed for easy integration with data science workflows. It is particularly well-suited for in-memory processing and can handle complex queries efficiently. Learning SQL is a great skill because it allows you to manage and analyze large datasets quickly and effectively.

Let's dive in and learn how to load data, grab a whole table, pick specific columns, add a calculated column, and filter rows using the `WHERE` clause.

```{Note}
If you are in Google Collab or a Jupyter notebook, remember to put the magic `%%dql` directive in the beginning of each SQL cell.
```

## Basic operations

Let's get started with inspecting some data! We'll use the {Download}`washington_weather.csv<./data/washington_weather.csv>` dataset.

## Load data from a CSV file

DuckDB makes it very easy to load data from a CSV file. To create a new table from a file, run:

```SQL
CREATE TABLE weather AS SELECT * FROM read_csv('washington_weather.csv');
```

## Describe the table

You can now describe the table to learn its structure:

```SQL
DESCRIBE weather;
```

This returns a table that shows you details about the columns, such as the column name and its type.

### Grab the Whole Table

To see all the data in the `weather` table, you can use the following SQL query:

```SQL
SELECT * FROM weather;
```

This query selects all columns and rows from the `weather` table.

### Pick the Columns that You Want

Sometimes, you may only want to see specific columns. For example, if you only want to see the `temperature_max` and `temperature_min` columns, you can run this query:

```SQL
SELECT staton_name, date, temperature_max, temperature_min FROM weather;
```

This command selects only the `name`, `date`, `temperature_max` and `temperature_min` columns from the `weather` table.

### Add a calculated Column

You can also add a calculated column to your results. For example, if you want to calculate the average of two columns, `temperature_max` and `temperature_min`, you can do this:

```SQL
SELECT staton_name, date, temperature_max, temperature_min, 
    (temperature_max + temperature_min) / 2 AS median_temperature 
FROM weather;
```

This command adds a new column called `median_temperature` that contains the average of `temperature_min` and `temperature_max`.

### Filter Rows (WHERE Clause)
To filter rows based on certain conditions, you can use the `WHERE` clause. For example, if you only want to see the dates where a temperature higher than 75 was observed, you can run this query:

```SQL
SELECT * FROM weather WHERE temperature_obs > 75;
```

This command selects all columns from the weather table, but only includes rows where the observed temperature is greater than 75.


### Order Rows (ORDER BY Clause)
To sort the rows based on a specific column, you can use the ORDER BY clause. For example, if you want to order the students by their average_score in descending order, you can run this query:

```SQL
SELECT name, date, temperature_max, temperature_min, 
       (temperature_max + temperature_min) / 2 AS median_temperature 
FROM weather
ORDER BY median_temperature DESC;
```

This command sorts the rows by the `median_temperature` column in descending order.


## Exercises

```{admonition} Exercise
Create a new table called `weather` using the {Download}`washington_weather.csv<./data/washington_weather.csv>` file.
```

```{admonition} Exercise
Select only the `name`, `date`, `elevation`, `precipitation` and `temperature_obs` columns from the `weather` table.
```

```{admonition} Exercise
Add a new calculated column called `temperature_range` that gets the difference between `temperature_max` and `temperature_min` columns.
```

```{admonition} Exercise
Filter rows where the station name is `'SEATTLE TACOMA AIRPORT, WA US'`.
```

```{admonition} Exercise
Order the rows by `precipitation` in descending order.
```

### Bonus exercises

```{admonition} Exercise
Create a new calculated column, `temperature_obs_celcius`, that converts the observed temperature to °C using the equation: `(32°F − 32) × 5/9 = 0°C`.
```

```{admonition} Exercise
Find the station name and date when the lowest temperature of 21°F was reported.
```
