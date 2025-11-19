# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**CARTO Analytics Toolbox Core** is a multi-cloud spatial analytics platform providing UDFs and Stored Procedures for BigQuery, Snowflake, Redshift, Postgres, and Databricks. The repository is organized into:

1. **Gateway**: Lambda-based Python functions callable via SQL external functions (Redshift)
2. **Clouds**: Native SQL UDFs specific to each cloud platform

## Repository Structure

```
core/
├── gateway/                   # Lambda deployment engine + functions
│   ├── functions/             # Function definitions by module
│   │   ├── quadbin/
│   │   ├── s2/
│   │   ├── clustering/
│   │   └── _shared/python/    # Shared libraries
│   ├── logic/                 # Deployment engine
│   │   ├── common/engine/     # Catalog, validators, packagers
│   │   ├── clouds/redshift/   # Redshift CLI and deployers
│   │   └── platforms/aws-lambda/
│   └── tools/                 # Build and dependency tools
│
└── clouds/{cloud}/            # Native SQL UDFs for each cloud
    ├── modules/
    │   ├── sql/               # SQL function definitions
    │   ├── doc/               # Function documentation
    │   └── test/              # Integration tests
    ├── libraries/             # Cloud-specific libraries (Python/JS)
    └── version                # Version file (defines package version)
```

## Common Development Commands

### Initial Setup

```bash
# From gateway directory
cd gateway
make venv                      # Create virtual environment
```

### Configuration

Create a `.env` file in the repository root or `gateway/` directory (template: `gateway/.env.template`):

```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>

# Lambda Configuration (keep short: len(prefix + function_name) < 18)
RS_LAMBDA_PREFIX=yourname-     # 2-5 chars recommended

# Redshift Configuration
RS_PREFIX=yourname_            # Dev prefix for schemas
RS_HOST=<cluster>.redshift.amazonaws.com
RS_DATABASE=<database>
RS_USER=<user>
RS_PASSWORD=<password>
RS_LAMBDA_INVOKE_ROLE=arn:aws:iam::<account>:role/<role>
```

### Building and Testing Gateway Functions

**IMPORTANT**: Gateway functions require building before testing (copies shared libraries):

```bash
cd gateway

# Build functions (REQUIRED before tests)
make build cloud=redshift

# Run unit tests (build first!)
make test-unit cloud=redshift

# Run specific module tests
make test-unit cloud=redshift modules=quadbin

# Run specific function tests
make test-unit cloud=redshift functions=quadbin_polyfill

# Run integration tests (requires Redshift connection)
make test-integration cloud=redshift
```

### Testing Cloud SQL Functions

```bash
cd clouds/redshift

# Run all tests
make test

# Run specific module tests
make test modules=h3

# Run specific function tests
make test functions=H3_POLYFILL
```

### Linting

```bash
# Lint gateway
cd gateway
make lint

# Auto-fix formatting
make lint-fix

# Lint from root (both gateway + clouds)
cd ..
make lint cloud=redshift
```

### Deployment

**From root** (deploys both gateway Lambda functions + clouds SQL UDFs):

```bash
# Deploy to dev (with prefixes)
make deploy cloud=redshift

# Deploy specific modules
make deploy cloud=redshift modules=quadbin

# Deploy to production (no prefixes)
make deploy cloud=redshift production=1
```

**Gateway only** (Lambda functions):

```bash
cd gateway

# Deploy to dev
make deploy cloud=redshift

# Deploy specific functions
make deploy cloud=redshift functions=quadbin_polyfill

# Deploy only modified functions
make deploy cloud=redshift diff=1
```

**Clouds only** (native SQL UDFs):

```bash
cd clouds/redshift
make deploy
```

### Creating Distribution Packages

```bash
# From root: Create unified package (gateway + clouds)
make create-package cloud=redshift

# Production package
make create-package cloud=redshift production=1

# Specific modules
make create-package cloud=redshift modules=quadbin
```

## Gateway Function Development

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

### function.yaml Example (Legacy with SQL Template)

```yaml
name: quadbin_polyfill
module: quadbin
clouds:
  redshift:
    type: lambda
    lambda_name: qb_polyfill   # Short name (≤18 chars with prefix)
    code_file: code/lambda/python/handler.py
    requirements_file: code/lambda/python/requirements.txt
    external_function_template: code/redshift.sql
    shared_libs:
      - quadbin                # Copies _shared/python/quadbin to lib/
    config:
      memory_size: 512
      timeout: 300
      max_batch_rows: 50
      runtime: python3.10
```

### Hybrid Function Definitions (NEW)

**For simple functions, you can now eliminate the SQL template file entirely!**

Define function parameters and return type directly in function.yaml:

```yaml
name: s2_fromtoken
module: s2

# Generic type definitions (auto-mapped to cloud-specific types)
parameters:
  - name: token
    type: string      # Maps to VARCHAR(MAX) in Redshift, STRING in BigQuery, etc.
  - name: resolution
    type: int         # Maps to INT in Redshift, INT64 in BigQuery, etc.
returns: bigint       # Maps to INT8 in Redshift, INT64 in BigQuery, etc.

clouds:
  redshift:
    type: lambda
    lambda_name: s2_ftok
    code_file: code/lambda/python/handler.py
    # NO external_function_template needed - SQL auto-generated!
    config:
      max_batch_rows: 1000
```

For cloud-specific types, use overrides:

