# Handler Development Guide

Guide for developing platform-specific handlers for Analytics Toolbox functions.

## Overview

Handlers are **platform-specific** by design. Each cloud/platform has different runtime requirements, so we maintain separate handler implementations per platform.

### Directory Structure

```
functions/
└── <module>/
    └── <function>/
        ├── function.yaml                # Multi-cloud configuration
        └── code/
            ├── lambda/python/           # AWS Lambda (for Redshift, Snowflake)
            │   ├── handler.py
            │   └── requirements.txt
            ├── bigquery/                # BigQuery JavaScript UDF
            │   └── function.js
            ├── databricks/              # Databricks Python UDF
            │   └── function.py
            └── snowpark/                # Snowflake Snowpark
                └── handler.py
```

## AWS Lambda Handlers (Redshift, Snowflake)

### Simple Handler Pattern

For AWS Lambda handlers (used by Redshift and Snowflake), import the platform wrapper:

```python
"""
CARTO Analytics Toolbox - MY_FUNCTION
Lambda handler for Redshift external function
"""

# Import lambda wrapper
# In Lambda deployment: packaged as carto_analytics_toolbox_core
# In local tests: conftest.py sets up the module alias
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler


@redshift_handler
def process_row(row):
    """
    Process a single request row.

    Args:
        row: List containing function arguments

    Returns:
        Processed result, or None for invalid inputs
    """
    # Handle invalid input
    if not row or len(row) < 1:
        return None

    # Your business logic here
    value = row[0]
    result = process_value(value)

    return result


# Export as lambda_handler for AWS Lambda
lambda_handler = process_row
```

### Why This Import Works Everywhere

**In Lambda Deployment:**
- Deployer packages `runtime/lambda_wrapper.py` as `carto_analytics_toolbox_core/lambda_wrapper.py`
- Handler imports from `carto_analytics_toolbox_core.lambda_wrapper` ✓

**In Local Tests:**
- `conftest.py` creates module alias before tests run
- Handler imports from `carto_analytics_toolbox_core.lambda_wrapper` ✓

**No try/except needed** - single import works in both environments!

### Error Handling Modes

The `@redshift_handler` decorator supports three error modes:

```python
from carto_analytics_toolbox_core.lambda_wrapper import (
    redshift_handler,
    ErrorHandlingMode
)

# FAIL_FAST (default): Stop entire batch on first error
@redshift_handler
def process_row(row):
    # Any error fails the batch
    return process(row)

# RETURN_ERROR: Return error as JSON for failed rows
@redshift_handler(error_mode=ErrorHandlingMode.RETURN_ERROR)
def process_row(row):
    # Errors returned as: {"error": "...", "row_index": N}
    return process(row)

# SILENT: Log errors, return None for failed rows
@redshift_handler(error_mode=ErrorHandlingMode.SILENT)
def process_row(row):
    # Errors logged to CloudWatch, None returned
    return process(row)
```

**Default is FAIL_FAST** - most functions should use this to ensure data quality.

### Batch Processing Pattern

For functions that benefit from batch processing:

```python
from carto_analytics_toolbox_core.lambda_wrapper import batch_redshift_handler


@batch_redshift_handler
def process_batch(rows):
    """
    Process all rows at once.

    Args:
        rows: List of row lists

    Returns:
        List of results (must match input length)
    """
    # Process all rows together for efficiency
    results = []
    for row in rows:
        results.append(process_row(row))

    return results


lambda_handler = process_batch
```

## GCP Cloud Functions Handlers (BigQuery)

### Future Pattern

```python
"""
CARTO Analytics Toolbox - MY_FUNCTION
Cloud Function handler for BigQuery remote function
"""

# In GCP: packaged as carto_analytics_toolbox_core
# In tests: conftest.py sets up alias
from carto_analytics_toolbox_core.cloud_run_wrapper import bigquery_handler


@bigquery_handler
def process_request(request):
    """Process BigQuery remote function request"""
    # BigQuery-specific request handling
    pass


# Export for Cloud Functions
main = process_request
```

## Platform-Specific vs Business Logic

### ✅ GOOD: Separate concerns

**Business Logic** (platform-agnostic):
```python
# business_logic.py
def reverse_string(s: str) -> str:
    """Pure business logic - works anywhere"""
    return s[::-1] if s else None
```

**Handler** (platform-specific):
```python
# handler.py
from carto_analytics_toolbox_core.lambda_wrapper import redshift_handler
from business_logic import reverse_string


@redshift_handler
def process_row(row):
    """Platform-specific wrapper"""
    if not row or row[0] is None:
        return None
    return reverse_string(row[0])


lambda_handler = process_row
```

