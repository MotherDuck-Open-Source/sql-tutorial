---
jupytext:
  formats: md:myst
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

# 2. Learn to quack SQL with DuckDB: Group by, Joins and Subqueries

To start off, install the latest version of `duckdb` and `magic-duckdb` to run this notebook.

```{code-cell}
!pip install --upgrade duckdb magic-duckdb --quiet
%load_ext magic_duckdb
```

## Example Tables
Let's start with two datasets:

- {Download}`birds.csv<./data/birds.csv>`: a list of measurements of individuals of different bird species
- {Download}`ducks.csv<./data/ducks.csv>`: a list of scientific names of bird species that are ducks

To download the datasets directly from GitHub, run:

```{code-cell}
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/birds.csv -q
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/data/ducks.csv -q
!wget https://raw.githubusercontent.com/MotherDuck-Open-Source/sql-tutorial/main/answers/answers_2.zip -q 
!unzip -o answers_2.zip -d answers 
```

To create the tables in your database, run:

```{code-cell}
%%dql
CREATE TABLE birds AS SELECT * FROM read_csv('birds.csv');
CREATE TABLE ducks AS SELECT * FROM read_csv('ducks.csv');
```

To begin understanding the data contained in these tables, you can run:

```{code-cell}
%%dql
SUMMARIZE birds;
```

```{code-cell}
%%dql
SUMMARIZE ducks;
```

```{admonition} Exercise 2.01
Create a new table `birds_measurements` from the file `birds.csv` (this file contains the names and measurements of individuals from over 10k bird species).
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.01.sql
```

```{admonition} Exercise 2.02
Create a new table `ducks_species` from the file `ducks.csv` (this file contains species names and common names of ducks).
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.02.sql
```

## 1. Aggregate Functions

The functions we saw previously when building calculated columns operated on each row of the table individually. 
In contrast, <a href="https://duckdb.org/docs/sql/aggregates.html" target="_blank">aggregate functions</a> summarize many rows of the table. 
By default, they will summarize all rows (stay tuned though!). 
For example, let's find the minimum and maximum `Beak_Width` of any bird in the dataset.

```{code-cell}
%%dql
SELECT 
    MIN(Beak_Width) AS Min_Beak_Width,
    MAX(Beak_Width) AS Max_Beak_Width
FROM birds;
```

However, aggregating an entire table all the way up to just a single row isn't always what we are looking for. 
Next, we will use the `GROUP BY` clause to apply aggregate functions to groups of rows instead of all rows.



## 2. Group Rows (GROUP BY Clause)


To group the rows based on a specific column (or columns) and perform <a href="https://duckdb.org/docs/sql/aggregates.html" target="_blank">aggregate functions</a>, you can use the `GROUP BY` clause. For example, if you want to group the birds by their species name and calculate the average `Beak_Width`, `Beak_Depth` and `Beak_Length_Culmen` for each group, you can run this query:

```{code-cell}
%%dql
SELECT
    Species_Common_Name,
    AVG(Beak_Width) AS Avg_Beak_Width,
    AVG(Beak_Depth) AS Avg_Beak_Depth,
    AVG(Beak_Length_Culmen) AS Avg_Beak_Length_Culmen
FROM birds
GROUP BY Species_Common_Name;
```

This command groups the rows by the `Species_Common_Name` column and calculates the average `Beak_Width`, `Beak_Depth` and `Beak_Length_Culmen` for the individuals in each bird species group.

Multiple columns can be included within a `GROUP BY` clause, separated by commas. 
In this example, we measure the maximum `wing_length` by `Country_WRI` and `Source`.
This example shows that these columns do not have to be hierarchically related - the `GROUP BY` will show all combinations of data in those columns. 

```{code-cell}
%%dql 
SELECT 
    Country_WRI,
    Source,
    MAX(wing_length)
FROM birds 
GROUP BY
    Country_WRI,
    Source
```

```{admonition} Exercise 2.03

Run a query that gets the average `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` for all birds.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.03.sql
```
```{admonition} Exercise 2.04
Run a query that finds the average `Tail_Length` by `Species_Common_Name` and by `Country_WRI`. 
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.04.sql
```

### Getting the 95<sup>th</sup> percentile of a column value

We've used `GROUP BY` to group by a certain column, and used an aggregate function to combine other columns in our query, for instance, by taking the average. But, what if we want to get the 95<sup>th</sup> percentile of a column value? DuckDB has a built-in aggregate function for that too! For instance, to get the 95<sup>th</sup> percentile value of the `Beak_Length_Culmen` of all birds, run:

