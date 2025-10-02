# CARTO Analytics Toolbox for Databricks

The Analytics Toolbox for Databricks contains SQL functions. The functions are deployed in a schema called `carto` inside a specific catalog.

CARTO Analytics Toolbox for Databricks provides geospatial functionality on top of spatial SQL functions.

## Tools

Make sure you have installed the following tools:

- `make`: <https://www.gnu.org/software/make/>
- `Python3`: <https://www.python.org/downloads/release/python-3811> (v3.8.11)
- `virtualenv`: <https://virtualenv.pypa.io/en/latest/> (v20.11)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox.

```
# Databricks
DB_PREFIX=
DB_CATALOG=
DB_HOST_NAME=
DB_HTTP_PATH=
DB_TOKEN=
```

- *Server hostname*: SQL Warehouses > Connection details
- *HTTP path*: SQL Warehouses > Connection details
- *Access token*: Settings > Developer > Access tokens

## Structure

- `common`
- `modules`
  - `doc`: contains the functions' documentation
  - `sql`: contains the functions' SQL code
  - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter and fixes the trivial issues (markdownlint, sqlfluff, brunette, flake8)
- `make build`: builds the final SQL script
- `make deploy`: builds and deploys the SQL scripts in the Databricks database
- `make test`: runs the modules tests with the Databricks database (pytest)
- `make remove`: removes all the SQL scripts from the Databricks database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates the installation package in the dist folder (zip)
