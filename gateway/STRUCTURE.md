# Gateway Directory Structure

Complete structure of the Analytics Toolbox Gateway for Lambda function deployment.

## Overview

36 files created across the following structure:

```
gateway/
├── .gitignore                          # Git ignore patterns
├── Makefile                            # Build and deployment commands
├── README.md                           # Main documentation
├── requirements.txt                    # Python dependencies
├── requirements-dev.txt                # Development dependencies
├── STRUCTURE.md                        # This file
├── .env.template                       # Environment configuration template
│
├── common/                             # Gateway-specific configurations
│   ├── redshift/.sqlfluff              # SQL linting config for Redshift
│   ├── bigquery/.sqlfluff              # SQL linting config for BigQuery
│   ├── snowflake/.sqlfluff             # SQL linting config for Snowflake
│   ├── databricks/.sqlfluff            # SQL linting config for Databricks
│   └── postgres/.sqlfluff              # SQL linting config for Postgres
│
├── functions/                          # Function definitions by module
│   └── quadbin/                        # Module: spatial indexing
│       └── quadbin_polyfill/           # Example function
│           ├── function.yaml           # Function metadata and config
│           ├── README.md               # Function documentation
│           ├── code/
│           │   ├── lambda/python/
│           │   │   ├── handler.py      # Lambda implementation
│           │   │   └── requirements.txt
│           │   └── redshift.sql  # SQL template
│           └── tests/
│               ├── unit/
│               │   ├── cases.yaml      # Declarative test cases
│               │   └── test_quadbin_polyfill.py  # Complex tests
│               └── integration/
│                   └── test_quadbin_polyfill.py  # Integration tests
│
├── logic/                              # Core engine and deployment
│   ├── common/                         # Shared utilities
│   │   ├── engine/
│   │   │   ├── __init__.py
│   │   │   ├── models.py              # Data models (Function, etc.)
│   │   │   ├── validator.py           # YAML validation logic
│   │   │   ├── catalog_loader.py      # Function discovery
│   │   │   └── packager.py            # Distribution package generation
│   │   ├── schemas/
│   │   │   └── function.schema.json   # JSON schema for validation
│   │   ├── utils/
│   │   │   ├── __init__.py
│   │   │   ├── logging.py             # Logging utilities
│   │   │   └── paths.py               # Path helpers
│   │   └── sql_macros/
│   │       └── geometry.j2            # Jinja2 SQL macros
│   │
│   ├── clouds/                         # Cloud-specific implementations
│   │   └── redshift/
│   │       ├── __init__.py
│   │       ├── cli.py                 # CLI for Redshift deployments
│   │       └── tests/unit/
│   │           └── test_cli.py
│   │
│   └── platforms/                      # Platform-specific code
│       └── aws-lambda/
│           ├── __init__.py
│           ├── runtime/               # Lambda wrapper utilities
│           │   ├── __init__.py
│           │   └── lambda_wrapper.py  # Response formatting, decorators
│           ├── deploy/                # Deployment tools
│           │   ├── __init__.py
│           │   ├── deployer.py        # Lambda packaging & deployment
│           │   └── iam_manager.py     # IAM role management for Redshift
│           └── tests/unit/
│               └── test_lambda_wrapper.py
│
└── dist/                               # Distribution packages (generated)
    ├── .gitkeep
    └── PACKAGE_STRUCTURE.md            # Documentation for dist packages
```

## Key Components

### Functions (`functions/`)
- Organized by **module** (e.g., `quadbin/`, `h3/`, `tiler/`)
- Each function has:
  - `function.yaml` - Metadata (no inline code)
  - `code/` - Implementation files (Python, SQL templates)
  - `tests/` - Unit and integration tests
  - `README.md` - Documentation

### Logic (`logic/`)

#### Common (`logic/common/`)
- **engine/** - Core data models and catalog management
  - `models.py` - Function, CloudConfig, etc.
  - `catalog_loader.py` - Discovers and loads functions
  - `validator.py` - Validates function.yaml files
  - `packager.py` - Generates customer-installable distribution packages
- **schemas/** - JSON schemas for validation
- **utils/** - Logging, path utilities
- **sql_macros/** - Reusable Jinja2 templates

#### Clouds (`logic/clouds/`)
- **redshift/** - Redshift-specific deployment logic
  - `cli.py` - Command-line interface (all config from .env files)
  - `tests/` - Unit tests for CLI

#### Platforms (`logic/platforms/`)
- **aws-lambda/** - Lambda deployment and runtime
  - `runtime/` - Wrapper utilities for Redshift response format
  - `deploy/` - Packaging and deployment to AWS

### Distribution (`dist/`)
- Generated distribution packages for customers
- See `PACKAGE_STRUCTURE.md` for details

## File Count by Type

- Python files: 17 (removed config_loader.py)
- YAML files: 3 (removed dev.yaml, prod.yaml)
- Markdown files: 5
- SQL/Jinja2 templates: 3
- JSON schema: 1
- Text files: 3
- Makefile: 1

## Usage

### Validate all functions
```bash
make validate
```

### List functions
```bash
make list
```

### Deploy to development
```bash
make deploy-redshift-dev
```

### Deploy single function
```bash
make deploy-function FUNCTION=quadbin_polyfill
```

### Create distribution package
```bash
make package-redshift VERSION=1.0.0
```

### Run tests
```bash
make test
make test-integration
make test-all
```

### Lint code
```bash
make lint              # Lint Python and SQL files
make lint-fix          # Auto-fix Python and SQL formatting
```

## Key Features

### SQL Linting with sqlfluff
- Per-cloud `.sqlfluff` configurations in `common/{cloud}/`
- Based on cloud-specific SQL dialects
- Jinja2 template support for external function SQL
- Automatic linting of `{cloud}.sql` files (e.g., `redshift.sql`)

### IAM Role Management
- **IAM Manager** (`logic/platforms/aws-lambda/deploy/iam_manager.py`)
- Auto-creates Redshift invoke role if not provided
- Auto-attaches role to Redshift cluster
- Configures Lambda resource policies
- Supports both same-account and cross-account setups

### SQL File Naming Convention
- Files named by cloud: `redshift.sql`, `bigquery.sql`, etc.
- Contains Jinja2 templates with variables: `schema`, `lambda_arn`, `iam_role_arn`
- Copyright headers included

## Adding New Functions

1. Create directory: `functions/<module>/<function_name>/`
2. Add `function.yaml` with metadata
3. Implement in `code/lambda/python/handler.py`
4. Add SQL template in `code/redshift.sql`
5. Write tests in `tests/unit/` and `tests/integration/`
6. Run `make validate` and `make test`

## Next Steps

1. **Expand function library**:
   - Add more Analytics Toolbox functions
   - Implement comprehensive test coverage
   - Add integration tests for all functions

2. **Migrate existing functions**:
   - Convert existing Redshift Python UDFs to Lambda format
   - Create function.yaml for each
   - Organize into modules

3. **Extend to other clouds**:
   - Add `logic/clouds/bigquery/` for Cloud Run
   - Add `logic/clouds/snowflake/` for Snowpark
   - Reuse common engine and models

4. **CI/CD Integration**:
   - Add GitHub Actions workflows
   - Implement incremental deployment
   - Add automatic testing

5. **Documentation**:
   - Create detailed installation guide
   - Add troubleshooting guide
   - Document IAM permissions required
