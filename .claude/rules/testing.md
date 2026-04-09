---
paths:
  - "**/test*"
  - "**/tests/**"
---

# Testing Standards

## Test Structure Standards

All gateway function tests follow a standardized structure with clear separation:

### File Structure

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

## Testing Tiers

- **Tier 1** (Handler only): Simple functions - validate Lambda interface
- **Tier 2** (Handler + Logic): Complex functions - also test internal algorithms directly
- **Tier 3** (Integration): Functions requiring database state validation

## Key Utilities

### load_function_module

`load_function_module(__file__)` - Loads from build directory with shared libs.

Parameters:
- `from_lib` - Access functions from `lib/__init__.py`
- `from_lib_module` - Access functions from `lib/submodule.py` (dict of `{module_name: [func_names]}`)
- `from_handler` - Access internal functions from `handler.py` for direct testing

## Running Tests

**Gateway functions require building before testing** (copies shared libraries):

```bash
cd gateway

# Build all functions (required before tests)
make build cloud=redshift

# Run all unit tests
make test-unit cloud=redshift

# Run specific module tests
make test-unit cloud=redshift modules=statistics

# Run specific function tests
make test-unit cloud=redshift functions=getis_ord_quadbin

# Run integration tests
make test-integration cloud=redshift

# Run linter
make lint
```

**Cloud SQL function tests:**

```bash
cd clouds/redshift

# Run all tests
make test

# Run specific module tests
make test modules=h3

# Run specific function tests
make test functions=H3_POLYFILL
```

## Unit Test Example

```python
# gateway/functions/module/function/tests/unit/test_function.py

import pytest
from unittest.mock import Mock, patch

# Import from built structure
from lib.statistics import get_neighbors
from lib.kernel import kernel_weight


def test_process_row_valid_input(handler_module):
    """Test handler with valid input."""
    row = [{"data": "..."}, 5, "uniform"]
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

## Integration Test Example

```python
# gateway/functions/module/function/tests/integration/test_function.py

import pytest
import boto3


@pytest.mark.integration
def test_lambda_invocation():
    """Test actual Lambda function."""
    client = boto3.client("lambda")
    response = client.invoke(
        FunctionName="dev_function_name",
        Payload=json.dumps({"data": "test"})
    )
    assert response["StatusCode"] == 200


@pytest.mark.integration
def test_redshift_external_function():
    """Test Redshift external function."""
    import psycopg2
    conn = psycopg2.connect(...)
    cursor = conn.cursor()
    cursor.execute("SELECT dev_carto.function_name(...)")
    result = cursor.fetchone()
    assert result is not None
```

Integration tests connect to real Redshift clusters and test deployed functions. They require proper `.env` configuration and deployed functions.
