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

### Hybrid Function Definitions (Auto-Generated SQL)

**For simple functions, you can now eliminate the SQL template file entirely!** The system can auto-generate SQL from function metadata.

#### Key Features

- **Convention over configuration**: Function name and module inferred from directory structure
- **Generic type mapping**: Define parameters once with generic types (`string`, `int`, `bigint`, etc.)
- **Cloud-specific overrides**: Override types for specific clouds when needed (e.g., Redshift's `SUPER`)
- **Automatic SQL generation**: SQL templates generated automatically from metadata
- **Backward compatible**: Existing functions with SQL templates continue to work

#### Function Naming Convention

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

#### Supported Generic Types

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

#### Usage Patterns

**Pattern 1: Simple Function with Generic Types**

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

**Pattern 2: Cloud-Specific Type Overrides**

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

**Pattern 3: Hybrid (Generic + Cloud-Specific Overrides)**

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
    # Uses generic types (object → JSON, float → FLOAT64)
    code_file: code/cloud_run/main.py
```

**Pattern 4: Legacy (SQL Template)**

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

#### Migration Guide

To convert an existing function from SQL template to YAML definition:

1. **Identify simple functions**: Functions with straightforward SQL templates (no wrappers, no complex logic)

2. **Extract parameter types**: Copy parameter names and types from SQL template

3. **Update function.yaml**:

   **Before (with SQL template):**
   ```yaml
   clouds:
     redshift:
       external_function_template: code/redshift.sql  # Delete this line
   ```

   **After (with metadata):**
   ```yaml
   parameters:
     - name: token
       type: string
   returns: bigint
   ```

4. **Test**: Deploy and verify auto-generated SQL matches original

5. **Delete SQL file** (optional): Once verified, remove old SQL template

#### When to Use Each Pattern

| Pattern | Use When |
|---------|----------|
| **Simple (Generic Types)** | Function has standard types (string, int) and works same across clouds |
| **Cloud-Specific Overrides** | Function needs proprietary types (SUPER, VARIANT) or cloud-specific syntax |
| **Hybrid** | Most clouds use generic types, but one cloud needs special handling |
| **Legacy (SQL Template)** | Function has complex SQL (wrappers, multiple statements, conditional logic) |

#### Best Practices

1. **Start with generic types**: Use generic types by default for maximum portability
2. **Override only when needed**: Only add cloud-specific overrides when absolutely necessary
3. **Use descriptive parameter names**: Parameter names appear in both SQL and documentation
4. **Add descriptions**: Include parameter descriptions for better documentation
   ```yaml
   parameters:
     - name: resolution
       type: int
       description: Quadbin resolution level (0-26)
   ```

#### Validation

The system validates function configurations at load time:

- **Error**: Function has neither SQL template nor parameters/returns metadata
- **Warning**: Function has both SQL template and metadata (template takes precedence)
- **OK**: Function has either SQL template or complete metadata (parameters + returns)

#### Implementation Architecture

The architecture follows a **Registry Pattern** for cloud-agnostic type mapping:

**Components:**
- **TypeMapperRegistry** (`logic/common/engine/type_mapper.py`): Cloud-agnostic registry (NO cloud-specific logic)
- **RedshiftTypeMappings** (`logic/clouds/redshift/type_mappings.py`): Redshift-specific mappings (auto-registers on import)
- **SQLTemplateGenerator** (`logic/clouds/redshift/sql_template_generator.py`): Generates SQL from metadata
- **CatalogLoader** (`logic/common/engine/catalog_loader.py`): Parses function.yaml and validates

**Resolution Order:**
1. Check if `external_function_template` exists → use SQL file
2. Check if function has `parameters` and `returns` → auto-generate
3. Error if neither available

**Cloud Override Resolution:**
1. Check if cloud has `parameters` or `returns` defined → use cloud-specific
2. Otherwise, use top-level (generic) definitions
3. Map types using TypeMapper

#### Adding Support for New Clouds

To add a new cloud:

1. **Create type mappings file** (`logic/clouds/{cloud}/type_mappings.py`):

```python
from ...common.engine.type_mapper import TypeMapperRegistry

class BigQueryTypeMappings:
    """BigQuery-specific type mapping provider"""

    TYPE_MAPPINGS = {
        "string": "STRING",
        "int": "INT64",
        "bigint": "INT64",
        "object": "JSON",
        # ... add all mappings
    }

    def map_type(self, generic_type: str) -> str:
        generic_lower = generic_type.lower()
        if generic_lower in self.TYPE_MAPPINGS:
            return self.TYPE_MAPPINGS[generic_lower]
        return generic_type

    def is_generic_type(self, type_str: str) -> bool:
        return type_str.lower() in self.TYPE_MAPPINGS

    def get_supported_generic_types(self) -> list[str]:
        return list(self.TYPE_MAPPINGS.keys())

# Auto-register
TypeMapperRegistry.register("bigquery", BigQueryTypeMappings())
```

2. **Create SQL template generator** (if auto-generation desired)
3. **Write tests** (`logic/clouds/{cloud}/tests/unit/test_type_mappings.py`)

That's it! The common engine automatically uses your cloud's mapper.

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

---

## Gateway Architecture Deep Dive

### Cloud and Platform Agnosticism

The gateway deployment engine in `gateway/logic/` is designed to be cloud and platform agnostic:

**Architecture Layers:**

1. **Common Engine** (`gateway/logic/common/engine/`):
   - `catalog_loader.py`: Discovers and loads function definitions
   - `models.py`: Cloud-agnostic data models (CloudType, PlatformType, CloudConfig)
   - `type_mapper.py`: Generic type mapping system with cloud-specific registrations
   - `validators.py`: Function configuration validation
   - `packagers.py`: Package creation for distribution

2. **Platform Layer** (`gateway/logic/platforms/`):
   - `aws-lambda/`: AWS Lambda-specific deployment logic
   - Extensible for other platforms (GCP Cloud Run, Snowflake Snowpark, etc.)

3. **Cloud Layer** (`gateway/logic/clouds/`):
   - `redshift/`: Redshift-specific SQL generation and deployment
   - `sql_template_generator.py`: Auto-generates SQL from function metadata
   - Extensible for other clouds (BigQuery, Snowflake, Databricks)

**Key Design Principles:**

- Functions are defined once in `function.yaml` with cloud-agnostic parameters
- Type mapping system converts generic types to cloud-specific types
- SQL templates use `@@VARIABLE@@` placeholders for cloud-specific values
- Platform deployers handle platform-specific deployment details

### Shared vs Function-Specific Libraries

**Critical Rule**: Only create shared libraries when code is used by **multiple functions**.

**Shared Libraries** (`gateway/functions/_shared/python/`):

- **Purpose**: Code used by multiple functions
- **Location**: `_shared/python/<module_name>/`
- **Reference**: Listed in function.yaml `shared_libs` field
- **Build**: Copied to each function's `lib/<module_name>/` during `make build`
- **Import**: `from lib.<module_name> import ...`

**Function-Specific Libraries** (`<function>/code/lambda/python/lib/`):

- **Purpose**: Code used by **only one function**
- **Location**: `code/lambda/python/lib/` within function directory
- **Reference**: Not in function.yaml (automatically included)
- **Build**: Included directly in function package
- **Import**: `from lib.<module> import ...`

**Why This Matters:**
- Provides **isolation** and **independent versioning** per function
- Prevents coupling between unrelated functions
- Allows different functions to evolve independently

### Build System Details

**What happens during `make build cloud=redshift`:**

1. **Discovery Phase**:
   ```python
   # Scans for function.yaml files in:
   gateway/functions/**/function.yaml
   ```

2. **Validation Phase**:
   ```python
   # Validates each function.yaml:
   - Required fields present
   - Lambda name ≤18 chars
   - Shared libs exist
   - Code files exist
   ```

3. **Copy Phase**:
   ```python
   # For each function with shared_libs:
   for lib in function.shared_libs:
       copy _shared/python/{lib}/ to {function}/code/lambda/python/lib/{lib}/
   ```

4. **Package Phase**:
   ```python
   # Creates deployment package for each function:
   - Copy function code
   - Install requirements.txt dependencies
   - Include shared libraries
   - Create .zip for Lambda deployment
   ```

**Why build is required before tests:**
- Tests import from `lib.*` which doesn't exist until build copies shared libraries
- Each test runs against the actual Lambda deployment structure
- Ensures tests match production behavior

### Function Configuration Deep Dive

**function.yaml Complete Reference:**

```yaml
name: function_name
module: module_name

# Generic type definitions (hybrid functions - NEW)
parameters:
  - name: input_data
    type: string                    # Generic type (maps to VARCHAR(MAX))
  - name: size
    type: int                       # Generic type (maps to INT)
returns: string                     # Return type

clouds:
  redshift:
    type: lambda                    # Platform type
    lambda_name: shortname          # ≤18 chars (with prefix)
    code_file: code/lambda/python/handler.py
    requirements_file: code/lambda/python/requirements.txt  # Optional
    external_function_template: code/redshift.sql  # Optional (auto-generated if omitted)
    shared_libs:                    # Optional - list of _shared/python/ modules
      - quadbin
      - utils
    config:
      memory_size: 512              # MB (128-10240, default 512)
      timeout: 300                  # Seconds (3-900, default 300)
      max_batch_rows: 100           # Batch size (default 100)
      runtime: python3.10           # Python runtime
```

**Generic Type Mapping** (auto-converts to cloud-specific):

| Generic Type | Redshift | BigQuery | Snowflake |
|--------------|----------|----------|-----------|
| `string` | `VARCHAR(MAX)` | `STRING` | `VARCHAR` |
| `int` | `INT` | `INT64` | `INTEGER` |
| `bigint` | `INT8` | `INT64` | `BIGINT` |
| `float` | `FLOAT8` | `FLOAT64` | `FLOAT` |
| `boolean` | `BOOLEAN` | `BOOL` | `BOOLEAN` |

### Deployment Flow

**Complete Deployment Process:**

```
1. Load Function Catalog (gateway/logic/common/engine/catalog_loader.py)
   ├─> Scan gateway/functions/
   └─> Parse all function.yaml files

2. Validate Functions (gateway/logic/common/engine/validators.py)
   ├─> Check required fields
   ├─> Validate lambda_name length
   ├─> Verify shared_libs exist
   └─> Validate code files exist

3. Package Functions (gateway/logic/common/engine/packagers.py)
   ├─> Copy function code
   ├─> Copy shared libraries (if specified)
   ├─> Install requirements (if specified)
   └─> Create deployment package (.zip)

4. Deploy to Lambda (gateway/logic/platforms/aws-lambda/)
   ├─> Upload Lambda package to AWS
   ├─> Set memory, timeout, runtime config
   ├─> Configure IAM role
   └─> Get Lambda ARN

5. Create External Functions (gateway/logic/clouds/redshift/)
   ├─> Generate SQL from template or auto-generate
   ├─> Replace @@VARIABLES@@ with actual values
   ├─> Execute SQL on Redshift
   └─> Link external function to Lambda ARN

6. Verify Deployment
   ├─> Test Lambda invocation
   └─> Test external function call
```

### Key Architectural Decisions

**1. Dual Architecture (Gateway + Clouds)**
- **Why**: Flexibility to use native SQL UDFs where possible, Lambda for complex Python logic
- **When to use Gateway**: Complex algorithms, external API calls, Python libraries
- **When to use Clouds**: Simple SQL operations, native cloud optimizations

**2. Build-Time Dependency Copying**
- **Why**: Lambda deployment packages must be self-contained
- **Alternative rejected**: Layers (limited to 5 per function, size limits)
- **Benefit**: Each function is independent and deployable

**3. Short Lambda Names**
- **Why**: AWS Lambda name limit (64 chars) with CI/CD prefixes
- **Pattern**: `{prefix}_{shortname}` (e.g., `ci_a1b2c3d4_123456_getisord`)
- **Benefit**: Supports long CI/CD prefixes

**4. Function-Specific vs Shared Libraries**
- **Why**: Balance between code reuse and isolation
- **Shared**: Used by multiple functions
- **Function-specific**: Used by one function
- **Benefit**: Prevents unnecessary coupling

**5. Generic Type System**
- **Why**: Write function definitions once, deploy to multiple clouds
- **How**: Generic types mapped to cloud-specific types at deployment
- **Benefit**: Cloud-agnostic function definitions

**6. Auto-Generated SQL Templates**
- **Why**: Reduce boilerplate for simple functions
- **How**: Use `parameters` and `returns` in function.yaml
- **Fallback**: Manual SQL template for complex cases
- **Benefit**: Faster development, fewer errors

### Testing Best Practices

**Unit Test Structure:**

```python
# gateway/functions/module/function/tests/unit/test_function.py

import pytest
from unittest.mock import Mock, patch

# Import from built structure
from lib.quadbin import to_geojson


def test_process_row_valid_input(handler_module):
    """Test handler with valid input."""
    row = ["quadbin_string", 5]
    result = handler_module.process_row(row)
    assert result is not None


def test_process_row_invalid_input(handler_module):
    """Test handler with invalid input."""
    row = []
    result = handler_module.process_row(row)
    assert result is None


@pytest.fixture
def handler_module():
    """Load handler module."""
    import sys
    sys.path.insert(0, "code/lambda/python")
    import handler
    return handler
```

### Troubleshooting Guide

**Common Issues:**

1. **Import Error: `ModuleNotFoundError: No module named 'lib'`**
   - **Cause**: Build not run before tests
   - **Fix**: `make build cloud=redshift`

2. **Lambda Deploy Fails: `ResourceName too long`**
   - **Cause**: lambda_name + prefix > 64 chars
   - **Fix**: Shorten lambda_name in function.yaml to ≤18 chars

3. **Test Import Error: `No module named 'lib.quadbin'`**
   - **Cause**: shared_libs not specified in function.yaml
   - **Fix**: Add `shared_libs: [quadbin]` to function.yaml, rebuild

4. **Function Not Found During Deploy**
   - **Cause**: function.yaml missing or invalid
   - **Fix**: Validate function.yaml structure, check required fields

5. **External Function Error: `Permission denied for Lambda`**
   - **Cause**: RS_LAMBDA_INVOKE_ROLE not set or incorrect
   - **Fix**: Verify IAM role ARN in .env file

6. **Build Copies Wrong Library Version**
   - **Cause**: Old build artifacts
   - **Fix**: `make clean && make build cloud=redshift`

### Future Development Guidelines

**When adding new functions:**

1. Determine if code should be shared or function-specific
2. Use shared library only if used by 2+ functions
3. Keep lambda_name ≤18 characters
4. Add comprehensive unit tests
5. Use generic types in function.yaml when possible
6. Follow existing handler patterns
7. Build and test before committing

**When modifying shared libraries:**

1. Consider impact on all dependent functions
2. Run tests for all dependent functions
3. Avoid breaking changes
4. Update shared library documentation
5. Rebuild all dependent functions

**When refactoring:**

1. Maintain backward compatibility
2. Keep function signatures unchanged
3. Update tests to match changes
4. Verify deployment after refactoring
5. Document architectural decisions
