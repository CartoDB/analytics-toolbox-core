---
paths:
  - "**/packager*"
  - "**/install*"
  - "dist/**"
---

# Packaging and Installation

## Creating Distribution Packages

```bash
# From root: create unified package (gateway + clouds)
make create-package cloud=redshift

# Production package
make create-package cloud=redshift production=1

# Specific modules only
make create-package cloud=redshift modules=quadbin
```

## Installing Packages (Redshift)

Redshift packages include an interactive installer (`scripts/install.py`) for gateway Lambda functions.

### Deployment Phases

- **Phase 0**: IAM Role Setup (auto-creates Lambda execution + Redshift invoke roles) — if needed
- **Phase 1**: Lambda Deployment (gateway functions)
- **Phase 2**: External Function Creation (SQL wrappers for Lambdas)
- **Phase 3**: Native SQL UDF Deployment (clouds functions)

### Interactive Installation

```bash
cd dist/carto-at-redshift-VERSION
python3 -m venv .venv && source .venv/bin/activate
pip install -r scripts/requirements.txt
python scripts/install.py
```

### Non-Interactive Installation

**IMPORTANT**: The `--non-interactive` flag is **required** to skip all prompts. Without it, the installer will prompt interactively even if all parameters are provided.

```bash
python scripts/install.py \
  --non-interactive \
  --aws-region us-east-1 \
  --aws-access-key-id AKIAXXXX \
  --aws-secret-access-key XXXX \
  --rs-lambda-prefix myprefix- \
  --rs-host cluster.redshift.amazonaws.com \
  --rs-database mydb \
  --rs-user admin \
  --rs-password secret \
  --rs-schema myschema
```

### Other Clouds

BigQuery, Snowflake, Databricks, Oracle, Postgres: use `make deploy` directly — deploys SQL UDFs without Lambda or installer.

## Package Customization (Extra Packager Pattern)

Core's packaging supports extensibility through a **try/except import pattern** that lets external repos (like premium) customize packages without modifying core code.

```python
# Core packager: gateway/logic/clouds/redshift/packager.py
def create_package(...):
    # ... create base package ...
    try:
        from gateway.logic.clouds.redshift.packager import customize_package
        customize_package(package_dir, production, functions)
    except ImportError:
        pass  # No premium packager - core-only package
```

External repos implement `customize_package(package_dir, production, functions)` at the same path.

## Installer Output Styling

- **Phase headers**: plain `logger.info` (no colors) for consistency across phases
- **Deployment banner**: only the main banner uses color (`click.secho` with `fg='cyan'`)
- **Phase list**: don't list phases statically in overview — they vary by configuration
