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
  - `tests/` - Tests for platform code

### Testing

Function tests are located in `functions/<module>/<function>/tests/`:
- **Unit tests** (`tests/unit/`) - Test business logic
- **Integration tests** (`tests/integration/`) - End-to-end validation with actual cloud

Example: `functions/quadbin/quadbin_polyfill/tests/unit/test_quadbin_polyfill.py`

### Distribution (`dist/`)
- Generated distribution packages for customers
- **Unified Packages**: Combine gateway (Lambda) + clouds (SQL UDFs)
- See `PACKAGE_STRUCTURE.md` for details

### Scripts (`scripts/`)
- **add_clouds_sql.py** - Filters and adds clouds SQL to gateway packages
  - Supports module and function filtering at build time
  - Can append SQL functions from multiple sources
  - Copies additional SQL files (VERSION.sql, DROP_FUNCTIONS.sql)

## File Count by Type

- Python files: 18 (removed config_loader.py, sql_renderer.py; added template_renderer.py, installer_generator.py)
- YAML files: 3 (removed dev.yaml, prod.yaml)
- Markdown files: 5
- SQL templates: 3 (using @@VARIABLE@@ syntax)
- JSON schema: 1
- Text files: 3
- Makefile: 1

## Usage

**RECOMMENDED: Work from repository root** for all operations. The root Makefile provides unified commands that deploy both gateway (Lambda functions) and clouds (SQL UDFs) together.

### From Repository Root (Recommended)

```bash
# Deploy everything (gateway + clouds)
make deploy cloud=redshift

# Run all tests (gateway + clouds)
make test cloud=redshift

# Lint all code (gateway + clouds)
make lint cloud=redshift

# List available functions
make list cloud=redshift

# Validate function definitions
make validate cloud=redshift

# Create unified distribution package
make create-package cloud=redshift
make create-package cloud=redshift modules=quadbin      # Filter by module
make create-package cloud=redshift production=1         # Production package

# Remove everything
make remove cloud=redshift

# Clean build artifacts
make clean cloud=redshift

# Show help
make help
```

### From Gateway Directory (Advanced)

For gateway-specific operations only:

```bash
cd gateway

# Gateway-only operations
make lint cloud=redshift
make test-unit cloud=redshift
make validate cloud=redshift
make deploy cloud=redshift
make remove cloud=redshift

# Create gateway-only package (without clouds SQL)
make create-package cloud=redshift
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

## Unified Package System

### Overview
The repository supports creating **unified distribution packages** that combine:
- **Gateway functions** (Lambda-based external functions)
- **Clouds SQL** (native SQL UDFs from `modules.sql`)

### Build-Time vs Install-Time
- **Build-time filtering**: Packages are pre-filtered when created using `make create-package`
- **Install-time simplicity**: Installer deploys everything in the package (no filtering logic)

### Package Creation Flow
1. **Step 1**: Create gateway package (Lambda functions)
2. **Step 2**: Add clouds SQL from `clouds/redshift/modules/build/modules.sql` (optional filtering)
3. **Step 3**: Create final ZIP archive

### Package Structure
```
carto-at-redshift-1.0.0/
├── README.md           # Installation instructions
├── functions/          # Function definitions
├── logic/              # Deployment logic
├── scripts/            # Installation scripts
│   └── install.py     # 3-phase installer
└── clouds/             # Native SQL UDFs
    └── redshift/
        ├── modules.sql         # Filtered SQL functions
        ├── VERSION.sql         # Version info
        └── DROP_FUNCTIONS.sql  # Cleanup script
```

### Installation Phases
The installer (`scripts/install.py`) deploys in 3 phases:
1. **Phase 1**: Deploy Lambda functions (gateway)
2. **Phase 2**: Create external functions (SQL templates)
3. **Phase 3**: Execute modules.sql (native SQL UDFs)

### Repository Independence
- Functions can be organized across multiple repositories
- Submodule pattern supports extending base functionality

### CI/CD Integration
GitHub Actions workflows updated to:
- Test both gateway and clouds
- Deploy both gateway and clouds
- Create unified packages for releases

See `.github/workflows/redshift.yml` and `.github/workflows/redshift-ded.yml`

## Versioning Strategy

### Cloud-Specific Versioning
Each cloud platform maintains its own independent version in `clouds/<cloud>/version`:

```
clouds/
├── redshift/version      # 1.1.3
├── bigquery/version      # 1.0.0
├── snowflake/version     # 1.0.0
├── databricks/version    # 1.0.0
└── postgres/version      # 1.0.0
```

### Why Cloud-Specific Versions?
- **Independent Release Cycles**: Each cloud can have different features and release schedules
- **Cloud-Specific Changelogs**: Each cloud maintains its own CHANGELOG with relevant changes
- **Flexibility**: Allows for cloud-specific hotfixes without affecting other platforms
- **Clarity**: Version numbers directly reflect what's deployed on each platform

### Version File Format
- Simple text file containing the version number (e.g., `1.1.3`)
- No additional formatting or metadata
- Read automatically by Makefiles during package creation

### Package Creation with Versions
When creating a package, the version is automatically read from the cloud-specific version file:

```bash
# Version is read from clouds/redshift/version
make create-package cloud=redshift

# Creates: dist/carto-at-redshift-1.1.3.zip
```

### Migration from Root VERSION Files
The root-level `VERSION` files have been removed from both repositories. All versioning is now managed through cloud-specific version files in `clouds/<cloud>/version`.

## Related Documentation

- **[README.md](README.md)** - Main gateway documentation with setup and usage instructions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Platform-agnostic architecture guide, design principles, and expandability
- **[CREDENTIAL_SETUP_GUIDE.md](CREDENTIAL_SETUP_GUIDE.md)** - AWS credential configuration guide

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
