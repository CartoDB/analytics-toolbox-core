---
paths:
  - ".github/**"
---

# CI/CD

## CI Naming

For CI/CD environments, use short prefixes to avoid AWS naming limits:
- Pattern: `ci_{8-char-sha}_{6-digit-run-id}_`
- Example: `ci_a1b2c3d4_123456_getisord`
- Total length: <=64 characters

## Workflows

Each cloud has its own CI/CD workflows in `.github/workflows/`:

| Cloud | Main Workflow | Dedicated Env |
|-------|--------------|---------------|
| BigQuery | `bigquery.yml` | `bigquery-ded.yml` |
| Snowflake | `snowflake.yml` | `snowflake-ded.yml` |
| Redshift | `redshift.yml` | `redshift-ded.yml` |
| Databricks | `databricks.yml` | - |
| Postgres | `postgres.yml` | `postgres-ded.yml` |
| Oracle | `oracle.yml` | `oracle-ded.yml` |

- **Main workflows**: Triggered on PRs and pushes to main. Run lint, deploy to CI env, test, cleanup.
- **Dedicated (`-ded`) workflows**: PR-triggered, deploy to isolated environment for testing.
- **Publish**: Triggered by `publish-release.yml` on push to `stable`. Creates GitHub Release, publishes packages to GCS, deploys to production.

## Diff Parameter Handling in Makefiles

When passing file lists through Make targets, **proper quoting is critical** to prevent Make from interpreting space-separated filenames as multiple targets.

### Problem

```makefile
# WRONG - Each filename becomes a separate target
$(if $(diff),diff=$(diff),)

# If diff=".github/workflows/redshift.yml Makefile README.md"
# Make interprets this as three separate targets and fails with:
# make: *** No rule to make target '.github/workflows/redshift.yml'
```

### Solution

```makefile
# CORRECT - Entire string passed as single quoted value
$(if $(diff),diff='$(diff)',)

# Properly passes: diff='.github/workflows/redshift.yml Makefile README.md'
```

### Where This Matters

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

### Architecture Flow

```
CI Workflow / External Caller
  | diff="file1 file2 file3"
Core Root Makefile
  | diff='$(diff)' (quoted!)
Gateway Makefile
  | --diff (flag only)
Python CLI (gateway/logic/clouds/redshift/cli.py)
  | reads $GIT_DIFF from environment
  | detects infrastructure changes
  | decides: deploy ALL or deploy CHANGED
```

### Infrastructure Change Detection

The Python CLI automatically detects infrastructure changes and deploys all functions when these paths are modified:
- `.github/workflows/` - CI/CD configuration
- `Makefile` - Build system changes
- `logic/` - Deployment logic changes
- `platforms/` - Platform code changes
- `requirements.txt` - Dependency changes

### Key Points

- Root Makefile must quote: `diff='$(diff)'`
- Gateway Makefile uses flag: `--diff` (no value)
- Python CLI reads `$GIT_DIFF` environment variable directly
- Infrastructure files trigger full deployment automatically
- Clouds Makefiles don't use diff (always deploy all SQL UDFs)