```{code-cell}
%%dql
SELECT 
    QUANTILE_CONT(Beak_Length_Culmen, 0.95)
FROM birds;
```

```{admonition} Exercise 2.05
Run a query that gets the 95<sup>th</sup> percentile and 99<sup>th</sup> percentile of `Beak_Length_Culmen` for all birds.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.05.sql
```

```{admonition} Exercise 2.06
Run a query that gets the 99<sup>th</sup> percentile of `Wing_Length` by `Species_Common_Name`.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.06.sql
```


## 3. Understanding SQL Joins

### INNER JOIN (JOIN)
In SQL, a Join operation allows you to combine rows from two or more tables based on a related column between them. This is incredibly useful when you need to pull together related information that is stored in different tables.

Let's combine the `birds` and `ducks` tables to find the `Beak_Length_Culmen` of all birds that are ducks. To do this, we'll use a SQL Join operation. Specifically, we'll use an `INNER JOIN`, which combines rows from both tables only when there is a match in the `Species_Common_Name` column.

```{code-cell}
%%dql
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Beak_Length_Culmen,
    ducks.author
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name;
```

### Step-by-Step Explanation
Let's break down the SQL query step by step:

`SELECT birds.column00 as id, birds.Species_Common_Name, birds.Beak_Length_Culmen, ducks.author`: We're selecting the species id, name and beak length from the `birds` table, and the duck species author from the `ducks` table.

Up until now, we haven't needed to specify which table a column is coming from since we have been working with just one table! 
Now we prefix column names with the name of the table they come from. 
As a note, this is not required if the column names in the two tables are completely different from one another, but it is a good best practice. 

`FROM birds`: We're starting with the `birds` table.

`INNER JOIN ducks ON birds.Species_Common_Name = ducks.name`: We're joining the birds table to the ducks table where the species' common name matches in both tables. 
We are using table prefixes again for clarity.

### INNER JOIN Gotchas

**NOTE:** When using an `INNER JOIN`, we only show output rows where there are matching values in both tables. 
This has dramatically reduced the number of output rows since now we are only looking at ducks!

**NOTE:** If a join between 2 tables results in multiple matches, all matches will be returned. 
This can mean that your result can actually return **more** rows after a join, in some cases!
(Imagine that we had messy data in `ducks.csv`, and one species mistakenly had multiple authors. We would have 1 row in our result for each author.)

**NOTE:** `INNER JOIN` is the default kind of join in SQL. So if you see a query that just says `... table1 JOIN table2 ...`, then it is using an `INNER JOIN`!
It is common practice to omit `INNER`. 

**NOTE:** It is possible to join on multiple columns. 
For example, imagine wanting to connect two tables by matching both a first name column and last name column. 
Inequality conditions are also possible (as we will see later!). 



```{admonition} Exercise 2.07
Run a query that gets the name, `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` of birds that are ducks.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.07.sql
```

```{admonition} Exercise 2.08
Let's run a similar query, but group the ducks by species. Run a query that gets the `Species_Common_Name`, _average_ `Beak_Length_Culmen`, `Wing_Length` and `Tail_Length` of birds that are ducks, and sort the results by `Species_Common_Name`.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.08.sql
```

### LEFT OUTER JOIN (LEFT JOIN)

A `LEFT OUTER JOIN` will keep all rows from the `LEFT` table in the join (the table before the `LEFT JOIN` keywords), even if there is not a match in the table on the right.
Any rows that do not have a match in the right table will have the value `NULL` for all columns from the right table. 
`NULL` is the missing value indicator in SQL. 

This can be useful when adding optional details.
For example, in our situtation, ducks will have an author, but all other birds will not.

```{code-cell}
%%dql
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Beak_Length_Culmen,
    ducks.author
FROM birds
LEFT JOIN ducks ON birds.Species_Common_Name = ducks.name;
```

Notice how the `LEFT JOIN` query has 90371 rows in the result (the same number of rows as the `birds` table), and the `INNER JOIN` query only had 662 rows. 

The `author` column contains the Python missing value indicator of `None`, which is equivalent to SQL's `NULL`. 

### LEFT JOIN Gotchas

**NOTE:** A `LEFT JOIN` usually, but not always, will result in the same number of rows as the left table. 
Cases where this is not true include:
* Duplicates in the columns that are being joined in the right table
* A `WHERE` clause that filters the result

