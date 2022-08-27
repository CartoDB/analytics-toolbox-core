# CARTO Analytics Toolbox for Postgres

The Analytics Toolbox for Postgres contains SQL functions. The functions are deployed in a schema called `carto` inside a specific database. In Postgres, the functions can be used with tables of the same database, but different schemas.

## Tools

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `Python3`: https://www.python.org/downloads/release/python-3811 (v3.8.11)
- `jq`: https://stedolan.github.io/jq/ (v1.6)
- `virtualenv`: https://virtualenv.pypa.io/en/latest/ (v20.11)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox.

```
# Postgres
PG_PREFIX=
PG_HOST=your-postgres-host.com
PG_DATABASE=your-postgres-database
PG_USER=your-postgres-user
PG_PASSWORD=your-postgres-password
```

## Structure

- `common`
- `modules`
    - `doc`: contains the functions' documentation
    - `sql`: contains the functions' SQL code
    - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (flake8) and fixes the trivial issues (brunette)
- `make build`: builds the final SQL script
- `make deploy`: builds and deploys the SQL scripts in the Postgres database
- `make test`: runs the modules tests with the Postgres database (pytest)
- `make remove`: removes all the SQL scripts from the Postgres cluster and database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates the installation package in the dist folder (zip)

Make commands can be run also inside `modules` folders, or be called like `make deploy-modules`.

**Filtering**

Commands `build`, `deploy`, `test` and `create-package` can be filtered by the following. All the filters are additive:
- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

For example:

```
make lint diff=modules/quadbin/test/test_QUADBIN_RESOLUTION.py
make deploy modules=quadbin
make test functions=QUADBIN_RESOLUTION
```
