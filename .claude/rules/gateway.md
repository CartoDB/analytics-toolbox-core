---
paths:
  - "gateway/**"
---

# Gateway Architecture

## Cloud and Platform Agnosticism

All gateway deployment logic is in `gateway/logic/` and is designed to be cloud and platform agnostic.

### Architecture Layers

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

## Shared vs Function-Specific Libraries

**Critical Rule**: Only create shared libraries when code is used by **multiple functions** (2+).

### Shared Libraries (`gateway/functions/_shared/python/`)

- **Purpose**: Code used by multiple functions
- **Location**: `_shared/python/<module_name>/`
- **Reference**: Listed in function.yaml `shared_libs` field
- **Build**: Copied to each function's `lib/<module_name>/` during `make build`
- **Import**: `from lib.<module_name> import ...`

**Examples:**
```python
# gateway/functions/_shared/python/statistics/
from lib.statistics import get_neighbors  # Used by multiple stat functions

# gateway/functions/_shared/python/tiler/
from lib.tiler import simple_tiler       # Used by multiple tiler functions
```

### Function-Specific Libraries (`<function>/code/lambda/python/lib/`)

- **Purpose**: Code used by **only one function**
- **Location**: `code/lambda/python/lib/` within function directory
- **Reference**: Not in function.yaml (automatically included)
- **Build**: Included directly in function package
- **Import**: `from lib.<module> import ...`

**Examples:**
```python
# statistics/__getis_ord_quadbin/code/lambda/python/lib/kernel.py
from lib.kernel import kernel_weight  # Only used by getis_ord

# statistics/__morans_i_quadbin/code/lambda/python/lib/decay.py
from lib.decay import distance_decay  # Only used by morans_i
```

**Why This Matters:**
- `kernel.py` and `decay.py` are **NOT duplicates** - they're intentionally function-specific
- This provides **isolation** and **independent versioning** per function
- Prevents coupling between unrelated functions
- Allows different functions to evolve independently

## Handler Patterns and Decorators

### Standard Pattern (98% of functions)

```python
from carto.lambda_wrapper import redshift_handler

@redshift_handler
def process_row(row):
    """Process single row from Redshift batch."""
    # Validation
    if not row or len(row) < expected_params:
        return None

    # Extract parameters
    param1 = row[0]
    param2 = row[1]

    # Validation
    if param1 is None or param2 is None:
        return None

    # Process
    result = compute_something(param1, param2)

    return result

# Export for AWS Lambda
lambda_handler = process_row
```

**What `@redshift_handler` does:**
- Handles batch processing (receives array of rows from Redshift)
- Processes each row individually
- Aggregates results
- Handles errors and returns proper response format
- Manages Lambda context

### Alternative Pattern (for complex functions)

```python
def my_function(param1, param2):
    """Core function logic."""
    from lib.shared_module import helper
    return helper(param1, param2)

@redshift_handler
def process_row(row):
    """Wrapper for redshift_handler."""
    if not row or len(row) < 2:
        return None
    return my_function(row[0], row[1])

lambda_handler = process_row
```

## Build System Details

**What happens during `make build cloud=redshift`:**

### 1. Discovery Phase

```python
# Scans for function.yaml files in:
gateway/functions/**/function.yaml
```

### 2. Validation Phase

```python
# Validates each function.yaml:
- Required fields present
- Lambda name <=18 chars
- Shared libs exist
- Code files exist
```

### 3. Copy Phase

```python
# For each function with shared_libs:
for lib in function.shared_libs:
    copy _shared/python/{lib}/ to {function}/code/lambda/python/lib/{lib}/
```

### 4. Package Phase

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

## Deployment Flow

**Complete Deployment Process:**

```
1. Load Function Catalog (gateway/logic/common/engine/catalog_loader.py)
   |-> Scan gateway/functions/
   |-> Parse all function.yaml files

2. Validate Functions (gateway/logic/common/engine/validators.py)
   |-> Check required fields
   |-> Validate lambda_name length
   |-> Verify shared_libs exist
   |-> Validate code files exist

3. Package Functions (gateway/logic/common/engine/packagers.py)
   |-> Copy function code
   |-> Copy shared libraries (if specified)
   |-> Install requirements (if specified)
   |-> Create deployment package (.zip)

4. Deploy to Lambda (gateway/logic/platforms/aws-lambda/)
   |-> Upload Lambda package to AWS
   |-> Set memory, timeout, runtime config
   |-> Configure IAM role
   |-> Get Lambda ARN

5. Create External Functions (gateway/logic/clouds/redshift/)
   |-> Generate SQL from template or auto-generate
   |-> Replace @@VARIABLES@@ with actual values
   |-> Execute SQL on Redshift
   |-> Link external function to Lambda ARN

6. Verify Deployment
   |-> Test Lambda invocation
   |-> Test external function call
```

