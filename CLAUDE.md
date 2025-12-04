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

# Lambda Configuration
RS_LAMBDA_PREFIX=yourname-at-  # Prefix for Lambda functions (max 46 chars, total name ≤64)
RS_LAMBDA_OVERRIDE=1           # Override existing Lambdas (1=yes, 0=no)

# Redshift Gateway Configuration
RS_SCHEMA=yourname_carto       # Schema name for gateway functions (use directly)
# OR use RS_PREFIX (automatically concatenated with "carto")
RS_PREFIX=yourname_            # Schema prefix (e.g., "yourname_" → "yourname_carto")
                               # Note: RS_SCHEMA takes priority if both are set
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

### Installing Packages

**Redshift Gateway Functions:**

Redshift packages include an interactive installer (`scripts/install.py`) for deploying gateway Lambda functions:

```bash
cd dist/carto-at-redshift-1.1.3
python3 -m venv .venv && source .venv/bin/activate
pip install -r scripts/requirements.txt
python scripts/install.py
```

**Deployment phases:**
1. **Phase 0**: Auto-create IAM roles (Lambda execution + Redshift invoke) - if needed
2. **Phase 1**: Deploy Lambda functions
3. **Phase 2**: Create external SQL functions
4. **Phase 3**: Deploy native SQL UDFs

**Interactive Mode (default):**
```bash
python scripts/install.py  # Prompts for all configuration
```

**Non-Interactive Mode:**

**IMPORTANT**: Use `--non-interactive` flag to skip all prompts (required for automation/CI/CD):

```bash
python scripts/install.py \
  --non-interactive \
  --aws-region us-east-1 \
  --aws-access-key-id AKIAXXXX \
  --aws-secret-access-key XXXX \
  --rs-lambda-prefix myprefix- \
  --rs-host cluster.redshift.amazonaws.com \
  --rs-database mydb \
  --rs-user admin \
  --rs-password secret \
  --rs-schema myschema
```

**Other Clouds (SQL UDFs only):**
- **BigQuery**: `cd clouds/bigquery && make deploy`
- **Snowflake**: `cd clouds/snowflake && make deploy`
- **Databricks**: `cd clouds/databricks && make deploy`
- **Postgres**: `cd clouds/postgres && make deploy`

These clouds deploy native SQL UDFs directly without Lambda or installer.

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

#### Validation

The system validates function configurations at load time:

- **Error**: Function has neither SQL template nor parameters/returns metadata
- **Warning**: Function has both SQL template and metadata (template takes precedence)
- **OK**: Function has either SQL template or complete metadata (parameters + returns)

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

SQL templates use `@@VARIABLE@@` syntax that gets replaced at different stages:

**Available Variables:**
- `@@RS_SCHEMA@@`: Schema name (e.g., `dev_carto` or `carto`)
- `@@RS_LAMBDA_ARN@@`: Lambda function ARN
- `@@RS_LAMBDA_INVOKE_ROLE@@`: IAM role for Lambda invocation
- `@@RS_VERSION_FUNCTION@@`: Version function name (e.g., `VERSION_CORE`)
- `@@RS_PACKAGE_VERSION@@`: Package version (e.g., `1.1.3`)

**When Variables Are Replaced:**

**Package Generation Time** (fixed for the package):
- `@@RS_VERSION_FUNCTION@@` → Replaced with function name during build
- `@@RS_PACKAGE_VERSION@@` → Replaced with version number during build

**Installation Time** (user-specific):
- `@@RS_SCHEMA@@` → Preserved in packages, replaced during installation with user's schema
- Gateway variables (`@@RS_LAMBDA_ARN@@`, etc.) → Replaced during deployment

**How RS_SCHEMA Preservation Works:**

When creating packages, the build system passes `RS_SCHEMA='@@RS_SCHEMA@@'` to preserve the template:

```makefile
# Makefile - Package creation
(cd clouds/redshift && RS_SCHEMA='@@RS_SCHEMA@@' $(MAKE) build-modules ...)
```

This ensures packages contain `@@RS_SCHEMA@@` as a literal template, which the installer then replaces with the user's chosen schema name.

**SQL Wrapper Pattern for Lambda Functions:**

For Lambda functions that need to reference the schema in error messages, use a SQL wrapper that passes the schema as a parameter:

```sql
-- Internal Lambda function (accepts carto_schema as parameter)
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__FUNCTION_NAME_LAMBDA(
    -- ... other parameters ...
    carto_schema VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

-- Public wrapper function (injects @@SCHEMA@@ at deployment time)
CREATE OR REPLACE FUNCTION @@SCHEMA@@.__FUNCTION_NAME(
    -- ... other parameters ...
)
RETURNS VARCHAR(MAX)
AS $$
    SELECT @@SCHEMA@@.__FUNCTION_NAME_LAMBDA(
        -- ... other parameters ...
        '@@SCHEMA@@'
    )
$$ LANGUAGE sql;
```

