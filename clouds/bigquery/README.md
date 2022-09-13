# CARTO Analytics Toolbox for Bigquery

The Analytics Toolbox for Bigquery contains SQL functions and JavaScript libraries. The functions are deployed in a dataset called `carto` inside a specific project. The JavaScript libraries are deployed inside the SQL functions. In Bigquery, the functions can be used with tables of any project in the same account.

## Tools

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `node`: https://www.npmjs.com/ (v14.18)
- `yarn`: https://yarnpkg.com/ (v1.22)
- `bq`: https://cloud.google.com/bigquery/docs/bq-command-line-tool
- `gsutil`: https://cloud.google.com/storage/docs/gsutil (v5.5)

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values.
```
# Bigquery
BQ_PREFIX=
BQ_PROJECT=<project>
BQ_BUCKET=gs://<bucket>/ or gs://<bucket>/<folder>/
BQ_REGION=<region>
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/or/adc.json
```

Note: you may need to run `gcloud auth login` to generate the `acd.json` file.

## Structure

- `common`
- `libraries`
    - `javascript`: JavaScript library
        - `libs`: contains the JavaScript module-specific code
        - `src`: contains the JavaScript source code
        - `test`: contains the library tests
- `modules`
    - `doc`: contains the functions' documentation
    - `sql`: contains the functions' SQL code
    - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (eslint) and fixes the trivial issues
- `make build`: builds the final SQL scripts and libraries (JS)
- `make deploy`: builds the JS libraries and SQL scripts and deploys in the Bigquery project
- `make test`: runs the library tests locally and the modules tests with the Bigquery project (jest)
- `make remove`: removes the SQL scripts from the Bigquery project
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates the installation package in the dist folder (zip)

Make commands can be run also inside `libraries/javascript` and `modules` folders, or be called like `make lint-libraries`, `make deploy-modules`.

**Filtering**

Commands `build-libraries`, `build-modules`, `deploy-modules`, `test-libraries`, `test-modules` and `create-package` can be filtered by the following. All the filters are additive:
- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

Example:

```
make build-libraries diff=modules/sql/quadbin/QUADBIN_BBOX.sql
make build-modules diff=modules/sql/quadbin/QUADBIN_RESOLUTION.sql
make deploy-modules modules=quadbin,constructors
make test-modules functions=ST_MAKEENVELOPE
make create-package modules=quadbin
```

Command `test-libraries` can be also filtered by setting the `test` variable with a path of the test file. It supports passing the name of the test. Note that `build-libraries` will rebuild the libraries to make them suitable for testing.

Example:

```
make test-libraries modules=constructors test=constructors.test.js
make test-libraries functions=ST_BUFFER test="transformations_buffer.test.js -t buffer"
```

Additionally, `nodeps=1` filter can be passed to skip building and including the dependencies. It can be used to speed up re-deployments during development.