### ❌ BAD: Mixed concerns

```python
# handler.py
@redshift_handler
def process_row(row):
    """Business logic mixed with platform handling"""
    if not row:  # Platform concern
        return None

    # Business logic embedded in handler
    s = row[0]
    result = s[::-1] if s else None
    return result
```

## Testing Handlers

### Unit Tests

Tests automatically work thanks to `conftest.py`:

```python
"""
Unit tests for MY_FUNCTION
"""

# No special setup needed - conftest.py handles imports
from handler import process_row, lambda_handler


def test_process_row():
    """Test row processing"""
    result = process_row(["hello"])
    assert result == "olleh"


def test_lambda_handler():
    """Test full Lambda handler"""
    event = {
        "arguments": [["hello"], ["world"]],
        "num_records": 2
    }

    import json
    response = json.loads(lambda_handler(event))

    assert response["success"] is True
    assert response["results"] == ["olleh", "dlrow"]
```

### How conftest.py Works

`conftest.py` at the gateway root automatically:
1. Adds runtime path to `sys.path`
2. Creates `carto_analytics_toolbox_core` module alias
3. Runs before any test

So handlers can use the same import in both deployment and tests!

## Adding Support for New Platforms

### Step 1: Create Platform Runtime Wrapper

```python
# logic/platforms/gcp-cloud-functions/runtime/cloud_run_wrapper.py
def bigquery_handler(func):
    """Decorator for BigQuery remote function handlers"""
    def cloud_function_handler(request):
        # GCP-specific error handling and response format
        try:
            data = request.get_json()
            results = [func(row) for row in data['calls']]
            return {'replies': results}
        except Exception as e:
            return {'errorMessage': str(e)}, 400

    return cloud_function_handler
```

### Step 2: Update conftest.py

```python
# conftest.py
# Add GCP runtime path
gcp_runtime = Path(__file__).parent / "logic" / "platforms" / "gcp-cloud-functions" / "runtime"
if gcp_runtime.exists():
    if str(gcp_runtime) not in sys.path:
        sys.path.insert(0, str(gcp_runtime))

    try:
        import cloud_run_wrapper
        sys.modules['carto_analytics_toolbox_core.cloud_run_wrapper'] = cloud_run_wrapper
    except ImportError:
        pass
```

### Step 3: Create Handler

```python
# functions/my_module/my_function/code/cloud_run/python/handler.py
from carto_analytics_toolbox_core.cloud_run_wrapper import bigquery_handler


@bigquery_handler
def process_row(row):
    # Business logic
    return result


# GCP Cloud Functions entry point
main = process_row
```

### Step 4: Update Deployer

```python
# logic/platforms/gcp-cloud-functions/deploy/deployer.py
class CloudRunDeployer:
    def package_function(self, function_path, requirements_path):
        # Package runtime as carto_analytics_toolbox_core namespace
        # (same pattern as AWS Lambda deployer)
        pass
```

## Best Practices

### 1. Keep Handlers Thin

Handlers should only:
- Import platform wrapper
- Handle null/invalid inputs
- Call business logic
- Return results

Business logic belongs in separate modules.

### 2. Use Type Hints

```python
from typing import Optional, List


@redshift_handler
def process_row(row: List) -> Optional[str]:
    """Process row with type hints for clarity"""
    pass
```

### 3. Document Expected Input

```python
@redshift_handler
def process_row(row):
    """
    Process geocoding request.

    Args:
        row: List containing [address, country_code] where:
            - address: Address string to geocode
            - country_code: Optional ISO country code

    Returns:
        WKT point string, or None if geocoding fails
    """
    pass
```

### 4. Default to FAIL_FAST

Most functions should fail fast to maintain data quality:

```python
@redshift_handler  # FAIL_FAST by default
def process_row(row):
    # Any error stops the batch - ensures data quality
    pass
```

Only use `RETURN_ERROR` or `SILENT` if you have a specific reason (e.g., optional enrichment).

## Summary

✅ **Handlers are platform-specific by design** - each platform has its own directory

✅ **Single import works everywhere** - no try/except needed thanks to conftest.py

✅ **Easy to add new platforms** - create runtime wrapper + update conftest.py

✅ **Clean separation** - business logic separate from platform wrappers

✅ **Testable** - conftest.py makes testing seamless

For more details, see:
- [ARCHITECTURE.md](ARCHITECTURE.md) - Overall architecture
- [MULTI_CLOUD_SUPPORT.md](../gateway/MULTI_CLOUD_SUPPORT.md) - Adding new clouds
- [README.md](README.md) - Gateway overview
