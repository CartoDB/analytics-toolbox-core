# CARTO Analytics Toolbox Core

The *CARTO Analytics Toolbox* is a set of UDFs and Stored Procedures to unlock Spatial Analytics. It is organized into modules based on the functionality they offer. This toolbox is cloud-native, which means it is available for different data warehouses: BigQuery, Snowflake, Redshift, Postgres, and Databricks. It is built on top of the data warehouse's GIS features, extending and complementing this functionality.

| BigQuery | Snowflake | Redshift | Postgres | Databricks |
|:--------:|:---------:|:--------:|:--------:|:----------:|
|<img src="./clouds/bigquery/common/analytics-toolbox-bigquery.png" width=80 height=80>|<img src="./clouds/snowflake/common/analytics-toolbox-snowflake.png" width=80 height=80>|<img src="./clouds/redshift/common/analytics-toolbox-redshift.png" width=80 height=80>|<img src="./clouds/postgres/common/analytics-toolbox-postgres.png" width=80 height=80>|<img src="./clouds/databricks/common/analytics-toolbox-databricks.png" width=80 height=80>|

This repo contains the core open-source modules of the toolbox. CARTO offers proprietary modules that extend this core functionality.

## Repository Structure

The Analytics Toolbox has two parallel components:

1. **Gateway** (`gateway/`): Lambda-based Python functions deployed to AWS Lambda
   - All deployment logic in `gateway/logic/`
   - Open-source functions in `gateway/functions/`

2. **Clouds** (`clouds/{cloud}/`): Native SQL UDFs specific to each cloud platform
   - BigQuery, Snowflake, Redshift, Postgres, Databricks

## Getting Started

### Using Functions (End Users)

Using the functions depends on the cloud you're using. In BigQuery and Snowflake you can access them directly as shared resources without installation.

#### BigQuery

You can use the functions directly as they're globally shared in the US region:

```sql
SELECT `carto-os.carto.H3_CENTER`('84390cbffffffff')
```

For the Europe region:

```sql
SELECT `carto-os-eu.carto.H3_CENTER`('84390cbffffffff')
```

If you need to install them in your own VPC or a different region, see the cloud-specific documentation below.

#### Snowflake

Install through the [Snowflake Marketplace](https://www.snowflake.com/datasets/carto-analytics-toolbox/):

```sql
SELECT carto_os.carto.H3_FROMGEOGPOINT(ST_POINT(-3.7038, 40.4168), 4)
```

#### Redshift

For Redshift, you need to install the toolbox directly on your cluster. See the deployment section below.

## Documentation

| Cloud | Documentation |
|---|---|
| BigQuery | https://docs.carto.com/analytics-toolbox-bigquery |
| Snowflake | https://docs.carto.com/analytics-toolbox-snowflake |
| Redshift | https://docs.carto.com/analytics-toolbox-redshift |
| Postgres | https://docs.carto.com/analytics-toolbox-postgres |
| Databricks | https://docs.carto.com/analytics-toolbox-databricks |

## Development

### Gateway Functions (Lambda-based)

For developing and deploying Lambda-based Python functions:

**Documentation:**
- **[gateway/README.md](gateway/README.md)** - User-friendly guide for creating functions
- **[CLAUDE.md](CLAUDE.md)** - Complete technical documentation

**Quick Start:**

```bash
cd gateway

# Setup
make venv
cp .env.template .env
# Edit .env with your credentials

# Build and test
make build cloud=redshift
make test-unit cloud=redshift

# Deploy
make deploy cloud=redshift
```

**All deployment logic lives in `gateway/logic/`:**
- `logic/common/engine/` - Catalog, validators, packagers
- `logic/clouds/redshift/` - Redshift CLI and SQL generation
- `logic/platforms/aws-lambda/` - Lambda deployment

### Cloud Functions (Native SQL)

For cloud-specific native SQL UDFs, see the cloud-specific READMEs:

| Cloud | Development Guide |
|---|---|
| BigQuery | [README.md](./clouds/bigquery/README.md) |
| Snowflake | [README.md](./clouds/snowflake/README.md) |
| Redshift | [README.md](./clouds/redshift/README.md) |
| Postgres | [README.md](./clouds/postgres/README.md) |
| Databricks | [README.md](./clouds/databricks/README.md) |

### Useful Commands

**Gateway functions:**

```bash
cd gateway

# Build functions (required before testing)
make build cloud=redshift

# Run tests
make test-unit cloud=redshift
make test-integration cloud=redshift

# Deploy
make deploy cloud=redshift              # Dev environment
make deploy cloud=redshift production=1 # Production

# Lint
make lint
make lint-fix

# Create distribution package
make create-package cloud=redshift
```

**Cloud functions:**

Switch to a specific cloud directory (e.g., `cd clouds/snowflake`):

```bash
# All tests
make test

# Specific module(s)
make test modules=h3
make test modules=h3,transformations

# Specific function(s)
make test functions=H3_POLYFILL
make test functions=H3_POLYFILL,ST_BUFFER

# Deploy
make deploy
```

## Contribute

This project is open source. We're happy to receive feedback and contributions! Feel free to:
- Open a ticket with a bug report, question, or discussion
- Submit a pull request with a fix or new feature

For technical details and architecture, see [CLAUDE.md](CLAUDE.md).
