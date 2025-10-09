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
│   │
│   ├── clouds/                         # Cloud-specific implementations
│   │   └── redshift/
│   │       ├── __init__.py
│   │       ├── cli.py                 # CLI for Redshift deployments
│   │       ├── template_renderer.py   # Simple @@VARIABLE@@ template renderer
│   │       ├── installer_generator.py # Generates install.py for distribution packages
│   │       ├── validation/            # Redshift-specific validation
│   │       │   ├── __init__.py
│   │       │   └── pre_flight_checks.py
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

#### Clouds (`logic/clouds/`)
- **redshift/** - Redshift-specific deployment logic
  - `cli.py` - Command-line interface (all config from .env files)
  - `template_renderer.py` - Simple template renderer for SQL generation (@@VARIABLE@@ syntax)
  - `installer_generator.py` - Generates install.py script for distribution packages
  - `validation/` - Pre-flight checks and validation
  - `tests/` - Unit tests for CLI

#### Platforms (`logic/platforms/`)
- **aws-lambda/** - Lambda deployment and runtime
  - `runtime/` - Cloud-agnostic wrapper utilities (ExternalFunctionResponse)
  - `deploy/` - Packaging and deployment to AWS

### Distribution (`dist/`)
- Generated distribution packages for customers
- See `PACKAGE_STRUCTURE.md` for details

## File Count by Type

- Python files: 18 (removed config_loader.py, sql_renderer.py; added template_renderer.py, installer_generator.py)
- YAML files: 3 (removed dev.yaml, prod.yaml)
- Markdown files: 5
- SQL templates: 3 (using @@VARIABLE@@ syntax)
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
make lint              # Lint Python files
make lint-fix          # Auto-fix Python formatting
```

## Key Features

### IAM Role Management
- **IAM Manager** (`logic/platforms/aws-lambda/deploy/iam_manager.py`)
- Auto-creates Redshift invoke role if not provided
- Auto-attaches role to Redshift cluster
- Configures Lambda resource policies
- Supports both same-account and cross-account setups

### SQL File Naming Convention
- Files named by cloud: `redshift.sql`, `bigquery.sql`, etc.
- Uses simple `@@VARIABLE@@` template syntax (e.g., `@@SCHEMA@@`, `@@LAMBDA_ARN@@`, `@@IAM_ROLE_ARN@@`)
- No external dependencies - just string replacement
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
