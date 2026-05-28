---
paths:
  - "**/function.yaml"
  - "**/functions/**"
---

# Function Development

## Gateway Functions (Lambda-based)

### Directory Structure

```
gateway/functions/<module>/<function_name>/
├── function.yaml              # Function metadata
├── code/
│   ├── lambda/python/
│   │   ├── handler.py         # Lambda handler
│   │   └── requirements.txt   # Python dependencies
│   └── redshift.sql           # External function SQL template
└── tests/
    ├── unit/
    │   ├── cases.yaml         # Simple test cases
    │   └── test_*.py          # Complex test scenarios
    └── integration/
        └── test_*.py          # Integration tests
```

## function.yaml Complete Reference

```yaml
# Optional: name and module are inferred from directory structure
# Only include if function name differs from folder name
name: function_name
module: module_name

# Generic type definitions (hybrid functions)
parameters:
  - name: input_data
    type: string                    # Generic type (maps to VARCHAR(MAX))
  - name: size
    type: int                       # Generic type (maps to INT)
returns: string                     # Return type

clouds:
  redshift:
    type: lambda                    # Platform type
    lambda_name: shortname          # <=18 chars (with prefix)
    code_file: code/lambda/python/handler.py
    requirements_file: code/lambda/python/requirements.txt  # Optional
    external_function_template: code/redshift.sql  # Optional (auto-generated if omitted)
    shared_libs:                    # Optional - list of _shared/python/ modules
      - statistics
      - tiler
    # Cloud-specific parameter type overrides (optional)
    parameters:
      - name: data
        type: SUPER                 # Redshift-specific type
    returns: SUPER
    config:
      memory_size: 512              # MB (128-10240, default 512)
      timeout: 300                  # Seconds (3-900, default 300)
      max_batch_rows: 100           # Batch size (default 100)
      runtime: python3.10           # Python runtime
```

### Function Naming Convention

**Function name and module are automatically inferred from directory structure:**

```
functions/
  <module>/
    <function_name>/
      function.yaml
```

- **Function name**: From directory name (e.g., `s2_fromtoken`)
- **Module**: From parent directory name (e.g., `s2`)
- **SQL function name**: Uppercase version (e.g., `S2_FROMTOKEN`)

**Important**: Do NOT include `name` or `module` fields in `function.yaml` unless the function name needs to differ from the folder name.

## Hybrid Function Definitions (Auto-Generated SQL)

For simple functions, you can eliminate the SQL template file entirely. The system auto-generates SQL from function metadata.

### Key Features

