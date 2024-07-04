# 2. Learn to quack SQL with DuckDB: Group by, Joins and Subqueries

## Example Tables
Let's start with two datasets:

- {Download}`birds.csv<./data/birds.csv>`: a list of measurements of individuals of different bird species
- {Download}`ducks.csv<./data/ducks.csv>`: a list of scientific names of bird species that are ducks

To create the tables in your database, run:

```SQL
create table birds as select * from read_csv('birds.csv');
create table ducks as select * from read_csv('ducks.csv');
```

Inspect the names of the columns by describing the tables:

```SQL
DESCRIBE birds;
DESCRIBE ducks;
```

## Group Rows (GROUP BY Clause)

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

## Understanding SQL Joins

In SQL, a Join operation allows you to combine rows from two or more tables based on a related column between them. This is incredibly useful when you need to pull together related information that is stored in different tables.

Let's combine the `birds` and `ducks` tables to find the beak sizes of all birds that are ducks. To do this, we'll use a SQL Join operation. Specifically, we'll use an `INNER JOIN`, which combines rows from both tables only when there is a match in the `Species_Common_Name` column.

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

### Step-by-Step Explanation
Let's break down the SQL query step by step:

`SELECT Species_Common_Name, Beak_Width, Beak_Depth, Beak_Length_Culmen`: We're selecting the species name and beak measurements.

`FROM birds`: We're starting with the `birds` table.

`INNER JOIN ducks ON name = Species_Common_Name`: We're joining the birds table to the ducks table where the species' common name matches in both tables.

`ORDER BY Species_Common_Name`: We're sorting the results by the duck's name.

## 2. Subqueries

### What is a Subquery?

A subquery, also known as an inner query or nested query, is a query within another SQL query. It's like a query inside a query! Subqueries are used to perform operations that require multiple steps, such as filtering data based on a complex condition or aggregating data before using it in the main query. In other words, instead of creating multiple new tables as intermediate steps, you can define these steps within the scope of a larger query.

### Using Subqueries in DuckDB

Let's start by looking at our previously example query to understand how subqueries work in DuckDB.

This query gets the beak measurements for all birds that are ducks:

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

#### Finding the top beak sizes

Suppose we want to find the ducks with the largest beak sizes. We can use a subquery to calculate the 95th percentile of beak sizes first, and then use that result in our main query:

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

In this example, the subquery (`SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Beak_Length_Culmen) from birds INNER JOIN ducks ON name = Species_Common_Name`) calculates the 99th percentile of beak length for all birds that are ducks. The main query then selects the names and beak measurements of ducks who have a beak length above this value.

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

In this example, the `WITH` clause creates two temporary result sets called `duck_beaks` and `pc99_beak_len`. The main query then selects the names and beak measurements of ducks with beak lengths above the top 99th percentile beak length.

## Exercises

### Datasets

- {Download}`birds.csv<./data/birds.csv>` {cite}`tobias-2022`
- {Download}`ducks.csv<./data/ducks.csv>` {cite}`col-2024`

```{admonition} Exercise
Create a new table `ducks` from the file `ducks.csv`, which contains species names and common names of ducks.
```

```{admonition} Exercise
Create a new table `birds` from the file `birds.csv`, which contains the names and measurements of individuals from over 10k bird species.
```

```{admonition} Exercise
Join the `birds` and `ducks` tables and create a table `duck_beaks` with the name and beak size of birds that are ducks.
``` 

```{admonition} Exercise
Run a query that gets the 99th percentile of beak lengths for all birds.
```

```{admonition} Exercise
Use the previous query as a subquery to get the *ducks* that have a beak size larger than the 99th percentile of all *birds*.
```