The Lambda Python code receives the schema name as a parameter and can use it in error messages.

### Gateway Deployment

**Gateway functions support flexible schema configuration:**
- **RS_SCHEMA**: Use directly as schema name (e.g., `RS_SCHEMA=yourname_carto` → "yourname_carto")
- **RS_PREFIX**: Concatenate with "carto" (e.g., `RS_PREFIX=yourname_` → "yourname_carto")
- **Priority**: `RS_SCHEMA` takes precedence if both are set
- **Consistency**: Using `RS_PREFIX` matches clouds behavior for consistent naming
- Lambda functions use `RS_LAMBDA_PREFIX` (e.g., `yourname-at-qb_polyfill`)
- Control Lambda updates with `RS_LAMBDA_OVERRIDE` (1=update existing, 0=skip existing)

### Package Customization (Extensibility Pattern)

Core's packaging system supports extensibility through a **try/except import pattern** that allows external repositories (like premium) to customize packages without modifying core code.

**How Core Enables Extension:**

The core packager (`gateway/logic/clouds/redshift/packager.py`) includes an extension point:

```python
def create_package(...):
    """Create base package with core functions."""
    # ... create base package ...

    # Extension point: Allow external customization
    try:
        # Import premium packager if available
        from gateway.logic.clouds.redshift.packager import customize_package
        customize_package(package_dir, production, functions)
    except ImportError:
        # No premium packager - core-only package
        pass
```

**External Customization Interface:**

External repositories can create `gateway/logic/clouds/redshift/packager.py` with:

```python
def customize_package(package_dir: str, production: bool, functions: dict) -> None:
    """Customize package with external-specific content.

    Args:
        package_dir: Path to package directory (full access)
        production: Whether this is a production build
        functions: Dictionary of all functions being packaged

    Example use cases:
        - Add proprietary setup scripts
        - Generate additional configuration files
        - Modify package structure for deployment requirements
    """
    # Full access to modify package_dir
    pass
```

**Key Benefits:**
- **Core remains generic**: No premium-specific code in open-source core
- **Convention-based**: Core automatically detects and uses external packager if present
- **Clean separation**: Extension point is clearly defined and documented
- **Full flexibility**: External packager has complete access to package directory

**Files Involved:**
- Core packager: `gateway/logic/clouds/redshift/packager.py` (defines extension point)
- External packager: Created by external repository at same path
- Activated during: `make create-package`

### Diff Parameter Handling in Makefiles

When passing file lists through Make targets, **proper quoting is critical** to prevent Make from interpreting space-separated filenames as multiple targets.

**Problem:**
```makefile
# WRONG - Each filename becomes a separate target
$(if $(diff),diff=$(diff),)

# If diff=".github/workflows/redshift.yml Makefile README.md"
# Make interprets this as three separate targets and fails with:
# make: *** No rule to make target '.github/workflows/redshift.yml'
```

**Solution:**
```makefile
# CORRECT - Entire string passed as single quoted value
$(if $(diff),diff='$(diff)',)

# Properly passes: diff='.github/workflows/redshift.yml Makefile README.md'
```

**Where This Matters:**

1. **Core Root Makefile** (`Makefile`, line 148):
   ```makefile
   cd gateway && $(MAKE) deploy cloud=$(cloud) \
       $(if $(diff),diff='$(diff)',)
   ```

2. **Gateway Makefile** (`gateway/Makefile`, lines 154, 163):
   ```makefile
   # Converts to boolean flag (not the value)
   $(if $(diff),--diff,)
   ```

**Architecture Flow:**

```
CI Workflow / External Caller
  ↓ diff="file1 file2 file3"
Core Root Makefile
  ↓ diff='$(diff)' (quoted!)
Gateway Makefile
  ↓ --diff (flag only)
Python CLI (gateway/logic/clouds/redshift/cli.py)
  ↓ reads $GIT_DIFF from environment
  ↓ detects infrastructure changes
  ↓ decides: deploy ALL or deploy CHANGED
```

**Infrastructure Change Detection:**

The Python CLI automatically detects infrastructure changes and deploys all functions when these paths are modified:
- `.github/workflows/` - CI/CD configuration
- `Makefile` - Build system changes
- `logic/` - Deployment logic changes
- `platforms/` - Platform code changes
- `requirements.txt` - Dependency changes

**Key Points:**
- Root Makefile must quote: `diff='$(diff)'`
- Gateway Makefile uses flag: `--diff` (no value)
- Python CLI reads `$GIT_DIFF` environment variable directly
- Infrastructure files trigger full deployment automatically
- Clouds Makefiles don't use diff (always deploy all SQL UDFs)

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

### Test Structure Standards

All gateway function tests follow a standardized structure with clear separation:

