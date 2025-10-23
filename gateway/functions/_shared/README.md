# Shared Function Libraries

This directory contains shared code libraries used by multiple gateway functions to avoid code duplication.

## Structure

```
_shared/
├── python/
│   ├── placekey/        # Placekey/H3 conversion utilities
│   ├── clustering/      # Shared clustering algorithms (KMeans, etc.)
│   ├── geospatial/      # Common geospatial utilities
│   └── helpers/         # Generic helper functions
├── javascript/          # Future: Shared JS libraries
└── go/                  # Future: Shared Go libraries
```

## Usage in Functions

Functions reference shared libraries during packaging. The packager automatically includes the shared code in the deployment package.

### Method 1: Copy During Packaging (Recommended)

The packager copies shared libraries into the function's deployment package:

**function.yaml:**
```yaml
clouds:
  redshift:
    type: lambda
    code_file: code/lambda/python/handler.py
    shared_libs:
      - placekey  # Copies _shared/python/placekey/* to lib/placekey/
      - clustering  # Copies _shared/python/clustering/* to lib/clustering/
```

**In handler.py:**
```python
from lib.placekey import placekey_to_h3, h3_to_placekey
from lib.clustering import KMeans
```

### Method 2: Direct Import During Development

During local development and testing, functions can import directly from _shared:

**test_utils/unit/python.py** handles this automatically by:
1. Adding _shared/python to sys.path
2. Creating appropriate lib/ namespace mappings

This allows tests to work without duplication while deployment packages remain self-contained.

## Adding a New Shared Library

1. Create the library in `_shared/python/{library_name}/`
2. Add `__init__.py` with public API exports
3. Update function's `function.yaml` with `shared_libs` entry
4. Update packager to handle the `shared_libs` field
5. Update test utilities to handle shared library imports

## Benefits

- **No code duplication**: Single source of truth for shared code
- **Easy updates**: Fix bugs in one place, deploy to all functions
- **Self-contained packages**: Each Lambda package includes all dependencies
- **Clean repository**: No duplicate files in git
- **Testing friendly**: Tests can import directly from shared libraries

## Migration Example

### Before (Duplicated):
```
functions/placekey/placekey_ash3/code/lambda/python/lib/placekey.py      (390 lines)
functions/placekey/placekey_fromh3/code/lambda/python/lib/placekey.py    (390 lines)
functions/placekey/placekey_isvalid/code/lambda/python/lib/placekey.py   (390 lines)
Total: 1,170 lines duplicated
```

### After (Shared):
```
functions/_shared/python/placekey/
  ├── __init__.py
  ├── encoding.py
  ├── validation.py
  └── conversion.py
Total: 390 lines, referenced by 3 functions
```

## Alternative: Shared Layer (Future)

For AWS Lambda, consider using Lambda Layers for truly shared runtime dependencies. This is more complex but offers additional benefits:

- Shared code across multiple functions at runtime
- Reduced package sizes
- Centralized version management

This would require additional deployment infrastructure but could be valuable for large-scale deployments.
