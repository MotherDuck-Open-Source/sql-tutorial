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

# Setup instructions

To get started with the tutorial, you'll need an interactive Python notebook environment.

## Option 1: Run in Colab

To get started without any setup required, <a target="_blank" href="https://colab.research.google.com/github/MotherDuck-Open-Source/sql-tutorial">open the tutorial in Colab</a>.

This requires a Google account. If you don't have one, you can <a href="https://accounts.google.com/signup" target="_blank">sign up</a>, or try the other options below.

## Option 2: Run in Jupyter Notebook on your laptop

1. Browse to a folder in your home directory where you want to keep your tutorial files and clone the GitHub repo:
```bash
git clone git@github.com:MotherDuck-Open-Source/sql-tutorial.git
```
2. Create a new Python virtual environment and activate it:
```bash
python3 -m venv venv
source venv/bin/activate
```
3. Start a local <a href="https://jupyter.org/install" target="_blank">Jupyter Notebook</a> in the `notebooks` folder:
```
cd notebooks
jupyter notebook .
```

Now you can open the `.ipynb` files accompanying the tutorial and run them cell by cell, add your own cells or make edits where needed.

## Option 3: Run in MotherDuck

For the parts that require only SQL, you can run them in the MotherDuck app. To access the app, <a href="https://app.motherduck.com/?auth_flow=signup" target="_blank">sign up for MotherDuck</a>.

Every new account receives a 30-day free trial of the MotherDuck Standard Plan, with no credit card required. After the end of your Standard Plan free trial, your account will automatically move to the MotherDuck Free Plan, no action needed on your part.

# How to run SQL queries

Throughout this tutorial, we'll show you SQL queries that you can run to inspect and manipulate data with DuckDB. DuckDB offers two database modes: in-memory and file-based. In-memory databases store data in RAM, providing lightning-fast operations but losing data when closed, ideal for temporary processing. File-based databases store data on disk, offering persistence and larger data capacity, suitable for long-term storage and sharing. You can easily switch between modes, allowing flexibility to balance performance and data retention needs.

## Jupyter Notebook: in-memory database

For the first two sections of this tutorial, we will use an in-memory database, since all examples are self-contained and can easily be re-run if needed.

You can run SQL directly in a Jupyter Notebook with a Python kernel by installing and loading the `magic_duckdb` extension:

```python
!pip install --upgrade duckdb magic-duckdb --quiet
%load_ext magic_duckdb
```

and using the `%%dql` magic command:

```python
%%dql
SELECT 42;
```

## Jupyter Notebook: persistent database

For the latter part of this tutorial, we will cover data sharing and collaboration. To persist your tables to a file or remote database, you can explicitly create a new connection in Python:

```python
import duckdb
con = duckdb.connect("my_database.duckdb")
```

In a separate cell, pass the connection object to the magic command with the `-co` option:

```python
%%dql -co con
CREATE TABLE test_table as (SELECT 42);
SELECT * FROM test_table;
```

## MotherDuck

You can also run SQL directly in a MotherDuck notebook. After <a href="https://app.motherduck.com/?auth_flow=signup" target="_blank">signing up</a>, go to <a href="https://app.motherduck.com/" target="_blank">app.motherduck.com</a> and log in. You'll see a SQL notebook environment where you can create cells, upload CSV files and run SQL queries.

Once you have the account and [get the authentication token](https://motherduck.com/docs/key-tasks/authenticating-to-motherduck/#creating-an-access-token), you can interact with your data in MotherDuck through the same Python API:

```python
import duckdb
con = duckdb.connect(f"md:my_db?motherduck_token={token}")
```

## How to access files

In a local Jupyter notebook, you can use the local filesystem with no extra steps.

In Google Colab, you can download the files using `!wget <url>` and access them directly. Another option is to mount a folder in Google Drive, which makes all files in that folder available to query under `/content/gdrive/MyDrive` path:

```
from google.colab import drive
drive.mount('/content/gdrive')
```

In MotherDuck, you can add JSON, CSV or Parquet file directly using the Add Files button in the top left of the UI.
