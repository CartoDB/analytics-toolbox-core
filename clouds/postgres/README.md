# CARTO Analytics Toolbox for Postgres

The Analytics Toolbox for Postgres contains SQL functions. The functions are deployed in a schema called `carto` inside a specific database. In Postgres, the functions can be used with tables of the same database, but different schemas.

## Tools

Make sure you have installed the following tools:

- `make`: <https://www.gnu.org/software/make/>
- `Python3`: <https://www.python.org/downloads/release/python-3811> (v3.8.11)
- `jq`: <https://stedolan.github.io/jq/> (v1.6)
- `virtualenv`: <https://virtualenv.pypa.io/en/latest/> (v20.11)

### Python version issuse with numpy

`make build-modules` will fail in case of `Python3.10.x` due to lack of `numpy` package compatible with this python version.
Unfortunally Ubuntu 20.4 LTS install Python 3.10.6 by default
To solve the issue Install a lower version e.g. under ubuntu:
```
apt install software-properties-common
# add repo with python packages
add-apt-repository ppa:deadsnakes/ppa
apt install python3.9-full python3.9-distutils
```
then modify []./common/Makefile](https://github.com/CartoDB/analytics-toolbox-core/blob/main/clouds/postgres/common/Makefile#L3) python version
used to setup virtual env

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values.

```
# Postgres
PG_PREFIX=
PG_HOST=<host>
PG_DATABASE=<database>
PG_USER=<user>
PG_PASSWORD=<password>
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

Make commands can be run also inside `modules` folders, or be called like `make ***-modules`.

**Filtering**

Commands `build-modules`, `deploy-modules`, `test-modules` and `create-package` can be filtered by the following. All the filters are additive:

- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

Example:

```
make build-modules diff=modules/sql/quadbin/QUADBIN_RESOLUTION.sql
make deploy-modules modules=quadbin
make test-modules functions=QUADBIN_RESOLUTION
make create-package modules=quadbin
```