```yaml
name: complex_function
module: statistics

# Generic types for most parameters
parameters:
  - name: value
    type: float

clouds:
  redshift:
    type: lambda
    lambda_name: complex
    code_file: code/lambda/python/handler.py
    # Override with Redshift-specific types
    parameters:
      - name: data
        type: SUPER         # Redshift-specific type
      - name: value
        type: float         # Uses generic mapping
    returns: SUPER          # Redshift-specific type
```

**See `gateway/HYBRID_FUNCTION_DEFINITIONS.md` for complete documentation and examples.**

### Lambda Handler Pattern

```python
from carto.lambda_wrapper import redshift_handler

@redshift_handler
def process_row(row):
    """Process single row."""
    if not row or row[0] is None:
        return None

    # Your logic here
    return result
```

### SQL Template Pattern

Templates use `@@VARIABLE@@` syntax:

```sql
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADBIN_POLYFILL(
    geom VARCHAR(MAX),
    resolution INT
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
```

Available variables:
- `@@SCHEMA@@` - Schema name (e.g., `yourname_carto` or `carto`)
- `@@LAMBDA_ARN@@` - Lambda function ARN
- `@@IAM_ROLE_ARN@@` - IAM role for Lambda invocation

### Shared Libraries

Place reusable code in `gateway/functions/_shared/python/<lib_name>/` and reference via `shared_libs` in function.yaml. The build system copies these to `lib/<lib_name>/` in the Lambda package.

## Key Implementation Details

### Lambda Naming Constraints

**Critical**: Redshift external functions have an undocumented limit of ~18 characters for Lambda function names.

- Keep total name under 18 chars: `len(RS_LAMBDA_PREFIX) + len(function_name) < 18`
- Use `lambda_name` field in function.yaml for short names
- Examples:
  - ✓ `v-quadbin_polyfill` = 17 chars (safe)
  - ✗ `myname-quadbin_polyfill` = 22 chars (will fail)

### Build System

`make build` performs these steps:
1. Discovers functions from `gateway/functions/`
2. Installs function-specific dependencies from `requirements.txt`
3. Copies shared libraries from `_shared/python/` to each function's `lib/` directory
4. Creates build artifacts in `gateway/build/`

**ALWAYS build before testing gateway functions.**

### Deployment Process

1. **Lambda deployment**: Creates/updates AWS Lambda functions
2. **External function deployment**: Creates SQL external functions in Redshift
3. **SQL UDF deployment**: Runs native SQL scripts for cloud-specific UDFs

### Template Variables

SQL templates use `@@VARIABLE@@` placeholders replaced during deployment.

### Dev vs Production Modes

- **Dev mode** (default): Adds prefixes
  - Schema: `{RS_PREFIX}carto` (e.g., `yourname_carto`)
  - Lambda: `{RS_LAMBDA_PREFIX}function_name` (e.g., `yourname-qb_polyfill`)
- **Production mode** (`production=1`): No prefixes
  - Schema: `carto`
  - Lambda: `{RS_LAMBDA_PREFIX}function_name` (prefix still applied)

## Cloud SQL Function Development

### Structure (Redshift Example)

```
clouds/redshift/
├── modules/
│   ├── sql/<module>/          # SQL function definitions
│   ├── doc/<module>/          # Markdown documentation
│   └── test/<module>/         # pytest integration tests
├── libraries/python/          # Python UDFs
└── version                    # Version file
```

### Common Commands

```bash
cd clouds/redshift

# Run tests
make test
make test modules=h3
make test functions=H3_POLYFILL

# Deploy
make deploy
make deploy modules=h3

# Lint
make lint

# Build modules
make build-modules
make build-modules modules=h3
```

### SQL Function Naming Conventions

For Redshift/Snowflake/Postgres:

```sql
-- Definition (parentheses on separate line)
CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.H3_POLYFILL
(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR
...

-- Invocation (no space before parentheses)
SELECT @@RS_SCHEMA@@.H3_POLYFILL(geom, 5)
```

## Testing

### Unit Tests (Gateway)

- Import from built structure: `from lib.quadbin import ...`
- Test the handler decorator: `@redshift_handler`
- Mock external dependencies
- Use `conftest.py` fixtures

### Integration Tests

- Connect to real Redshift cluster
- Require proper `.env` configuration
- Test deployed functions end-to-end

## Multi-Cloud Support

Functions can support multiple clouds in function.yaml:

```yaml
clouds:
  redshift:
    type: lambda
    # ... redshift config
  snowflake:
    type: lambda
    # ... snowflake config
```

## Version Management

Versions defined in `clouds/{cloud}/version` files. Used during `make create-package`.

## Documentation

Function documentation in `clouds/{cloud}/modules/doc/<module>/`:
- `_INTRO.md` - Module introduction
- `FUNCTION_NAME.md` - Individual function docs

Follows markdown format with special metadata headers. See CONTRIBUTING.md for details.

## Pull Request Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(rs|quadbin): add quadbin_polyfill function
fix(sf|h3): fix h3_polyfill boundary handling
```

Scope format: `(<cloud(s)>|<module(s)>)`

Cloud codes: `bq` (BigQuery), `sf` (Snowflake), `rs` (Redshift), `pg` (Postgres), `db` (Databricks)

## Important Notes

- **Always build before testing gateway**: `make build cloud=redshift` before `make test-unit`
- **Shared libraries are copied during build**: Changes to `_shared/` require rebuilding
- **Lambda names must be short**: Use `lambda_name` field to keep under 18 chars total
- **Two parallel systems**: Gateway (Lambda) and Clouds (native SQL) are deployed independently but packaged together
