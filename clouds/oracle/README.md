# CARTO Analytics Toolbox for Oracle

The Analytics Toolbox for Oracle contains SQL functions and procedures. The functions are deployed in a schema called `CARTO` inside the Oracle database. In Oracle, the functions can be used with cross-schema access using fully qualified names or by granting EXECUTE permissions.

## Tools

Make sure you have installed the following tools:

- `make`: <https://www.gnu.org/software/make/>
- `Python3`: <https://www.python.org/downloads/> (v3.10+)
- `node`: <https://nodejs.org/> (v20+)
- `yarn`: <https://yarnpkg.com/>
- `virtualenv`: <https://virtualenv.pypa.io/en/latest/>

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values.

```
# Oracle
ORA_PREFIX=
ORA_USER=<database-user>
ORA_PASSWORD=<user-password>
ORA_WALLET_ZIP=<base64-encoded-wallet-zip>
ORA_WALLET_PASSWORD=<wallet-password>
```

Note: `ORA_WALLET_ZIP` is the base64-encoded content of the Oracle wallet ZIP file (`base64 -i Wallet_YourDB.zip | tr -d '\n'`). `ORA_PREFIX` sets the schema name prefix, e.g. `DEV_` → schema `DEV_CARTO`. Leave empty or use `production=1` for schema `CARTO`.

## Structure

- `common`: Common build scripts and utilities
- `modules`
  - `doc`: contains the functions' documentation
  - `sql`: contains the functions' SQL code
  - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (flake8, sqlfluff) and fixes the trivial issues (brunette)
- `make build`: builds the final SQL scripts
- `make deploy`: builds and deploys SQL scripts to the Oracle database
- `make test`: runs the modules tests with the Oracle database (pytest)
- `make remove`: removes SQL functions from the Oracle database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates a distributable package (ZIP file)

**Filtering**

Commands `build-modules`, `deploy-modules`, and `test-modules` can be filtered by the following. All the filters are additive:

- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

Example:

```
make build-modules diff=modules/sql/utils/VERSION_ADVANCED.sql
make deploy-modules modules=utils
make test-modules functions=VERSION_CORE
```
