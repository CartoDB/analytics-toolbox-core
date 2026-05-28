---
paths:
  - "clouds/**/test/**"
---

# Cloud SQL Testing

## Test Frameworks by Cloud

- **pytest**: Oracle, Redshift, Databricks, Postgres — test files named `test_FUNCTION_NAME.py`
- **Jest**: BigQuery, Snowflake — test files named `FUNCTION_NAME.test.js`

## Test File Location

`clouds/{cloud}/modules/test/{module}/test_FUNCTION.py` (or `.test.js`)

## Running Tests

```bash
cd clouds/{cloud}
make test                        # all tests
make test modules=h3             # specific module
make test functions=H3_POLYFILL  # specific function
```

## Test Utilities

Each cloud has its own test utilities for database connectivity:

- **Python**: `clouds/{cloud}/common/test_utils/__init__.py` — provides `run_query()`, `run_queries()`, `get_cursor()`
- **JavaScript**: `clouds/{cloud}/common/test-utils.js` — provides `runQuery()`, `loadTable()`, `deleteTable()`, `readJSONFixture()`

## Schema Placeholders

Tests use `@@SCHEMA@@` placeholders replaced at runtime:

- `@@RS_SCHEMA@@` (Redshift)
- `@@ORA_SCHEMA@@` (Oracle)
- `@@BQ_DATASET@@` (BigQuery)
- `@@BQ_PREFIX@@` (BigQuery)

## Fixtures

Located in `test/{module}/fixtures/`:

- `.txt` files (Oracle, Redshift) — line-by-line expected output
- `.json` / `.ndjson` / `.csv` files (BigQuery) — structured test data

## Testing Best Practices

- Test values should match canonical outputs from the reference cloud (Databricks for Quadbin, BigQuery for H3)
- Geometry tolerance: 1e-6 for floating-point coordinate comparison
- JSON array results: sort before comparison
- NULL input should always return NULL
