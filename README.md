# CARTO Analytics Toolbox Core

The *CARTO Analytics Toolbox* is a set of UDFs and Stored Procedures to unlock Spatial Analytics. It is organized into modules based on the functionality they offer. This toolbox is cloud-native, which means it is available for different data warehouses: BigQuery, Snowflake, Redshift, Postgres, and Databricks. It is built on top of the data warehouse's GIS features, extending and complementing this functionality.

| BigQuery | Snowflake | Redshift | Postgres | Databricks |
|:--------:|:---------:|:--------:|:--------:|:----------:|
|<img src="./clouds/bigquery/common/analytics-toolbox-bigquery.png" width=80 height=80>|<img src="./clouds/snowflake/common/analytics-toolbox-snowflake.png" width=80 height=80>|<img src="./clouds/redshift/common/analytics-toolbox-redshift.png" width=80 height=80>|<img src="./clouds/postgres/common/analytics-toolbox-postgres.png" width=80 height=80>|<img src="./clouds/databricks/common/analytics-toolbox-databricks.png" width=80 height=80>|

This repo contains the core open-source modules of the toolbox. CARTO offers a set of premium modules that are available for CARTO users.

## Getting started

Using the functions on this project depends on the Datawarehouse you are using. In BigQuery and Snowflake you can access them directly as a shared resources without having to install them, for the rest you will have to install them locally on your database.

### BigQuery

You can use directly the functions as they are globally shared in the US region.

```sql
SELECT `carto-os.carto.H3_CENTER`('84390cbffffffff')
```

If you need to use them from the Europe region use:

```sql
SELECT `carto-os-eu.carto.H3_CENTER`('84390cbffffffff')
```

If you need to install them on your own VPC or in a different region, follow the instructions later on.

### Snowflake

The easiest way to start using these functions is to add them to your Datawarehouse through the [Snowflake Marketplace](https://www.snowflake.com/datasets/carto-analytics-toolbox/). Go there and install it using theregular methods. After that you should be able to use them on the location you have installed them. For example try:

```sql
SELECT carto_os.carto.H3_FROMGEOGPOINT(ST_POINT(-3.7038, 40.4168), 4)
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
| BigQuery | [README.md](./clouds/bigquery/README.md) |
| Snowflake | [README.md](./clouds/snowflake/README.md) |
| Redshift | [README.md](./clouds/redshift/README.md) |
| Postgres | [README.md](./clouds/postgres/README.md) |
| Databricks | [README.md](./clouds/databricks/README.md) |

### Useful make commands

To run tests, switch to a specific cloud directory. For example, Showflake: `cd clouds/snowflake`.  

```
# All tests
make test

# Specific module(s)
make test modules=h3
make test modules=h3,transformations

# Specific function(s)
make test functions=H3_POLYFILL
make test functions=H3_POLYFILL,ST_BUFFER
```

### Rebuild h3-js 3.7.2 dependency
First, ensure you have yarn and docker installed.  

```
wget https://github.com/uber/h3-js/releases/tag/v3.7.2
unzip h3-js-3.7.2.zip
cd h3-js-3.7.2
yarn docker-boot && yarn build-emscripten
```

Remove all the unneeded bindings from the `lib/bindings.js`  

Then run:  
```
yarn docker-emscripten-run
```

Your new library file is available at `out/a.out.js`. Copy it to the correct location with the new filename. For example: `cp out/a.out.js  ~/development/analytics-toolbox/core/clouds/snowflake/libraries/javascript/src/h3/h3_polyfill/libh3_custom.js`. Ensure it is named `libh3_custom.js`.


## Contribute

This project is public. We are more than happy of receiving feedback and contributions. Feel free to open a ticket with a bug, a doubt or a discussion, or open a pull request with a fix or a new feature.
