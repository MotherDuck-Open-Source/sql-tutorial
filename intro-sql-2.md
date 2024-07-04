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

# 2. Learn to quack SQL with DuckDB: Group by, Joins and Subqueries

## Example Tables
Let's start with two datasets:

- {Download}`birds.csv<./data/birds.csv>`: a list of measurements of individuals of different bird species
- {Download}`ducks.csv<./data/ducks.csv>`: a list of scientific names of bird species that are ducks

To create the tables in your database, run:

```SQL
CREATE TABLE birds AS SELECT * FROM read_csv('birds.csv');
CREATE TABLE ducks AS SELECT * FROM read_csv('ducks.csv');
```

To inspect the names of the columns by describing the tables, you can run:

```SQL
DESCRIBE birds;
DESCRIBE ducks;
```

```{admonition} Exercise
Create a new table `birds` from the file `birds.csv`, which contains the names and measurements of individuals from over 10k bird species.
```

```{admonition} Exercise
Create a new table `ducks` from the file `ducks.csv`, which contains species names and common names of ducks.
```

## 1. Group Rows (GROUP BY Clause)

To group the rows based on a specific column and perform <a href="https://duckdb.org/docs/sql/aggregates.html" target="_blank">aggregate functions</a>, you can use the `GROUP BY` clause. For example, if you want to group the birds by their species name and calculate the average `Beak_Length_Culmen` for each group, you can run this query:

```SQL
SELECT
    Species_Common_Name,
    AVG(Beak_Width) AS Avg_Beak_Width,
    AVG(Beak_Depth) AS Avg_Beak_Depth,
    AVG(Beak_Length_Culmen) AS Avg_Beak_Length_Culmen
FROM birds
GROUP BY Species_Common_Name;
```

This command groups the rows by the `Species_Common_Name` column and calculates the average `Beak_Width`, `Beak_Depth` and `Beak_Length_Culmen` for the individuals in each bird species group.

```{admonition} Exercise
Run a query that gets the average `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` for all birds.
```

### Getting the 95<sup>th</sup> percentile of a column value

We've used `GROUP BY` to group by a certain column, and used an aggregate function to combine other columns in our query, for instance, by taking the average. But, what if we want to get the 95<sup>th</sup> percentile of a column value? For that, we can also use something called an <a href="https://duckdb.org/docs/sql/aggregates.html#ordered-set-aggregate-functions" target="_blank">ordered set aggregate function</a>. For instance, to get the 95<sup>th</sup> percentile value of the `Beak_Length_Culmen` of all birds, run:

```SQL
SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY Beak_Length_Culmen) from birds;
```

```{admonition} Exercise
Run a query that gets the 95<sup>th</sup> percentile and 99<sup>th</sup> percentile of `Beak_Length_Culmen` for all birds.
```

```{admonition} Exercise
Run a query that gets the 99<sup>th</sup> percentile of `Wing_Length` for all birds.
```


## 2. Understanding SQL Joins

In SQL, a Join operation allows you to combine rows from two or more tables based on a related column between them. This is incredibly useful when you need to pull together related information that is stored in different tables.

Let's combine the `birds` and `ducks` tables to find the `Beak_Length_Culmen` of all birds that are ducks. To do this, we'll use a SQL Join operation. Specifically, we'll use an `INNER JOIN`, which combines rows from both tables only when there is a match in the `Species_Common_Name` column.

```SQL
SELECT
    Species_Common_Name,
    Beak_Width,
    Beak_Depth,
    Beak_Length_Culmen
FROM birds
INNER JOIN ducks ON name = Species_Common_Name
ORDER BY Species_Common_Name;
```

```{admonition} Exercise
Join the `birds` and `ducks` tables and run a query that gets the name, `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` of birds that are ducks.
``` 

### Step-by-Step Explanation
Let's break down the SQL query step by step:

`SELECT Species_Common_Name, Beak_Width, Beak_Depth, Beak_Length_Culmen`: We're selecting the species name and beak measurements.

`FROM birds`: We're starting with the `birds` table.

`INNER JOIN ducks ON name = Species_Common_Name`: We're joining the birds table to the ducks table where the species' common name matches in both tables.

`ORDER BY Species_Common_Name`: We're sorting the results by the duck's name.

## 3. Subqueries

### What is a Subquery?

A subquery, also known as an inner query or nested query, is a query within another SQL query. It's like a query inside a query! Subqueries are used to perform operations that require multiple steps, such as filtering data based on a complex condition or aggregating data before using it in the main query. In other words, instead of creating multiple new tables as intermediate steps, you can define these steps within the scope of a larger query.

### Using Subqueries in DuckDB

Let's start by looking at our previously example query to understand how subqueries work in DuckDB.

#### Finding the top `Beak_Length_Culmen`

Suppose we want to find the ducks with the largest `Beak_Length_Culmen`. We can use a subquery to calculate the 95<sup>th</sup> percentile of `Beak_Length_Culmen` first, and then use that result in our main query:

```SQL
SELECT
    Species_Common_Name,
    Beak_Width,
    Beak_Depth,
    Beak_Length_Culmen
FROM birds
INNER JOIN ducks ON name = Species_Common_Name
WHERE Beak_Length_Culmen > (
    SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Beak_Length_Culmen) from birds INNER JOIN ducks ON name = Species_Common_Name
)
ORDER BY Beak_Length_Culmen DESC;
```

In this example, the subquery (`SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Beak_Length_Culmen) from birds INNER JOIN ducks ON name = Species_Common_Name`) calculates the 99<sup>th</sup> percentile of beak length for all birds that are ducks. The main query then selects the names and beak measurements of ducks who have a beak length above this value.

```{admonition} Exercise
Use a subquery to get the ducks that have a `Wing_Length` larger than the 99<sup>th</sup> percentile of all ducks.
```

#### Using the WITH Clause

Now, let's see how we can use the `WITH` clause to make our queries more readable. Suppose we want to find the names and measurements of ducks who have a beak length above the average. Here's how we can do it using the `WITH` clause:

```SQL
WITH
    duck_beaks AS (
        SELECT
            Species_Common_Name,
            Beak_Width,
            Beak_Depth,
            Beak_Length_Culmen
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
    ),

    pc99_beak_len AS (
        SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Beak_Length_Culmen) AS Top_Beak_Length from duck_beaks
    )

SELECT
    Species_Common_Name,
    Beak_Width,
    Beak_Depth,
    Beak_Length_Culmen
FROM duck_beaks, pc99_beak_len
WHERE Beak_Length_Culmen > pc99_beak_len.Top_Beak_Length
ORDER BY Beak_Length_Culmen DESC;
```

In this example, the `WITH` clause creates two temporary result sets called `duck_beaks` and `pc99_beak_len`. The main query then selects the names and beak measurements of ducks with `Beak_Length_Culmen` above the top 99<sup>th</sup> percentile beak length.

```{admonition} Exercise
Use a subquery to get the ducks that have a `Wing_Length` larger than the 99<sup>th</sup> percentile of all ducks.
```

```{admonition} Exercise
Use a subquery to get the *birds* that have a `Beak_Length_Culmen` larger than the 99<sup>th</sup> percentile of all *ducks*.
```
