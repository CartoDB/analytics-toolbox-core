# Gateway Tools

This directory contains automation tools for the Analytics Toolbox Gateway.

## Dependency Management

The gateway uses a **minimal requirements strategy** to keep development dependencies clean and scalable.

### Architecture

- **`requirements.txt`**: Core gateway dependencies (CLI, AWS SDK, YAML, etc.) and shared function libraries (numpy, packaging)
- **`requirements-dev.txt`**: Development tools only (pytest, black, flake8, mypy, type stubs)
- **Function-specific `requirements.txt`**: Each function declares its own runtime dependencies

### Why This Approach?

This architecture provides several benefits:

1. **Clean separation**: Development tools vs runtime dependencies are clearly separated
2. **Scalability**: Don't need to consolidate 100+ function dependencies into one file
3. **On-demand installation**: Only install dependencies for functions you're testing
4. **Flexibility**: Easy to filter by cloud, module, or specific functions
5. **Conflict detection**: Automatically detects and fails on version conflicts

### Tools

#### `install_function_deps.py`

Scans function directories and installs their dependencies on-demand for testing.

**Usage:**
```bash
# Install dependencies for all Redshift functions
python tools/install_function_deps.py --cloud redshift

# Install dependencies for specific modules
python tools/install_function_deps.py --cloud redshift --modules clustering,quadbin

# Install dependencies for specific functions
python tools/install_function_deps.py --cloud redshift --functions clusterkmeans,quadbin_fromlonglat

# Include additional function directories (for private gateway)
python tools/install_function_deps.py --cloud redshift --include-root /path/to/extra/functions

# Or use Make (automatically called by make build and make test)
make install-function-deps cloud=redshift
make install-function-deps cloud=redshift modules=clustering
```

**Features:**
- **Conflict detection**: Fails immediately if functions have incompatible versions (testing-only restriction)
- **Cloud-aware**: Only installs dependencies for functions that support the target cloud
- **Module/function filtering**: Install only what you need
- **Multi-repo support**: Can scan multiple function directories (core + private)

**Important: Conflict Detection is for Testing Only**

Each Lambda function is **completely isolated at deployment**:
- Each function gets its own package with only its declared dependencies
- Functions can have different versions of the same library
- No dependency sharing between Lambda functions

**However**, during local testing, all tests run in one Python environment. We cannot have both `numpy==1.24.3` and `numpy==1.26.4` installed simultaneously. Therefore, the script detects conflicts and requires you to standardize versions **for testing purposes only**.

Example: If `statistics/morans_i` uses `numpy==1.26.4` but doesn't use `mercantile`, its Lambda package will contain:
- ✅ `numpy==1.26.4`
- ✅ `quadbin==0.2.2`
- ❌ `mercantile` (not included - not in its requirements.txt)

**Version conflict detection:**

When the script detects incompatible versions, it fails with a clear error:

```
❌ Version conflicts detected in function requirements:

  Package: numpy
    numpy==1.26.4
      - clustering/clusterkmeans
      - processing/delaunaygeneric
    numpy==1.24.3
      - transformations/st_greatcircle

Please update the function requirements files to use consistent versions.
All functions should use the same version for each package.
```

This ensures consistency and prevents silent issues at runtime.

#### `build_functions.py`

Builds Lambda deployment packages with proper directory structure and shared libraries.

**Usage:**
```bash
# Build all functions for Redshift
python tools/build_functions.py --cloud redshift

# Build specific modules
python tools/build_functions.py --cloud redshift --modules clustering,quadbin

# Include additional function directories
python tools/build_functions.py --cloud redshift --include-root /path/to/extra/functions

# Or use Make
make build cloud=redshift
make build cloud=redshift modules=clustering
```

**Features:**
- Copies function code to build directory
- Installs function-specific dependencies
- Includes shared libraries from `functions/_shared/python/`
- Creates proper package structure for Lambda deployment

### Workflow

#### Adding a New Function

1. Create function with its own `requirements.txt`:
   ```
   functions/module/function_name/code/lambda/python/requirements.txt
   ```

