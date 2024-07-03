# Setup instructions

## Installation

1. Log into <a href="https://colab.research.google.com/" target="_blank">Google Colab</a> or start a local <a href="https://jupyter.org/install" target="_blank">Jupyter Notebook</a>.
2. Install the latest version of `duckdb` and `magic_duckdb` by running:
    ```bash
    !pip install --upgrade duckdb magic-duckdb
    ```
3. (For section 5) <a href="https://app.motherduck.com/?auth_flow=signup" target="_blank">Sign up for MotherDuck</a>


## How to run SQL queries

Throughout this tutorial, we'll show you SQL queries that you can run to inspect and manipulate data with DuckDB. DuckDB offers two database modes: in-memory and file-based. In-memory databases store data in RAM, providing lightning-fast operations but losing data when closed, ideal for temporary processing. File-based databases store data on disk, offering persistence and larger data capacity, suitable for long-term storage and sharing. You can easily switch between modes, allowing flexibility to balance performance and data retention needs.

### Jupyter Notebook: in-memory database

For the first two sections of this tutorial, we recommend using an in-memory database, since all examples are self-contained and can easily be re-run if needed.

You can run SQL directly in a Jupyter Notebook with a Python kernel by loading the `magic_duckdb` extension:

```python
%load_ext magic_duckdb
```

and using the `%%dql` magic command:

```python
%%dql
-- Your query here
SELECT 42;
```

### Jupyter Notebook: persistent database

For the latter part of this tutorial, we will cover data sharing and collaboration. To persist your tables to a file or remote database, you can explicitly create a new connection in Python:

```python
import duckdb
con = duckdb.connect("my_database.db")
```

In a separate cell, pass the connection object to the magic command with the `-co` option:

```python
%%dql -co con
CREATE TABLE test_table as (SELECT 42);
FROM test_table;    -- this is a short form of SELECT * FROM test_table
```


### MotherDuck

You can also run SQL directly in a MotherDuck notebook. After <a href="https://app.motherduck.com/?auth_flow=signup" target="_blank">signing up</a>, go to <a href="https://app.motherduck.com/" target="_blank">app.motherduck.com</a> and log in. You'll see a SQL notebook environment where you can create cells, upload CSV files and run SQL queries.


## How to read files

In a local Jupyter notebook, you can use the local filesystem with no extra steps!

In Google Collab, you'll need to mount a folder in Google Drive, which makes all files in that folder available to query under `/content/gdrive/MyDrive` path:
```
from google.colab import drive
drive.mount('/content/gdrive')
```

In MotherDuck, you can add JSON, CSV or Parquet file directly using the Add Files button in the top left of the UI.