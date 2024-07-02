# Learn SQL the Quacky way!

As scientists and Python developers, you're likely familiar with NumPy or DataFrame tools like Pandas, Polars or PyArrow for data manipulation and analysis. These are powerful tools, but as your datasets grow and your analyses become more complex, you may find yourself pushing against its limits. This is where SQL comes in.

[Structured Query Language](https://duckdb.org/docs/sql/introduction.html) (or SQL for short) is the standard language for interacting with relational databases. It's been around for decades and remains crucial in the data science toolkit. DuckDB is an in-process SQL OLAP database management system, designed to be fast and efficient for analytical queries. It is a database that lives in-process which makes it fast, portable and easy to use and deploy. It's especially great for learning SQL because all you need to do is to download it, and it runs right on your laptop! It combines the simplicity of SQLite with the analytical power of traditional data warehouses. But why should you care about SQL or `duckdb`?

Let's start with a simple example. Imagine you're working with a large climate dataset, and you want to filter it to find all records where the temperature is above 25°C and precipitation is below 10 mm. With `pandas`, you might write:


```python
import pandas as pd

df = pd.read_csv('washington_weather.csv')
filtered_df = df[(df['temperature'] > 25) & (df['precipitation'] < 10)]
```

This works well for small to medium-sized datasets. But what if your data doesn't fit in memory? What if you're working with a database that's constantly being updated? What if you're working in an environment where Python is not available? Here's how you'd do the same thing in SQL:

```sql
SELECT *
FROM read_csv('washington_weather.csv')
WHERE temperature > 25 AND precipitation < 10;
```

This SQL query can work on datasets of any size, is often more efficient, and can be run directly on the database server, reducing data transfer.

Throughout this tutorial, we'll explore how SQL can complement your Python skills, enabling you to:

- Load data and perform basic operations such as filtering, sorting, grouping and adding a calculated column.
- Combine data and filtering rows based on data from multiple tables
- Use SQL and Python to get the best of both worlds
- Use SQL for fast and efficient data visualization
- Share your data with your collaborators and efficiently access large amounts of data

By the end of this tutorial, you'll have a solid understanding of SQL basics, how to integrate SQL with your Python workflows, and when to choose SQL over DataFrame tools (and vice versa).


## Setup instructions


1. Log into [Google Colab](https://colab.research.google.com/) or start a local [Jupyter Notebook](https://jupyter.org/install).
2. Install the latest version of `duckdb` by running `pip install --upgrade duckdb`.
3. (Optional for the "Do more with your data" section) Sign up for MotherDuck via https://app.motherduck.com/?auth_flow=signup
