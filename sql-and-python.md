# 3. Combining SQL and Python

We'll show you how to leverage the power of DuckDB without even needing to write a single line of SQL. Instead, we'll use Ibis, a powerful Python library that allows you to interact with databases using a DataFrame-like syntax. We'll also show you how to combine the two so you can get the best of both worlds.

## Setting Up Your Environment

First, let's make sure you have the necessary packages installed. You can install DuckDB and Ibis using pip:

```bash
pip install duckdb ibis-framework
```

## Connecting to DuckDB

We'll start by connecting to a DuckDB database. DuckDB is an in-process SQL OLAP database management system. It works seamlessly with Python and is perfect for analytical queries.

```python
import duckdb
import ibis
```

# Connect to a DuckDB database
```python
con = ibis.duckdb.connect(database=':memory:')
```

Here, we use an in-memory database for simplicity, but you can also connect to a file-based database by specifying a file path.

# Creating a Table

Next, let's create a sample table and insert some data into it. We'll use DuckDB's SQL functionality for this step, but don't worry, this is just a one-time setup!

```SQL
con.raw_sql('''
CREATE TABLE employees (
    employee_id INTEGER,
    name TEXT,
    department TEXT,
    salary DOUBLE
);

INSERT INTO employees VALUES
(1, 'Alice', 'Engineering', 75000),
(2, 'Bob', 'Marketing', 55000),
(3, 'Charlie', 'HR', 60000);
''')
```

# Querying Data with Ibis
Now that we have a table set up, let's see how we can query this data using Ibis. With Ibis, you can perform operations on your data without writing SQL.

# Reference the employees table and select all columns
```python
employees = con.table('employees')
all_employees = employees.execute()
print(all_employees)
```

This will fetch all the rows from the employees table and print them out.

Combining SQL Queries with Ibis DataFrame Operations
One of the powerful features of Ibis is that you can combine SQL queries with DataFrame operations. For example, let's filter employees with a salary greater than 60000 and then sort them by name:

# Filter and sort
```python
high_earners = employees[employees.salary > 60000].sort_by('name')
result = high_earners.execute()
print(result)
```
This will return a DataFrame with employees who earn more than 60000, sorted by their names.

Using Only Ibis with a DuckDB Backend
Finally, let's see how we can perform more complex operations using only Ibis. Suppose we want to calculate the average salary by department:

# Group by department and calculate average salary
```python
avg_salary_by_dept = employees.groupby('department').aggregate(
    avg_salary=employees.salary.mean()
)
result = avg_salary_by_dept.execute()
print(result)
```
This will give us a DataFrame with the average salary for each department.

And that's it! You've learned how to use Ibis with DuckDB to query and manipulate your data without writing SQL. Happy coding!


# 3. Use DuckDB as the engine, all with DataFrame syntax

- Pandas, Apache Arrow, Numpy, Polars
- Ibis
- PySpark API
- DuckDB Relational API
