# CARTO Analytics Toolbox for Redshift

The Analytics Toolbox for Redshift contains SQL functions. The functions are deployed in a schema called `carto` inside a specific database. In Redshift, the functions can be used with tables of the same database, but different schemas.

Note: Redshift UDFs only support Python2 but the Python Redshift connector is only available in Python3. Therefore, both Python versions are required to develop the toolbox.

## Tools

Make sure you have installed the following tools:

- `make`: <https://www.gnu.org/software/make/>
- `Python2`: <https://www.python.org/downloads/release/python-2718/> (v2.7.18)
- `Python3`: <https://www.python.org/downloads/release/python-3811> (v3.8.11)
- `aws`: <https://aws.amazon.com/cli/> (v2.4)
- `jq`: <https://stedolan.github.io/jq/> (v1.6)
- `virtualenv`: <https://virtualenv.pypa.io/en/latest/> (v20.11)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values.

```
# Redshift
RS_PREFIX=
RS_HOST=<cluster>.<account>.<region>.redshift.amazonaws.com
RS_DATABASE=<database>
RS_USER=<user>
RS_PASSWORD=<password>
AWS_ACCESS_KEY_ID=<access-key-id>
AWS_SECRET_ACCESS_KEY=<secret-access-key>
```

## Structure

- `common`: Common build scripts and utilities
- `modules`
  - `doc`: contains the functions' documentation
  - `sql`: contains the functions' SQL code
  - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (flake8) and fixes the trivial issues (brunette)
- `make build-modules`: builds the final SQL scripts
- `make deploy`: builds and deploys SQL scripts to the Redshift database
- `make test`: runs the modules tests with the Redshift database (pytest)
- `make remove`: removes SQL functions from the Redshift database
- `make clean`: cleans the installed dependencies and generated files locally

**Filtering**

Commands `build-modules`, `deploy-modules`, and `test-modules` can be filtered by the following. All the filters are additive:

- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

Example:

```
make build-modules diff=modules/sql/quadbin/QUADBIN_RESOLUTION.sql
make deploy-modules modules=quadbin,constructors
make test-modules functions=ST_MAKEENVELOPE
```