- **Convention over configuration**: Function name and module inferred from directory structure
- **Generic type mapping**: Define parameters once with generic types (`string`, `int`, `bigint`, etc.)
- **Cloud-specific overrides**: Override types for specific clouds when needed (e.g., Redshift's `SUPER`)
- **Automatic SQL generation**: SQL templates generated automatically from metadata
- **Backward compatible**: Existing functions with SQL templates continue to work

### Pattern 1: Simple Function with Generic Types

For straightforward functions, define parameters and return type at the top level. **No SQL file needed!**

```yaml
# No 'name' or 'module' fields - inferred from directory structure
# Function: functions/s2/s2_fromtoken/

parameters:
  - name: token
    type: string      # Maps to VARCHAR(MAX) in Redshift
returns: bigint       # Maps to INT8 in Redshift

clouds:
  redshift:
    type: lambda
    lambda_name: s2_ftok
    code_file: code/lambda/python/handler.py
    # NO external_function_template needed!
    config:
      max_batch_rows: 10000
```

**Generated SQL (Redshift):**

```sql
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.S2_FROMTOKEN(
    token VARCHAR(MAX)
)
RETURNS INT8
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS 10000;
```

### Pattern 2: Cloud-Specific Type Overrides

For functions that need cloud-specific types (e.g., Redshift's `SUPER`), define types under the cloud section:

```yaml
# Function: functions/statistics/getis_ord_quadbin/

clouds:
  redshift:
    type: lambda
    lambda_name: getisord
    code_file: code/lambda/python/handler.py
    shared_libs:
      - statistics
    # Cloud-specific parameter types
    parameters:
      - name: data
        type: SUPER        # Redshift-specific type
      - name: k_neighbors
        type: INT
    returns: SUPER
    config:
      memory_size: 1024
      max_batch_rows: 50
```

### Pattern 3: Hybrid (Generic + Cloud-Specific Overrides)

Define generic types at top level for most clouds, then override specific clouds:

```yaml
# Generic types for most clouds
parameters:
  - name: input_data
    type: object      # Maps to SUPER, JSON, VARIANT, etc.
  - name: value
    type: float
returns: object

clouds:
  redshift:
    type: lambda
    lambda_name: ex_hybrid
    code_file: code/lambda/python/handler.py
    # Override for Redshift (use SUPER instead of generic object)
    parameters:
      - name: input_data
        type: SUPER
      - name: value
        type: float
    returns: SUPER

  bigquery:
    type: cloud_run
    # Uses generic types (object -> JSON, float -> FLOAT64)
    code_file: code/cloud_run/main.py
```

### Pattern 4: Legacy (SQL Template)

Existing functions with SQL templates continue to work unchanged:

```yaml
name: example_legacy
module: example

clouds:
  redshift:
    type: lambda
    lambda_name: ex_legacy
    code_file: code/lambda/python/handler.py
    external_function_template: code/redshift.sql  # Uses existing template
```

## Generic Type Mapping

| Generic Type | Redshift | BigQuery | Snowflake | Databricks | Postgres |
|-------------|----------|----------|-----------|------------|----------|
| `string` | `VARCHAR(MAX)` | `STRING` | `VARCHAR` | `STRING` | `TEXT` |
| `int` | `INT` | `INT64` | `INT` | `INT` | `INTEGER` |
| `bigint` | `INT8` | `INT64` | `BIGINT` | `BIGINT` | `BIGINT` |
| `float` | `FLOAT4` | `FLOAT64` | `FLOAT` | `FLOAT` | `REAL` |
| `double` | `FLOAT8` | `FLOAT64` | `DOUBLE` | `DOUBLE` | `DOUBLE PRECISION` |
| `boolean` | `BOOLEAN` | `BOOL` | `BOOLEAN` | `BOOLEAN` | `BOOLEAN` |
| `bytes` | `VARBYTE` | `BYTES` | `BINARY` | `BINARY` | `BYTEA` |
| `object` | `SUPER` | `JSON` | `VARIANT` | `STRING` | `JSONB` |
| `geometry` | `GEOMETRY` | `GEOGRAPHY` | `GEOMETRY` | `STRING` | `GEOMETRY` |
| `geography` | `GEOGRAPHY` | `GEOGRAPHY` | `GEOGRAPHY` | `STRING` | `GEOGRAPHY` |

You can also use cloud-specific types directly (e.g., `VARCHAR(MAX)`, `SUPER`), which are passed through unchanged.

## Validation Rules

The system validates function configurations at load time:

- **Error**: Function has neither SQL template nor parameters/returns metadata
- **Warning**: Function has both SQL template and metadata (template takes precedence)
- **OK**: Function has either SQL template or complete metadata (parameters + returns)

## Lambda Naming Constraints

**Critical**: Redshift external functions have an undocumented limit of ~18 characters for Lambda function names.

- Keep total name under 18 chars: `len(RS_LAMBDA_PREFIX) + len(function_name) < 18`
- Use `lambda_name` field in function.yaml for short names
- Examples:
  - OK: `v-quadbin_polyfill` = 17 chars (safe)
  - FAIL: `myname-quadbin_polyfill` = 22 chars (will fail)

For CI/CD prefixes (e.g., `ci_12345678_123456_`), function names should be <=18 chars to stay within the 64-character total AWS Lambda name limit.

## Shared Libraries

Place reusable code in `gateway/functions/_shared/python/<lib_name>/` and reference via `shared_libs` in function.yaml. The build system copies these to `lib/<lib_name>/` in the Lambda package.

**Critical Rule**: Only create shared libraries when code is used by **multiple functions** (2+). Single-function code should live in the function's own `code/lambda/python/lib/` directory.

## Cloud Functions (Native SQL)

SQL UDFs go in `clouds/{cloud}/modules/sql/<module>/` and follow cloud-specific patterns. See cloud-specific READMEs:
- `clouds/redshift/README.md`
- `clouds/bigquery/README.md`
- etc.

## Multi-Cloud Functions

Functions can support multiple clouds in a single `function.yaml`:

```yaml
clouds:
  redshift:
    type: lambda
    lambda_name: ex_multi
    code_file: code/lambda/python/handler.py
  snowflake:
    type: lambda
    code_file: code/snowflake/handler.py
```

## Function Documentation

Documentation lives in `clouds/{cloud}/modules/doc/<module>/`:

- `_INTRO.md` — Module introduction
- `FUNCTION_NAME.md` — Individual function docs

Follows markdown format with special metadata headers. See `CONTRIBUTING.md` for details.

## Future Development Guidelines

### When adding new functions

1. Determine if code should be shared or function-specific
2. Use shared library only if used by 2+ functions
3. Keep lambda_name <=18 characters
4. Add comprehensive unit tests
5. Document function in module README
6. Use generic types in function.yaml when possible
7. Follow existing handler patterns
8. Build and test before committing
