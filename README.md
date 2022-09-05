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
| Postgres | https://docs.carto.com/analytics-toolbox-postgres |
| Databricks | https://docs.carto.com/analytics-toolbox-databricks |

## Development

| Cloud | Development |
|---|---|
| BigQuery | |
| Snowflake | [README.md](./clouds/snowflake/README.md) |
| Redshift | [README.md](./clouds/redshift/README.md) |
| Postgres | [README.md](./clouds/postgres/README.md) |
| Databricks | [README.md](./clouds/databricks/README.md) |

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

## Contribute

This project is public. We are more than happy of receiving feedback and contributions. Feel free to open a ticket with a bug, a doubt or a discussion, or open a pull request with a fix or a new feature.
