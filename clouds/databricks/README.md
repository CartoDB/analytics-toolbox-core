# CARTO Analytics Toolbox for Databricks

CARTO Analytics Toolbox for Databricks provides geospatial functionality leveraging the GeoMesa SparkSQL capabilities. It implements Spatial Hive UDFs. In order to install the toolbox the library (jar-with-dependencies) needs to be installed in the cluster you are using, and the Hive UDFs registered via createUDFs sql script

## Tools

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `jdk (8 or 11)`: https://www.oracle.com/java/technologies/javase/javase8u211-later-archive-downloads.html (v8.x)
- `sbt`: https://www.scala-sbt.org/1.x/docs/Setup.html (v1.x)
- `Python3.6 and above`: https://www.python.org/downloads/release/python-3811 (v3.8.11)
- `databricks cli`: https://docs.databricks.com/dev-tools/cli/index.html
- `jq`: https://stedolan.github.io/jq/ (v1.6)

In order to set up authentication you can use a databricks token and the databricks host URL.

```
databricks configure --token
```

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values. Only the cluster id is mandatory. Default schema is 'default'.

```
# Databricks
DB_DATASET_PREFIX=
DB_CLUSTER_ID=<cluster-id>
DB_SCHEMA=<schema>
# For Databricks integration tests
DATABRICKS_SERVER_HOSTNAME=<hostname>
DATABRICKS_HTTP_PATH=<http_path>
DATABRICKS_TOKEN=<token>
```

## Structure

- `common`
- `libraries`
    - `scala`: Python library
        - `core/src/main`: contains the scala code
        - `core/src/test`: contains the library tests
- `modules`
    - `doc`: contains the functions' documentation
    - `sql`: contains the functions' SQL code, in databricks this is only used to register the functions
    - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (scalafix)
- `make build`: Builds the jar to deploy
- `make deploy`: builds and deploys the libraries in the Redshift cluster, and SQL scripts in the Redshift database
- `make test`: runs the the modules tests with the Databricks cluster (pytest)
- `make remove`: removes all the libraries and SQL functions from the Databricks cluster and database
- `make clean`: cleans the installed dependencies and generated files locally
