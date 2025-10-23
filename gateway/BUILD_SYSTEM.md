# Gateway Build System

## Overview

The gateway now uses a **build system** that mirrors the actual Lambda deployment structure. This eliminates the need for try/except import fallbacks and makes testing more reliable.

## Key Changes

### 1. Build Step
- **New command**: `make build`
- Creates `build/` directory with functions that have shared libraries copied into `lib/`
- Mirrors exact deployment structure
- Required before running tests

### 2. Unified Import Pattern
- **Before** (try/except fallback):
  ```python
  try:
      from lib.clustering import KMeans
  except ImportError:
      from clustering import KMeans
  ```

- **After** (direct import):
  ```python
  from lib.clustering import KMeans
  ```

### 3. Test Infrastructure
- Tests now use `build/` directory automatically
- No more `setup_shared_libraries_path()` needed
- Tests see the exact same structure as Lambda

## Usage

### Building Functions
```bash
# Build all functions with shared libraries
make build

# Clean and rebuild
make clean && make build
```

### Running Tests
```bash
# Build is automatic - just run tests
make test-unit

# Test specific module
make test-unit modules=clustering

# Test specific function
venv/bin/python -m pytest functions/clustering/clusterkmeans/tests/unit/ -v
```

### Deploying
```bash
# Build happens automatically during deployment via packager
make deploy cloud=redshift

# Or create distribution package
make create-package cloud=redshift
```

## Directory Structure

```
gateway/
├── functions/                    # Source functions
│   ├── _shared/python/          # Shared libraries
│   │   ├── clustering/
│   │   ├── quadkey/
│   │   └── ...
│   └── clustering/
│       └── clusterkmeans/
│           ├── code/lambda/python/
│           │   ├── handler.py
│           │   └── lib/         # Empty (or has __init__.py)
│           └── tests/
├── build/                        # Built functions (gitignored)
│   └── functions/
│       └── clustering/
│           └── clusterkmeans/
│               ├── code/lambda/python/
│               │   ├── handler.py
│               │   └── lib/     # ✓ Shared libs copied here!
│               │       └── clustering/
│               └── tests/       # Tests copied too
└── tools/
    └── build_functions.py       # Build script
```

## Benefits

✅ **No try/except imports** - Single, clear import pattern
✅ **Tests mirror deployment** - What you test is what deploys
✅ **Simpler for developers** - One way to import shared code
✅ **Build issues caught early** - Before deployment
✅ **Consistent with clouds** - Same pattern as redshift/clouds repo

## Migration Notes

### For Existing Functions
1. Remove try/except import blocks from `lib/__init__.py`
2. Always import from `lib.*`
3. Update tests to use `load_function_module()` with proper `import_spec`

### For New Functions
1. Place shared code in `functions/_shared/python/`
2. Add `shared_libs` to `function.yaml`:
   ```yaml
   clouds:
     redshift:
       shared_libs:
         - clustering
   ```
3. Import directly from `lib.*` in your handler
4. Run `make build` before testing

## Removed Files

- `test_utils/install_test_deps.py` - Replaced by `requirements-dev.txt`
- `setup_shared_libraries_path()` - No longer needed
- Backward compatibility code in `test_utils/unit/python.py`

## Technical Details

### Build Script (`tools/build_functions.py`)
- Scans all functions for `shared_libs` in `function.yaml`
- Copies functions to `build/functions/<module>/<name>/`
- Copies shared libraries from `_shared/python/` to each function's `lib/`
- Preserves test directories for testing

### Test Loader (`test_utils/unit/python.py`)
- `load_function_module()` now uses `build/` directory
- Raises clear error if build doesn't exist
- No fallback to `_shared` - forces proper build workflow

### Makefile Targets
- `build`: Build functions with shared libs
- `test-unit`: Run unit tests (depends on `build`)
- `test-integration`: Run integration tests (depends on `build`)
- `clean`: Remove `build/`, `dist/`, `venv/`

## Troubleshooting

### "Build directory not found"
```bash
# Solution: Run build first
make build
```

### "ModuleNotFoundError: No module named 'clustering'"
```bash
# Solution: Update imports to use lib.*
# Before:
from clustering import KMeans

# After:
from lib.clustering import KMeans
```

### Tests still failing after changes
```bash
# Solution: Rebuild to copy updated source
make clean && make build
```

## Examples

### Test File Pattern
```python
"""Unit tests for CLUSTERKMEANS function"""

import json
import pytest
import numpy as np
from test_utils.unit import load_function_module

# Load function module and shared libs from build/
imports = load_function_module(
    __file__,
    {
        "from_lib": ["clusterkmeans"],
        "from_lib_module": {
            "clustering": ["KMeans"],
            "clustering.helper": ["reorder_coords"],
        },
    },
)

clusterkmeans = imports["clusterkmeans"]
lambda_handler = imports["lambda_handler"]
KMeans = imports["KMeans"]
reorder_coords = imports["reorder_coords"]

class TestKMeans:
    def test_simple_clustering(self):
        # Test uses KMeans from build/
        ...
```

### Function Handler Pattern
```python
"""
CLUSTERKMEANS function implementation using shared clustering utilities.

This module imports shared clustering utilities from lib/clustering/
which is populated during the build step from functions/_shared/python/clustering/
"""

import json
import numpy as np

# Import from lib/clustering (copied during build/deploy)
from lib.clustering import KMeans
from lib.clustering.helper import (
    load_geom,
    reorder_coords,
    count_distinct_coords,
)

def clusterkmeans(geom_json, k):
    # Implementation using shared utilities
    ...
```

### function.yaml Pattern
```yaml
name: clusterkmeans
module: clustering
clouds:
  redshift:
    shared_libs:
      - clustering  # Copies _shared/python/clustering/* to lib/clustering/
    config:
      memory_size: 1024
      timeout: 300
```
