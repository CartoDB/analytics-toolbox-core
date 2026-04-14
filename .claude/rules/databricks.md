---
paths:
  - "clouds/databricks/**"
---

# Databricks

## Configuration

Create a `.env` file in `clouds/databricks/` (template: `clouds/databricks/.env.template`):

```bash
DB_PREFIX=yourname_            # Schema prefix (e.g., "yourname_" -> "yourname_carto")
DB_CATALOG=<catalog>           # Databricks catalog name
DB_HOST_NAME=<hostname>        # SQL Warehouse hostname
DB_HTTP_PATH=<path>            # SQL Warehouse HTTP path
DB_TOKEN=<token>               # Access token
DB_CONNECTION=<connection>     # Databricks connection string
DB_API_BASE_URL=<url>          # CARTO API base URL
DB_API_ACCESS_TOKEN=<token>    # CARTO API access token
```

## Commands

```bash
cd clouds/databricks
make deploy                    # Deploy SQL UDFs
make test                      # Run all tests (pytest)
make test modules=quadbin      # Run tests for specific module
make build-modules             # Build module packages
```

## Key Details

- Native SQL UDFs only (no gateway/Lambda)
- `quadbin` module migrated March 2026 (20 SQL functions)
- Deploy scripts in `clouds/databricks/common/`: `run_query.py`, `create_schema.py`
- Schema creation runs automatically during deploy
