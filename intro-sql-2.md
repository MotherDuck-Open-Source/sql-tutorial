# 2. Learn to quack SQL with DuckDB: Joins and Subqueries

## Understanding SQL Joins
In SQL, a Join operation allows you to combine rows from two or more tables based on a related column between them. This is incredibly useful when you need to pull together related information that is stored in different tables.

### Example Tables
Let's start with two tables:

#### Table 1: Students

{Download}`student_ids.csv<./data/student_ids.csv>`

| StudentID | Name |
| --------- | ---- |
| 1 | Alice |
| 2 | Bob |
| 3 | Charlie |


#### Table 2: Grades

{Download}`grades.csv<./data/grades.csv>`

| StudentID | Course | Grade |
| --------- | ------ | ----- |
| 1 | Math | 85 |
| 1 | Science | 90 |
| 2 | Math | 78 |
| 3 | Math | 92 |
| 3 | Science | 88 |

To create the tables in your database, run:

```SQL
create table Student_info as select * from read_csv('student_ids.csv');
create table Grades as select * from read_csv('grades.csv');
```

### Performing a SQL Join

We want to combine these tables to find the average grade for each student. To do this, we'll use a SQL Join operation. Specifically, we'll use an INNER JOIN, which combines rows from both tables only when there is a match in the StudentID column.

```SQL
SELECT Student_info.Name, Grades.Course, Grades.Grade
  FROM Student_info
  INNER JOIN Grades ON Student_info.StudentID = Grades.StudentID
  ORDER BY Student_info.Name;
```

This combines the two columns so we can conveniently see the student name next to their grades.

### Step-by-Step Explanation
Let's break down the SQL query step by step:

`SELECT Student_info.Name, Grades.Course, Grades.Grade`: We're selecting the student's name and their grade per course.

`FROM Student_info`: We're starting with the Student_info table.

`INNER JOIN Grades ON Student_info.StudentID = Grades.StudentID`: We're joining the Grades table to the Student_info table where the StudentID matches in both tables.

`ORDER BY Student_info.Name`: We're sorting the results by the student's name.

### Result
After running the SQL query, the result will look like this:

| Name | Course | Grade |
| --- | --- | --- |
| Alice   | Math    |    85 |
| Alice   | Science |    90 |
| Bob     | Math    |    78 |
| Charlie | Math    |    92 |
| Charlie | Science |    88 |

### Conclusion

And that's it! You've successfully learned how to use a SQL Join to combine two tables and extract useful information. Practice this with different datasets to get more comfortable with SQL Joins. Happy querying!

## 2. Subqueries

### What is a Subquery?

A subquery, also known as an inner query or nested query, is a query within another SQL query. It's like a query inside a query! Subqueries are used to perform operations that require multiple steps, such as filtering data based on a complex condition or aggregating data before using it in the main query.

### Example

Let's start by looking at our example table, `students.csv`. This table contains the following columns:

- name: The name of the student.
- age: The age of the student.
- grade: The grade the student is in.
- score: The student's score in the last exam.

### Using Subqueries in DuckDB

Let's dive into some examples to understand how subqueries work in DuckDB.

#### Example 1: Finding Top Scorers
Suppose we want to find the students who scored above the average score. We can use a subquery to calculate the average score first, and then use that result in our main query:

```SQL
SELECT Name, Grade
FROM Students
WHERE score > (SELECT AVG(Grade) FROM Students);
```

In this example, the subquery (`SELECT AVG(score) FROM students`) calculates the average score of all students. The main query then selects the names and scores of students who scored above this average.

#### Example 2: Finding Students in the Top Grade

Next, let's find the students who are in the same grade as the student with the highest score. Here's how we can do it:

```SQL
SELECT name, grade, score
FROM students
WHERE grade = (SELECT grade
               FROM students
               ORDER BY score DESC
               LIMIT 1);
```

In this example, the subquery (`SELECT grade FROM students ORDER BY score DESC LIMIT 1`) finds the grade of the student with the highest score. The main query then selects the names, grades, and scores of all students in that grade.

#### Example 3: Using the WITH Clause

Now, let's see how we can use the `WITH` clause to make our queries more readable. Suppose we want to find the names and scores of students who scored above the average score. Here's how we can do it using the `WITH` clause:

```SQL
WITH avg_score AS (
    SELECT AVG(score) AS avg
    FROM students
)
SELECT name, score
FROM students, avg_score
WHERE students.score > avg_score.avg;
```

In this example, the `WITH` clause creates a temporary result set called `avg_score` that contains the average score. The main query then selects the names and scores of students who scored above this average.

## Exercises

### Datasets

- {Download}`birds.csv<./data/birds.csv>` {cite}`tobias-2022`
- {Download}`ducks.csv<./data/ducks.csv>` {cite}`col-2024`

```{admonition} Exercise
Create a new table `ducks` by using the file `ducks.csv`, which contains species names and common names of ducks.
```

```{admonition} Exercise
Join the `birds` and `ducks` tables and create a table `duck_beaks` with the name and beak size of birds that are ducks.
``` 

```{admonition} Exercise
Get the average beak size for all birds, and the average beak size for all birds that are ducks.
```

```{admonition} Exercise
Run a query that gets the number of birds that have a beak size that is below the average beak size for all birds.
Then, do the same thing, but for all _ducks_.
```
