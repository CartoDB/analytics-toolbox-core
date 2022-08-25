# CARTO Analytics Toolbox Core

The *CARTO Analytics Toolbox* is a set of UDFs and Stored Procedures to unlock Spatial Analytics. It is organized into modules based on the functionality they offer. This toolbox is cloud-native, which means it is available for different data warehouses: BigQuery, Snowflake, and Redshift. It is built on top of the data warehouse's GIS features, extending and complementing this functionality.

This repo contains the core open-source modules of the toolbox. CARTO offers a set of premium modules that are available for CARTO users.

## Getting started

Using the functions on this project depends on the Datawarehouse you are using. In BigQuery and Snowflake you can access them directly as a shared resoueces without having to install them, for the rest you will have to install them locally on your database.

### BigQuery

You can use directly the functions as they are globally shared in the US region.

```sql
SELECT `carto-os.carto.H3_CENTER`('847b59dffffffff')
```

If you need to use them from the Europe region use:

```sql
SELECT `carto-os-eu.carto.H3_CENTER`('847b59dffffffff')
```

If you need to install them on your own VPC or in a different region, follow the instructions later on.

### Snowflake

The easiest way to start using these functions is to add them to your Datawarehouse through the [Snowflake Marketplace](https://www.snowflake.com/datasets/carto-analytics-toolbox/). Go there and install it using theregular methods. After that you should be able to use them on the location you have installed them. For example try:

```sql
SELECT carto.H3_FROMGEOGPOINT(ST_POINT(40.4168, -3.7038), 4)
```

If you need to install them directly, not through the data share process, follow the instructions later on.

### Redshift

Right now the only way to get access the Analytics toolbox is by installing it directly on your database. Follow the instructions later on.


## Documentation

| Cloud | Documentation |
|---|---|
| BigQuery | https://docs.carto.com/analytics-toolbox-bigquery |
| Snowflake | https://docs.carto.com/analytics-toolbox-snowflake |
| Redshift | https://docs.carto.com/analytics-toolbox-redshift |
| Databricks | https://docs.carto.com/analytics-toolbox-databricks |
## Development

The repo contains the implementation of the toolbox for all the clouds. The functions are organized in modules. Each module has the following structure:
- `doc`: contains the SQL reference of the functions
- `lib`: contains the library code (JavaScript/Python)
- `sql`: contains the function's code (SQL)
- `test`: contains both the unit and integration tests

Inside a module, you can run the following commands. These commands are available for any {module}/{cloud}. For example, you can enter the module `cd modules/accessors/bigquery` and then run the command:
- `make help`: shows the commands available in the Makefile.
- `make lint`: runs a linter (using eslint or flake8).
- `make lint-fix`: runs a linter (using eslint or flake8) and fixes the trivial issues.
- `make build`: builds the bundles (using rollup or zip).
- `make deploy`: builds the bundles and deploys and SQL functions to the data warehouse using the env variables.
- `make test-unit`: builds the bundles and runs the unit tests for these bundles (using jest or pytest).
- `make test-integration`: runs just the integration tests (using jest or pytest). It performs requests to real data warehouses.
- `make test-integration-full`: runs the full-path integration tests (using jest or pytest). It is equivalent to `deploy` + `test-integration` + `clean-deploy`.
- `make clean`: removes the installed dependencies and generated files.
- `make clean-deploy`: removes all the assets, functions, procedures, tables uploaded in the `deploy`.

These commands can be used with all the modules at once from the root folder. For example, `make deploy CLOUD=bigquery`.

Additionally, [this tool](./tools/setool/) has been developed to generate code templates for new modules and functions.

| Cloud | Development |
|---|---|
| BigQuery | |
| Snowflake |  |
| Redshift | [README.md](./clouds/redshift/README.md) |

### BigQuery

The Analytics Toolbox for BigQuery contains SQL functions and JavaScript libraries. The functions are deployed in a dataset called `carto` inside a specific project. In BigQuery, datasets are associated with a region so the functions can only be used with tables stored in datasets with the same region. The JavaScript libraries are deployed in a Google Cloud Storage bucket and referenced by the functions.

**Tools**

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `node`: https://www.npmjs.com/ (v14.18)
- `yarn`: https://yarnpkg.com/ (v1.22)
- `bq`: https://cloud.google.com/bigquery/docs/bq-command-line-tool
- `gsutil`: https://cloud.google.com/storage/docs/gsutil (v5.5)

**Environment variables**

The `.env` file contains the variables required to deploy and run the toolbox.

```
# BigQuery
BQ_PROJECT=your-bigquery-project
BQ_BUCKET=gs://your-gcs-bucket/
BQ_REGION=your-region
BQ_DATASET_PREFIX=
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service/account/or/adc.json
```

Note: you may need to run `gcloud auth login` to generate the `acd.json` file.

### Snowflake

The Analytics Toolbox for Snowflake contains SQL functions and JavaScript libraries. The functions are deployed in a schema called `carto` inside a specific database. The JavaScript libraries are deployed inside the SQL functions. In Snowflake, the functions can be used with tables of any database in the same account.

**Tools**

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `node`: https://www.npmjs.com/ (v14.18)
- `yarn`: https://yarnpkg.com/ (v1.22)
- `snowsql`: https://docs.snowflake.com/en/user-guide/snowsql.html (v1.2)

**Environment variables**

The `.env` file contains the variables required to deploy and run the toolbox.

```
# Snowflake
SF_ACCOUNT=your-snowflake-account
SF_DATABASE=your-snowflake-database
SF_SCHEMA_PREFIX=
SF_USER=your-snowflake-user
SF_PASSWORD=your-snowflake-password
SF_SHARE_PREFIX=
SF_SHARE_ENABLED=0
```

### Databricks

CARTO Analytics Toolbox for Databricks provides geospatial functionality leveraging the GeoMesa SparkSQL capabilities. It implements Spatial Hive UDFs. In order to install the toolbox the library (jar-with-dependencies) needs to be installed in the cluster you are using, and the Hive UDFs registered via createUDFs sql script

**Tools**

Make sure you have installed the following tools:

- `make`: https://www.gnu.org/software/make/
- `jdk (8 or 11)`: https://www.oracle.com/java/technologies/javase/javase8u211-later-archive-downloads.html (v8.x)
- `sbt`: https://www.scala-sbt.org/1.x/docs/Setup.html (v1.x)
- `Python3.6 and above`: https://www.python.org/downloads/release/python-3811 (v3.8.11)
- `databricks cli`: https://docs.databricks.com/dev-tools/cli/index.html
- `jq`: https://stedolan.github.io/jq/ (v1.6)

In order to set up authentication you can use a databricks token and the databricks host URL
``
databricks configure --token
``

**Environment variables**
The `.env` file contains the variables required to deploy and run the toolbox. Only the cluster id is mandatory. Default schema is 'default'

```
# Databricks
DB_CLUSTER_ID=my-cluster-id
DB_SCHEMA=
DB_DATASET_PREFIX=
```

## Contribute

This project is public. We are more than happy of receiving feedback and contributions. Feel free to open a ticket with a bug, a doubt or a discussion, or open a pull request with a fix or a new feature.