**File Structure:**
```python
"""
Unit tests for function_name function.

This file contains:
- Handler Interface Tests: Validate Lambda handler and batch processing
- Function Logic Tests: Validate internal algorithms and helpers (if complex)
"""

# Copyright (c) 2025, CARTO

import json
from test_utils.unit import load_function_module

# Load handler and functions
imports = load_function_module(__file__)
lambda_handler = imports["lambda_handler"]

# For functions with internal helpers to test:
imports = load_function_module(
    __file__,
    {
        "from_lib": ["function_from_lib"],              # From lib/__init__.py
        "from_lib_module": {                            # From lib/submodule.py
            "module_name": ["helper_func"]
        },
        "from_handler": ["internal_func"]              # From handler.py itself
    }
)

# ============================================================================
# HANDLER INTERFACE TESTS
# ============================================================================

class TestLambdaHandler:
    """Test the Lambda handler interface."""
    # Tests: empty events, null inputs, batch processing

# ============================================================================
# FUNCTION LOGIC TESTS (only for complex functions)
# ============================================================================

class TestHelperFunction:
    """Test helper_function directly."""
    # Direct tests of algorithms, edge cases, mathematical correctness
```

**Testing Tiers:**
- **Tier 1** (Handler only): Simple functions - validate Lambda interface
- **Tier 2** (Handler + Logic): Complex functions - also test internal algorithms directly
- **Tier 3** (Integration): Functions requiring database state validation

**Key Utilities:**
- `load_function_module(__file__)` - Loads from build directory with shared libs
- `from_handler` parameter - Access internal functions from handler.py for testing

### Running Tests

```bash
cd gateway

# Build before testing (required)
make build cloud=redshift

# Run unit tests
make test-unit cloud=redshift

# Run integration tests
make test-integration cloud=redshift

# Run linter
make lint
```

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

## Extending Cloud Support

The gateway uses a registry pattern for cloud-specific type mappings, allowing new clouds to be added without modifying core code.

### Type Mapping Architecture

**TypeMapperRegistry** (`core/gateway/logic/common/engine/type_mapper.py`):
- Cloud-agnostic registry maintaining type mapping providers
- Each cloud registers its own TypeMappingProvider implementation
- Provides unified interface: `TypeMapperRegistry.map_type("string", "redshift")` → `"VARCHAR(MAX)"`

### Adding a New Cloud

To add support for a new cloud (e.g., BigQuery, Snowflake):

**1. Create cloud-specific type mappings:**

```python
# core/gateway/logic/clouds/bigquery/type_mappings.py
from ...common.engine.type_mapper import TypeMapperRegistry

class BigQueryTypeMappings:
    """BigQuery-specific type mapping provider"""

    TYPE_MAPPINGS = {
        "string": "STRING",
        "int": "INT64",
        "bigint": "INT64",
        "float": "FLOAT64",
        "double": "FLOAT64",
        "boolean": "BOOL",
        "bytes": "BYTES",
        "object": "JSON",
        "geometry": "GEOGRAPHY",  # BigQuery uses GEOGRAPHY for spatial
        "geography": "GEOGRAPHY",
    }

    def map_type(self, generic_type: str) -> str:
        """Map generic type to BigQuery SQL type"""
        generic_lower = generic_type.lower()
        if generic_lower in self.TYPE_MAPPINGS:
            return self.TYPE_MAPPINGS[generic_lower]
        return generic_type  # Already cloud-specific

    def is_generic_type(self, type_str: str) -> bool:
        """Check if type is generic"""
        return type_str.lower() in self.TYPE_MAPPINGS

    def get_supported_generic_types(self) -> list[str]:
        """Get supported generic types"""
        return list(self.TYPE_MAPPINGS.keys())

# Auto-register when module is imported
_bigquery_mapper = BigQueryTypeMappings()
TypeMapperRegistry.register("bigquery", _bigquery_mapper)
```

**2. Update CloudType enum:**

```python
# core/gateway/logic/common/engine/models.py
class CloudType(Enum):
    """Supported cloud platforms"""
    REDSHIFT = "redshift"
    BIGQUERY = "bigquery"  # Add new cloud
```

**3. Import the mapping in your cloud CLI:**

```python
# core/gateway/logic/clouds/bigquery/cli.py
from .type_mappings import BigQueryTypeMappings  # Triggers auto-registration
```

**4. Implement cloud-specific deployment logic:**
- SQL template generator (like `RedshiftSQLTemplateGenerator`)
- Template renderer for cloud-specific SQL syntax
- CLI commands for deployment
- Pre-flight checks and validation

### Current Implementation

**Redshift** (`core/gateway/logic/clouds/redshift/type_mappings.py`):
- Implements `RedshiftTypeMappings` class
- Maps generic types to Redshift SQL types (VARCHAR(MAX), INT8, SUPER, etc.)
- Auto-registers on import via `TypeMapperRegistry.register("redshift", ...)`

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