## Template Variables

SQL templates use `@@VARIABLE@@` syntax that gets replaced at different stages:

```sql
CREATE OR REPLACE EXTERNAL FUNCTION @@RS_SCHEMA@@.GETIS_ORD_QUADBIN(...)
LAMBDA '@@RS_LAMBDA_ARN@@'
IAM_ROLE '@@RS_LAMBDA_INVOKE_ROLE@@';
```

**Available Variables:**
- `@@RS_SCHEMA@@`: Schema name (e.g., `dev_carto` or `carto`)
- `@@RS_LAMBDA_ARN@@`: Lambda function ARN
- `@@RS_LAMBDA_INVOKE_ROLE@@`: IAM role for Lambda invocation
- `@@RS_VERSION_FUNCTION@@`: Version function name (e.g., `VERSION_CORE`, `VERSION_ADVANCED`)
- `@@RS_PACKAGE_VERSION@@`: Package version (e.g., `1.11.2`)

**When Variables Are Replaced:**

**Package Generation Time** (fixed for the package):
- `@@RS_VERSION_FUNCTION@@` -> Replaced with function name during build
- `@@RS_PACKAGE_VERSION@@` -> Replaced with version number during build

**Installation Time** (user-specific):
- `@@RS_SCHEMA@@` -> Preserved in packages, replaced during installation with user's schema
- Gateway variables (`@@RS_LAMBDA_ARN@@`, etc.) -> Replaced during deployment

**How RS_SCHEMA Preservation Works:**

When creating packages, the build system passes `RS_SCHEMA='@@RS_SCHEMA@@'` to preserve the template:

```makefile
# Makefile - Package creation
(cd clouds/redshift && RS_SCHEMA='@@RS_SCHEMA@@' $(MAKE) build-modules ...)
```

This ensures packages contain `@@RS_SCHEMA@@` as a literal template, which the installer then replaces with the user's chosen schema name.

### SQL Wrapper Pattern for Lambda Functions

For Lambda functions that need to reference the schema in error messages, use a SQL wrapper:

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

The Lambda Python code receives the schema name as a parameter:

```python
@redshift_handler
def process_row(row):
    # ... extract other parameters ...
    carto_schema = row[-1]  # Last parameter

    # Can now use carto_schema in error messages
    raise Exception(f"Error in {carto_schema}.FUNCTION_NAME: ...")
```

This pattern is used by functions like `__generic_is_configured` and data enrichment functions.

## Gateway Deployment Configuration

**Gateway functions support flexible schema configuration:**
- **RS_SCHEMA**: Use directly as schema name (e.g., `RS_SCHEMA=yourname_carto` -> "yourname_carto")
- **RS_PREFIX**: Concatenate with "carto" (e.g., `RS_PREFIX=yourname_` -> "yourname_carto")
- **Priority**: `RS_SCHEMA` takes precedence if both are set
- **Consistency**: Using `RS_PREFIX` matches clouds behavior for consistent naming
- Lambda functions use `RS_LAMBDA_PREFIX` (e.g., `yourname-at-qb_polyfill`)
- Control Lambda updates with `RS_LAMBDA_OVERRIDE` (1=update existing, 0=skip existing)

## Package Customization (Extensibility Pattern)

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

## Module Organization

### Core Modules (open source in `gateway/functions/`)

- `quadbin`: Quadbin spatial indexing
- `quadkey`: Quadkey spatial indexing
- `s2`: S2 geometry
- `placekey`: Placekey operations
- `clustering`: Spatial clustering
- `constructors`: Geometry constructors
- `processing`: Geometry processing
- `transformations`: Coordinate transformations
- `random`: Random data generation

## Troubleshooting Guide

**Common Issues:**

1. **Import Error: `ModuleNotFoundError: No module named 'lib'`**
   - **Cause**: Build not run before tests
   - **Fix**: `make build cloud=redshift`

2. **Lambda Deploy Fails: `ResourceName too long`**
   - **Cause**: lambda_name + prefix > 64 chars
   - **Fix**: Shorten lambda_name in function.yaml to <=18 chars

3. **Test Import Error: `No module named 'lib.statistics'`**
   - **Cause**: shared_libs not specified in function.yaml
   - **Fix**: Add `shared_libs: [statistics]` to function.yaml, rebuild

4. **Function Not Found During Deploy**
   - **Cause**: function.yaml missing or invalid
   - **Fix**: Validate function.yaml structure, check required fields

5. **External Function Error: `Permission denied for Lambda`**
   - **Cause**: RS_LAMBDA_INVOKE_ROLE not set or incorrect
   - **Fix**: Verify IAM role ARN in .env file

6. **Build Copies Wrong Library Version**
   - **Cause**: Old build artifacts
   - **Fix**: `make clean && make build cloud=redshift`
