# Test Utilities

This directory contains shared test utilities for Analytics Toolbox Gateway functions.

## Structure

```
test_utils/
├── __init__.py
├── unit/                        # Language-specific unit test helpers
│   ├── __init__.py
│   └── python.py               # Python Lambda/Cloud Run utilities
└── integration/                 # Cloud-specific integration test helpers
    ├── __init__.py
    └── redshift.py             # Amazon Redshift utilities
```

## Usage

### Unit Tests (Python)

For testing Python function logic without database dependencies:

```python
"""Unit tests for MY_FUNCTION"""

from test_utils.unit import load_function_module
# Or explicitly: from test_utils.unit.python import load_function_module

# Load function module and handler
imports = load_function_module(
    __file__,
    {
        'from_lib': ['my_function', 'HelperClass'],
        'from_lib_module': {
            'helper': ['helper_func1', 'helper_func2']
        }
    },
)

my_function = imports['my_function']
HelperClass = imports['HelperClass']
helper_func1 = imports['helper_func1']
lambda_handler = imports['lambda_handler']


class TestMyFunction:
    def test_basic_case(self):
        result = my_function("input")
        assert result == "expected"
```

### Integration Tests (Redshift)

For testing deployed functions against a real Redshift database:

```python
"""Integration tests for MY_FUNCTION"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestMyFunctionIntegration:
    def test_basic_query(self):
        """Test function with basic input"""
        result = run_query("""
            SELECT @@RS_SCHEMA@@.MY_FUNCTION('test')
        """)
        assert result[0][0] == 'expected_value'
```

The `run_query` helper automatically:
- Loads credentials from `.env`
- Skips tests if `redshift_connector` is not installed
- Calculates schema from `RS_PREFIX` environment variable
- Replaces `@@RS_SCHEMA@@` placeholder in queries
- Manages database connection lifecycle

## Backward Compatibility

The root `conftest.py` re-exports utilities for backward compatibility:

```python
# This still works (but new tests should use test_utils directly)
from conftest import load_function_module, run_query
```

## Adding New Utilities

### Adding a new cloud platform (for integration tests)

1. Create `test_utils/integration/{cloud_name}.py`
2. Implement cloud-specific `run_query()` or equivalent helper function
3. Export it in `test_utils/integration/__init__.py` (optional)
4. Update this README with usage examples

Example: Adding BigQuery support
```python
# test_utils/integration/bigquery.py
"""Google BigQuery integration test utilities."""

import os
import pytest
from google.cloud import bigquery

def run_query(query):
    """Execute a query against BigQuery for integration testing."""
    # Implementation here
    pass
```

### Adding a new language (for unit tests)

1. Create `test_utils/unit/{language_name}.py` (or `.js`, `.go`, etc.)
2. Implement language-specific module loading helpers
3. Export key functions in `test_utils/unit/__init__.py` if appropriate
4. Update this README with usage examples

Example: Adding JavaScript support
```javascript
// test_utils/unit/javascript.js
/**
 * JavaScript/Node.js unit test utilities for gateway functions.
 */

function loadFunctionModule(testFilePath, imports) {
    // Implementation to load and test JavaScript Lambda/Cloud Run functions
}

module.exports = { loadFunctionModule };
```

## Environment Variables

### Redshift Integration Tests

Required environment variables (set in `.env` at gateway or core root):

- `RS_HOST`: Redshift cluster endpoint
- `RS_DATABASE`: Database name
- `RS_USER`: Database user
- `RS_PASSWORD`: Database password
- `RS_PREFIX`: (Optional) Schema prefix for testing
