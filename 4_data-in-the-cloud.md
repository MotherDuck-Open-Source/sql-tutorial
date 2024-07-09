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

<a target="_blank" href="https://colab.research.google.com/github/MotherDuck-Open-Source/sql-tutorial">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

# 4. Collaborating with data in the Cloud

To start off, install the latest version of `duckdb`, `magic-duckdb` and `dash` to run this notebook.

```{code-cell}
!pip install duckdb==1.0.0 magic-duckdb dash -q
%load_ext magic_duckdb
```

We're also going to create a helper variable `IN_COLAB` to see if we're running Google Colab. This will come in handy later.

```{code-cell}
try:
  import google.colab
  IN_COLAB = True
except:
  IN_COLAB = False
```

## Sign up for MotherDuck

If you haven't already done it, [sign up for MotherDuck](https://app.motherduck.com/?auth_flow=signup).

To connect to MotherDuck, all you need to do is connect to a `duckdb` database! Your MotherDuck databases will be accessible with the `md:` prefix. For example, to connect to the `sample_data` database and show the tables, uncomment the following lines and run:

```{code-cell}
import duckdb
con = duckdb.connect("md:sample_data")
```

However, this will throw an error! You actually need to specify your authentication token to connect to MotherDuck.

To do so, you can [copy your token](https://app.motherduck.com/token-request?appName=Jupyter) from Motherduck and add it to your notebook "Secrets".

If you are using Google Colab, you can click on the "Secrets" tab and add a new "token" secret there. See how to do that in the screenshot below.

<img src="https://github.com/MotherDuck-Open-Source/sql-tutorial/blob/main/notebooks/Colab_Secret.png?raw=true" width=400>

Now, you can get your token from the secrets manager and load it into an environment variable. After this, you can connect to MotherDuck without any extra authentication steps!

```{code-cell}
import os

if IN_COLAB:
  from google.colab import userdata
  os.environ["motherduck_token"] = userdata.get('token')
```

If you're running in a Jupyter Notebook elsewhere, you can uncomment and run the following, and paste your token in the input field:

```{code-cell}
# import getpass
# os.environ["motherduck_token"] = getpass.getpass(prompt='Password: ', stream=None)
```

```{admonition} Exercise 4.01
Create a connection to MotherDuck and show all tables in your `sample_data` database. You can use the `SHOW TABLES` command that is documented [here](https://duckdb.org/docs/guides/meta/list_tables.html).
```

## Run a query against DuckDB in the Cloud

You are now all ready to go and query your Cloud data warehouse! One example in the `sample_data` database is the `service_requests` table, which contains [New York City 311 Service Requests](https://motherduck.com/docs/getting-started/sample-data-queries/nyc-311-data/) with requests to the city's complaint service from 2010 to the present.

To query the data, you'll want to fully specify the table name with the following format:

```sql
<database name>.<schema>.<table name>
```

For example, you can run the below cell to get the service requests between March 27th and 31st of 2022:

```{code-cell}
%%dql -co con
SELECT
  created_date, agency_name, complaint_type,
  descriptor, incident_address, resolution_description

FROM
  sample_data.nyc.service_requests
WHERE
  created_date >= '2022-03-27' AND
  created_date <= '2022-03-31';
```

```{admonition} Exercise 4.02
Take a look at the `sample_data.who.ambient_air_quality` 
```

## Load data from Huggingface

Now, let's try to load some data from a data source into MotherDuck. HuggingFace has recently released an extension for DuckDB, that lets you access and query their entire [datasets library](https://huggingface.co/datasets)!

To query a HuggingFace dataset, you can run:

```{code-cell}
%%dql -co con
SELECT * FROM read_parquet('hf://datasets/datonic/threatened_animal_species/data/threatened_animal_species.parquet');
```

Before we create a new table with this data, let's first swap to a different database. You can do so by creating a new DuckDB connection, or by changing the database with the `USE` statement. For example, to connect to your default database, `my_db`, run:

```{code-cell}
%%dql -co con
USE my_db;
```

```{admonition} Exercise 4.03
Create a new table called `animals` in your MotherDuck database `md:my_db` based on the `datonic/threatened_animal_species` dataset.
```

```{admonition} Exercise 4.04
DuckDB releases are each named after a duck! Let's load [this data](https://duckdb.org/data/duckdb-releases.csv) into a new table called `duckdb_ducks`. You can use `read_csv` to load the data directly from the HTTP URL: `https://duckdb.org/data/duckdb-releases.csv`.
```

## Sharing is caring: Teach your data to fly!

Now, we have two tables that we can join together and share with our colleagues!

Let's inspect them and take a look at the columns we have available.

```{code-cell}
%%dql -co con
DESCRIBE animals;
```

```{code-cell}
%%dql -co con
DESCRIBE duckdb_ducks;
```

Now, we can get the endangered species status of all DuckDB ducks by joining the two.

```{code-cell}
%%dql -co con
CREATE OR REPLACE TABLE duckdb_species AS
SELECT
  duckdb_ducks.version_number, duckdb_ducks.codename, duckdb_ducks.duck_species_primary, animals.category
FROM duckdb_ducks
LEFT JOIN animals
ON animals.scientific_name = duckdb_ducks.duck_species_primary
WHERE codename IS NOT NULL
ORDER BY category, version_number;
```

```{admonition} Exercise 4.05
Create a new table called `duckdb_species` that joins the `duckdb_ducks` and `animals` tables on the scientific name.
```

To share your database, you can run:

```{code-cell}
%%dql -co con -o df
CREATE SHARE duck_share FROM my_db (ACCESS UNRESTRICTED);
```

Now you can print the share URL:
```{code-cell}
print(df.share_url.iloc[0])
```

```{admonition} Exercise 4.06
Check out these datasets from Huggingface: https://huggingface.co/datasets. Pick one, create a share and send it to your neighbor!
```

To attach a share into your Cloud data warehouse, run:

```sql
ATTACH '<share_url>';
```

For example, to load the [Mosaic example datasets](https://github.com/motherduckdb/wasm-client/tree/main), run

```{code-cell}
%%dql -co con
ATTACH 'md:_share/mosaic_examples/b01cfda8-239e-4148-a228-054b94cdc3b4';
```

You can then inspect the database and query the data like so:

```{code-cell}
%%dql -co con
USE mosaic_examples;
SHOW TABLES;
```

```{code-cell}
%%dql -co con
SELECT * FROM seattle_weather;
```

```{admonition} Exercise 4.07
Attach the share you received from your neighbor, inspect the tables.
```
