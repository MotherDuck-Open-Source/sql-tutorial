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

Today, we'll cover some basic operations using data from a file named `students.csv`. DuckDB is a high-performance analytical database system designed for easy integration with data science workflows. It is particularly well-suited for in-memory processing and can handle complex queries efficiently. Learning SQL is a great skill because it allows you to manage and analyze large datasets quickly and effectively. Let's dive in and learn how to load data, grab a whole table, pick specific columns, add a calculated column, and filter rows using the `WHERE` clause.

## Basic operations

### Load Data

First, we need to load the data from our students.csv file into DuckDB. Here's how you do it:

```SQL
CREATE TABLE students (
    name VARCHAR,
    age INTEGER,
    english_score INTEGER,
    history_score INTEGER
);

INSERT INTO students VALUES
('Alice', 15, 92, 85),
('Bob', 16, 78, 89),
('Charlie', 15, 85, 90);
```

This command creates a new table called `students` and inserts some example rows.

You can now run describe the table:

```SQL
DESCRIBE students;
```

This returns a table that shows you details about the columns, such as the name and variable type.

```bash
┌───────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│  column_name  │ column_type │  null   │   key   │ default │  extra  │
│    varchar    │   varchar   │ varchar │ varchar │ varchar │ varchar │
├───────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ name          │ VARCHAR     │ YES     │         │         │         │
│ age           │ INTEGER     │ YES     │         │         │         │
│ english_score │ INTEGER     │ YES     │         │         │         │
│ history_score │ INTEGER     │ YES     │         │         │         │
└───────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
```

### Grab the Whole Table

To see all the data in the students table, you can use the following SQL command:

```SQL
SELECT * FROM students;
```

This command selects all columns and rows from the students table.


| name | age | english_score | history_score |
|------|-----|---------------|----------------|
| Alice| 15  | 92            | 85             |
| Bob  | 16  | 78            | 89             |
| Charlie| 15 | 85            | 90             |

### Pick the Columns that You Want

Sometimes, you may only want to see specific columns. For example, if you only want to see the name and age columns, you can use this command:

```SQL
SELECT name, age FROM students;
```

This command selects only the name and age columns from the students table.

| name | age |
|------|-----|
| Alice| 15  |
| Bob  | 16  |
| Charlie| 15 |

### Add a Calculated Column

You can also add a calculated column to your results. For example, if you want to calculate the average of two columns, english_score and history_score, you can do this:

```SQL
SELECT name, english_score, history_score, 
       (english_score + history_score) / 2 AS average_score 
FROM students;
```

This command adds a new column called `average_score` that contains the average of `english_score` and `history_score`.

| name       | english_score | history_score | average_score |
|------------|---------------|---------------|----------------|
| Alice      | 92            | 85            | 88.5           |
| Bob        | 78            | 89            | 83.5           |
| Charlie    | 85            | 90            | 87.5           |

### Filter Rows (WHERE Clause)
To filter rows based on certain conditions, you can use the `WHERE` clause. For example, if you only want to see students who scored above 90 in English, you can use this command:

```SQL
SELECT * FROM students WHERE english_score > 90;
```

This command selects all columns from the students table but only includes rows where the english_score is greater than 90.

| name   | age | english_score | history_score |
|--------|-----|---------------|----------------|
| Alice  | 15  | 92            | 85             |


### Order Rows (ORDER BY Clause)
To sort the rows based on a specific column, you can use the ORDER BY clause. For example, if you want to order the students by their average_score in descending order, you can use this command:

```SQL
SELECT name, english_score, history_score, 
       (english_score + history_score) / 2 AS average_score 
FROM students
ORDER BY average_score DESC;
```

This command sorts the rows by the `average_score` column in descending order.

| name       | english_score | history_score | average_score |
|------------|---------------|---------------|----------------|
| Alice      | 92            | 85            | 88.5           |
| Charlie    | 85            | 90            | 87.5           |
| Bob        | 78            | 89            | 83.5           |

### Group Rows (GROUP BY Clause)
To group the rows based on a specific column and perform aggregate functions, you can use the `GROUP BY` clause. For example, if you want to group the students by their age and calculate the average `english_score` for each group, you can use this command:

```SQL
SELECT age, AVG(english_score) AS avg_english_score
FROM students
GROUP BY age;
```

This command groups the rows by the age column and calculates the average english_score for each age group.

| age          | avg_english_score |
|--------------|-------------------|
| 15           | 88.5              |
| 16           | 78                |

That's it for the first section of the tutorial! You've learned how to load data, grab a whole table, pick specific columns, add a calculated column, filter rows using the `WHERE` clause, order rows using the `ORDER BY` clause, and group rows using the `GROUP BY` clause in DuckDB. Practice these commands to get comfortable with SQL basics in DuckDB.

## Exercises

_Dataset_

- {Download}`AVONET.csv<./data/AVONET.csv>` {cite}`tobias-2022`

```{admonition} Exercise
Create a new table called `birds` using the `AVONET.csv` file linked in the Datasets section.
```

```{admonition} Exercise
Select only the Species_Common_Name, Beak_Width and Beak_Depth columns from the birds table.
```

```{admonition} Exercise
Add a new calculated column called `Beak_Size` that gets the sum of the Beak_Width and Beak_Depth.
```

```{admonition} Exercise
Filter rows where the `Beak_Size` is greater than 100.
```

```{admonition} Exercise
Order the rows by `Beak_Size` in descending order.
```

```{admonition} Exercise
Group the rows by location and calculate the average `Beak_Size` for each group.
```

### Bonus exercises

_Dataset_

- {Download}`bees.csv<./data/bees.csv>` {cite}`bees-2020`

```{admonition} Exercise
Inspect the `bees.csv` file. Find out which plant families or species are most popular with different bee species.
```

```{admonition} Exercise
Find out if there is any overlap in plant species favored by native bees versus non-native bees.
```