```{admonition} Exercise 2.09
Modify the `LEFT JOIN` query above to filter to only rows that are **NOT** ducks. 

Hint: In Python (like in SQL), nothing equals None! 
Just like in Python, we use the `IS` keyword to check if a value is missing.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.09.sql
```

## 3. Subqueries

### What is a Subquery?

A subquery, also known as a nested query, is a query within another SQL query. It's like a query inside a query! Subqueries are used to perform operations that require multiple steps, such as filtering data based on a complex condition or aggregating data before using it in the main query. In other words, instead of creating multiple new tables as intermediate steps, you can define these steps within the scope of a larger query.

### Using Subqueries in DuckDB

Let's start by looking at our previously example query to understand how subqueries work in DuckDB.

#### Finding the top `Beak_Length_Culmen`

Suppose we want to find the _individual_ ducks with the largest `Beak_Length_Culmen`. We can use a subquery to calculate the 99<sup>th</sup> percentile of `Beak_Length_Culmen` first, and then use that result in our main query:

```{code-cell}
%%dql
SELECT
    birds.column00 as id,
    birds.Species_Common_Name,
    birds.Beak_Length_Culmen
FROM birds
INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
WHERE birds.Beak_Length_Culmen > (
    SELECT QUANTILE_CONT(birds.Beak_Length_Culmen, 0.99)
    FROM birds 
    INNER JOIN ducks ON birds.Species_Common_Name = ducks.name
)
ORDER BY birds.Beak_Length_Culmen DESC;
```

In this example, the subquery (`SELECT QUANTILE_CONT(birds.Beak_Length_Culmen, 0.99) FROM birds INNER JOIN ducks ON birds.Species_Common_Name = ducks.name`) calculates the 99<sup>th</sup> percentile of beak length for all birds that are ducks. The main query then selects the names and beak measurements of individual ducks who have a beak length above this value.



```{admonition} Exercise 2.10

Find the duck species that have a `Wing_Length` larger than the 99<sup>th</sup> percentile of all ducks.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.10.sql
```

```{admonition} Exercise 2.11
Can you find any duck species that have both a `Wing_Length` _and_ `Beak_Length_Culmen` larger than the 95<sup>th</sup> percentile of all duck species?
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.11.sql
```


```{admonition} Exercise 2.12
NOTE: This is extra credit!

Instead of individual ducks, find the duck species that _on average_ have a measured beak size that is larger than the 95<sup>th</sup> percentile of all ducks.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.12.sql
```


#### Using the WITH Clause

The `WITH` clause is an alternative to a subquery that has 2 key advantages: it can increase readability, and it allows for reusability. 
The technical term for a `WITH` clause is a Common Table Expression (abbreviated CTE), which describes how it can be reusable.

Now, let's see how we can use the `WITH` clause to make our queries more readable. Suppose we want to find the individual ducks that have a beak length above the 99<sup>th</sup> percentile of duck beaks. Here's how we can do it using the `WITH` clause:

```{code-cell}
%%dql
WITH
    duck_beaks AS (
        SELECT
            column00 as id,
            Species_Common_Name,
            Beak_Length_Culmen
        FROM birds
        INNER JOIN ducks ON name = Species_Common_Name
    ),

    pc99_beak_len AS (
        SELECT QUANTILE_CONT(Beak_Length_Culmen, 0.99) AS Top_Beak_Length 
        FROM duck_beaks
    )

SELECT
    duck_beaks.id,
    duck_beaks.Species_Common_Name,
    duck_beaks.Beak_Length_Culmen
FROM duck_beaks
INNER JOIN pc99_beak_len ON duck_beaks.Beak_Length_Culmen > pc99_beak_len.Top_Beak_Length
ORDER BY duck_beaks.Beak_Length_Culmen DESC;
```

In this example, the `WITH` clause creates two temporary result sets called `duck_beaks` and `pc99_beak_len`. The main query then selects the names and beak measurements of ducks with `Beak_Length_Culmen` above the top 99<sup>th</sup> percentile beak length.


```{admonition} Exercise 2.13
Find the duck species that have an average `Wing_Length` larger than the 95<sup>th</sup> percentile of all duck species.
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.13.sql
```


```{admonition} Exercise 2.14
What about the duck species that have both a `Wing_Length` _or_ `Beak_Length_Culmen` larger than the 95sup>th</sup> percentile of all duck species?
```
```{code-cell}
# Show solution
!cat ./answers/answer_2.14.sql
```
