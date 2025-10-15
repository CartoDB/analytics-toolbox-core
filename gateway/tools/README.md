# Gateway Tools

This directory contains automation tools for the Analytics Toolbox Gateway.

## Dependency Management

The gateway uses an automated approach to managing function dependencies for testing:

### Architecture

- **`requirements.txt`**: Core gateway dependencies only (CLI, AWS SDK, etc.)
- **`requirements-dev.txt`**: Auto-generated file with all function dependencies needed for testing
- **Function-specific `requirements.txt`**: Each function has its own requirements for Lambda deployment

### Why This Approach?

This architecture solves several problems:

1. **Cloud-agnostic**: Each cloud can have different function implementations with different dependencies
2. **Zero maintenance**: New functions automatically discovered, no manual updates needed
3. **Conflict detection**: Automatically warns about version conflicts between functions
4. **Clean separation**: Core dependencies vs function dependencies are clearly separated
5. **No dependency bloat**: Each Lambda only gets the dependencies it needs

### Tools

#### `generate_dev_requirements.py`

Scans all function directories and consolidates their requirements into `requirements-dev.txt`.

**Usage:**
```bash
# Generate requirements-dev.txt for all clouds
python tools/generate_dev_requirements.py

# Generate requirements-dev.txt for a specific cloud
python tools/generate_dev_requirements.py --cloud redshift

# Or use Make
make update-dev-requirements
make update-dev-requirements cloud=bigquery
```

**Output example:**
```
# Function dependencies needed for unit testing
# These allow tests to import function code without installing each function's requirements
geojson==3.1.0  # Used by: bezierspline, clusterkmeans, delaunaygeneric (redshift)
numpy>=1.24.0,<2.0.0  # Used by: clusterkmeans, delaunaygeneric, voronoigeneric (redshift)
scipy==1.11.4  # Used by: delaunaygeneric, voronoigeneric (redshift)
```

**Features:**
- Detects and warns about version conflicts
- Shows which functions use each dependency
- Cloud-aware (shows which clouds each function supports)
- Preserves version constraints from original requirements

#### `install_test_deps.py`

Dynamically installs function dependencies for a specific cloud platform.

**Usage:**
```bash
# Install all Redshift function dependencies
python test_utils/install_test_deps.py --cloud redshift

# Install to a specific directory (useful for packaging)
python test_utils/install_test_deps.py --cloud redshift --target ./lib

# Dry run (see what would be installed)
python test_utils/install_test_deps.py --cloud redshift --dry-run

# Or use Make
make install-test-deps
make install-test-deps cloud=bigquery
```

**Use cases:**
- CI/CD environments where you only want dependencies for one cloud
- Creating distribution packages
- Isolating test environments

### Workflow

#### Adding a New Function

1. Create function with its own `requirements.txt` in `functions/module/function_name/code/lambda/python/requirements.txt`
2. Run `make update-dev-requirements` to regenerate `requirements-dev.txt`
3. Run `make install-dev` to install updated dependencies
4. Run tests: `make test-unit`

**No manual editing of `requirements-dev.txt` needed!**

#### Resolving Version Conflicts

When the generator detects a conflict:

```
# WARNING: Version conflict for numpy: {'==1.26.4', '>=1.24.0,<2.0.0'}
# numpy  # Used by: clusterkmeans, delaunaygeneric (redshift)
numpy  # CONFLICT - manual resolution needed
```

**Resolution steps:**

1. Find the conflicting requirements files
2. Standardize on a compatible version range
3. Re-run `make update-dev-requirements`

**Example fix:**

```bash
# Before (conflict)
functions/clustering/clusterkmeans/.../requirements.txt:  numpy>=1.24.0,<2.0.0
functions/processing/delaunaygeneric/.../requirements.txt: numpy==1.26.4

# After (resolved)
functions/clustering/clusterkmeans/.../requirements.txt:  numpy>=1.24.0,<2.0.0
functions/processing/delaunaygeneric/.../requirements.txt: numpy>=1.24.0,<2.0.0
```

#### CI/CD Integration

**Option 1: Use requirements-dev.txt (standard, fast)**
```yaml
- name: Install dependencies
  run: |
    pip install -r requirements-dev.txt
    pytest functions/ -m "not integration"
```

**Option 2: Use dynamic discovery (cloud-specific)**
```yaml
- name: Install Redshift function dependencies
  run: |
    pip install -r requirements.txt
    python test_utils/install_test_deps.py --cloud redshift
    pytest functions/ -m "not integration"
```

### Best Practices

1. **Don't manually edit `requirements-dev.txt`** - it's auto-generated
2. **Use version ranges** in function requirements when possible (e.g., `>=1.24.0,<2.0.0` not `==1.26.4`)
3. **Run `make update-dev-requirements`** after adding/modifying functions
4. **Check for conflicts** - the generator will warn you
5. **Commit both** the function requirements and updated requirements-dev.txt

### Troubleshooting

**Problem: Tests failing with import errors**

```bash
# Regenerate and reinstall dependencies
make update-dev-requirements
make install-dev
```

**Problem: Version conflict warnings**

See "Resolving Version Conflicts" above.

**Problem: New function not detected**

Ensure:
1. Function has `function.yaml` with `clouds:` section
2. Requirements file is at `functions/module/name/code/lambda/python/requirements.txt`
3. Not inside a `tests/` directory

**Problem: Dependencies not installing in CI**

Ensure CI workflow installs from `requirements-dev.txt` or uses `install_test_deps.py`.

### Implementation Details

**How `generate_dev_requirements.py` works:**

1. Scans `functions/` directory for all `requirements.txt` files
2. Skips test requirements (paths containing `tests/`)
3. Parses `function.yaml` to determine cloud support
4. Consolidates all requirements with version tracking
5. Detects conflicts (multiple different versions of same package)
6. Generates formatted output with documentation

**How `install_test_deps.py` works:**

1. Scans `functions/` directory for all `requirements.txt` files
2. Parses each `function.yaml` to check cloud support
3. Filters to only functions supporting the target cloud
4. Installs each requirements file using pip

### Future Enhancements

Possible improvements:

- Pre-commit hook to auto-regenerate `requirements-dev.txt`
- Automated conflict resolution with semantic versioning
- Dependency graph visualization
- Per-module test dependency subsets
- Integration with dependency security scanning