2. Ensure the version matches other functions:
   ```bash
   # Check for similar dependencies
   grep -r "numpy" functions/*/code/lambda/python/requirements.txt
   ```

3. Run tests (dependencies installed automatically):
   ```bash
   make test cloud=redshift
   ```

**No manual editing of requirements-dev.txt needed!**

#### Resolving Version Conflicts

When you get a conflict error:

```
❌ Version conflicts detected in function requirements:

  Package: numpy
    numpy==1.26.4
      - clustering/clusterkmeans
      - processing/delaunaygeneric
    numpy==1.24.3
      - transformations/st_greatcircle
```

**Resolution steps:**

1. Find the conflicting requirements files shown in the error
2. Update them to use the same version (typically the highest compatible version)
3. Re-run tests to verify

**Example fix:**

```bash
# Update the outdated version
echo "numpy==1.26.4" > functions/transformations/st_greatcircle/code/lambda/python/requirements.txt

# Or if one has no version, add it
echo "numpy==1.26.4" > functions/quadbin/quadbin_toquadkey/code/lambda/python/requirements.txt

# Verify fix
make test cloud=redshift
```

#### CI/CD Integration

**Standard approach (recommended):**
```yaml
- name: Install dependencies
  run: |
    pip install -r requirements.txt
    pip install -r requirements-dev.txt

- name: Run tests
  run: make test cloud=redshift
```

The `make test` target automatically:
1. Creates/activates virtual environment
2. Installs function dependencies via `install_function_deps.py`
3. Builds functions
4. Runs unit tests

**Manual control (advanced):**
```yaml
- name: Install dependencies
  run: |
    pip install -r requirements.txt
    pip install -r requirements-dev.txt
    python tools/install_function_deps.py --cloud redshift --modules clustering

- name: Run tests
  run: pytest functions/clustering/ -m "not integration"
```

### Best Practices

1. **Use consistent versions** across all functions for the same package
2. **Pin exact versions** for runtime dependencies (e.g., `numpy==1.26.4` not `numpy>=1.26`)
3. **Let Make handle installation** - `make build` and `make test` automatically install function deps
4. **Check for conflicts early** - the script fails fast if versions don't match
5. **Use filtering** when working on specific modules: `make test cloud=redshift modules=clustering`

### Troubleshooting

**Problem: Tests failing with import errors**

```bash
# Clean and rebuild
make clean
make test cloud=redshift
```

**Problem: Version conflict errors**

See "Resolving Version Conflicts" above. The error message shows exactly which files to update.

**Problem: New function not detected**

Ensure:
1. Function has `function.yaml` with `clouds:` section
2. Requirements file is at `functions/module/name/code/lambda/python/requirements.txt`
3. Not inside a `tests/` directory

**Problem: Packaging library not found**

```bash
# Install packaging (needed for conflict detection)
pip install packaging>=21.0
```

### Implementation Details

**How `install_function_deps.py` works:**

1. Scans `functions/` directory for all `requirements.txt` files
2. Skips test requirements (paths containing `tests/`)
3. Parses `function.yaml` to determine cloud support
4. Filters based on --cloud, --modules, --functions arguments
5. **Checks for version conflicts** (fails if found)
6. Consolidates all requirements and installs in one pip call
7. Shows clear progress and error messages

**Key difference from old approach:**

- Old: Consolidated all deps into `requirements-dev.txt` (became huge and hard to maintain)
- New: Minimal `requirements-dev.txt` with only dev tools, function deps installed on-demand

**Conflict detection:**

Uses the `packaging` library to parse requirement specifications and detect when multiple functions require different versions of the same package. This prevents subtle runtime issues and forces consistency.

### Migration Notes

If you're coming from the old `generate_dev_requirements.py` approach:

**What changed:**
- `requirements-dev.txt` is now minimal (only dev tools, no function deps)
- Function dependencies installed automatically by Make targets
- Conflicts cause immediate failure instead of warnings
- No need to regenerate `requirements-dev.txt` after adding functions

**Benefits:**
- Faster setup (don't install deps for functions you're not testing)
- Clearer separation between dev tools and runtime deps
- Scales better as function count grows
- Catches version conflicts early
