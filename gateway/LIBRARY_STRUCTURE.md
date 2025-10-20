# Library Structure Best Practices

## Overview

This document describes the recommended structure for shared libraries in the Analytics Toolbox gateway.

## Core Principles

### 1. Shared Libraries (`functions/_shared/python/`)

Shared libraries are copied into each function's `lib/` directory during the build process. They should export all public APIs through their `__init__.py` file.

**Structure:**
```
functions/_shared/python/
├── clustering/
│   ├── __init__.py          # Exports all public functions/classes
│   ├── kmeans.py            # Implementation
│   └── helper.py            # Helper functions
├── s2/
│   └── __init__.py          # All functions defined here
├── placekey/
│   ├── __init__.py          # Exports all public functions
│   └── placekey.py          # Implementation
└── ...
```

### 2. Import Pattern in Functions

**Always use this pattern:**
```python
from lib.clustering import (
    KMeans,
    PRECISION,
    load_geom,
    reorder_coords,
)
```

**NOT this pattern:**
```python
# ❌ DON'T use submodule imports
from lib.clustering.helper import (...)

# ❌ DON'T use try/except fallbacks
try:
    from lib.clustering import KMeans
except ImportError:
    from clustering import KMeans
```

**Reason:** The build system copies shared libraries into `lib/`, and the shared library's `__init__.py` should export everything. This keeps imports simple and consistent.

### 3. Shared Library `__init__.py` Template

```python
"""
Brief description of the library.

Explanation of what it provides.
"""

from .implementation import ClassA, function_b
from .helper import helper_function, CONSTANT

__all__ = [
    "ClassA",
    "function_b",
    "helper_function",
    "CONSTANT",
]
```

**Key points:**
- Import from submodules (`.implementation`, `.helper`)
- Re-export everything in `__all__`
- Add docstring explaining the library's purpose

### 4. Function `lib/__init__.py` Structure

Functions that use shared libraries should have a simple `lib/__init__.py`:

```python
"""
FUNCTION_NAME function implementation.

Imports shared utilities from lib/shared_library_name/
which is populated during the build step.
"""

from lib.shared_library import (
    required_function,
    required_class,
    CONSTANT,
)


def function_name(args):
    """Function implementation."""
    # Use imported functions
    result = required_function(args)
    return result


__all__ = ["function_name"]
```

**Key points:**
- Simple, direct imports from `lib.shared_library`
- No try/except blocks
- No sys.path manipulation
- Function implementation in the same file

### 5. Test Structure

Tests should use `load_function_module` from `test_utils.unit`:

```python
from test_utils.unit import load_function_module

# Load function and shared library items
imports = load_function_module(
    __file__,
    {
        "from_lib": ["my_function"],
        "from_lib_module": {
            "clustering": ["KMeans", "reorder_coords"],
        },
    },
)

my_function = imports["my_function"]
KMeans = imports["KMeans"]
reorder_coords = imports["reorder_coords"]
```

**Benefits:**
- Tests use the same structure as deployment
- Load from `build/` directory (created by `make build`)
- No sys.path manipulation needed

## Examples

### Good: Clustering Library

**functions/_shared/python/clustering/__init__.py:**
```python
from .kmeans import KMeans
from .helper import (
    PRECISION,
    load_geom,
    reorder_coords,
    count_distinct_coords,
    extract_coords_from_geojson,
)

__all__ = [
    "KMeans",
    "PRECISION",
    "load_geom",
    "reorder_coords",
    "count_distinct_coords",
    "extract_coords_from_geojson",
]
```

**functions/clustering/clusterkmeans/code/lambda/python/lib/__init__.py:**
```python
from lib.clustering import (
    KMeans,
    PRECISION,
    load_geom,
    reorder_coords,
    count_distinct_coords,
    extract_coords_from_geojson,
)

def clusterkmeans(geom_json, k):
    geom = load_geom(geom_json)
    coords = reorder_coords(extract_coords_from_geojson(geom))
    cluster_idxs, centers, loss = KMeans()(coords, k)
    return result
```

### Bad Examples

**❌ Don't import from submodules:**
```python
# BAD - imports from helper submodule
from lib.clustering.helper import reorder_coords

# GOOD - import from library root
from lib.clustering import reorder_coords
```

**❌ Don't use try/except fallbacks:**
```python
# BAD - try/except fallback pattern
try:
    from lib.clustering import KMeans
except ImportError:
    from clustering import KMeans

# GOOD - direct import (build system handles this)
from lib.clustering import KMeans
```

**❌ Don't manipulate sys.path in tests:**
```python
# BAD - manual path manipulation
import sys
import os
lib_path = os.path.join(os.path.dirname(__file__), "../../code/lambda/python/lib")
sys.path.insert(0, os.path.abspath(lib_path))
from my_function import my_function

# GOOD - use load_function_module
from test_utils.unit import load_function_module
imports = load_function_module(__file__, {"from_lib": ["my_function"]})
my_function = imports["my_function"]
```

## Configuration

### function.yaml

Functions specify which shared libraries they need via the `shared_libs` configuration:

```yaml
clouds:
  redshift:
    runtime: aws-lambda:python3.9
    shared_libs:
      - clustering
```

During build/deploy, the build system:
1. Reads `function.yaml`
2. Copies specified libraries from `functions/_shared/python/` to `lib/`
3. Function can now import: `from lib.clustering import ...`

## Migration Checklist

When updating an existing function to use this pattern:

- [ ] Remove try/except import blocks from function's `lib/__init__.py`
- [ ] Update imports to use `from lib.library_name import ...`
- [ ] Ensure shared library's `__init__.py` exports everything needed
- [ ] Update tests to use `load_function_module`
- [ ] Remove sys.path manipulation from tests
- [ ] Run `make build` before running tests
- [ ] Verify tests pass: `make test-unit`

## Summary

**Simple rule:**

1. Shared libraries export everything through `__init__.py`
2. Functions import directly: `from lib.library_name import X`
3. Tests use `load_function_module`
4. No try/except, no sys.path manipulation

This keeps the codebase clean, consistent, and mirrors the actual Lambda deployment structure.
