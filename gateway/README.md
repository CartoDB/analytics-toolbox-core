# CARTO Analytics Toolbox Gateway

This directory contains the infrastructure for deploying Analytics Toolbox functions as Lambda functions in AWS Redshift (and potentially other clouds in the future).

## Overview

The Gateway system allows Analytics Toolbox functions to be deployed as:
- **AWS Lambda functions** for Redshift external functions
- **Cloud Run functions** for BigQuery (future)
- **Snowpark UDFs** for Snowflake (future)

## Directory Structure

```
gateway/
├── functions/              # Function definitions organized by module
│   └── quadbin/
│       └── quadbin_polyfill/
│           ├── function.yaml              # Function metadata
│           ├── README.md                  # Documentation
│           ├── code/
│           │   ├── lambda/python/
│           │   │   ├── handler.py         # Lambda implementation
│           │   │   └── requirements.txt   # Python dependencies
│           │   └── redshift.sql  # SQL template
│           └── tests/
│               ├── unit/
│               │   ├── cases.yaml         # Simple test cases
│               │   └── test_*.py          # Complex test scenarios
│               └── integration/
│                   └── test_*.py          # Integration tests
│
├── logic/                  # Core engine and deployment logic
│   ├── common/             # Shared utilities
│   │   ├── engine/         # Core models, validation, catalog
│   │   ├── schemas/        # JSON schemas for validation
│   │   ├── utils/          # Logging, path utilities
│   │   └── sql_macros/     # Jinja2 SQL templates
│   ├── clouds/             # Cloud-specific logic
│   │   └── redshift/
│   │       ├── cli.py      # CLI for Redshift deployments
│   │       ├── configs/    # Environment configurations
│   │       └── sql/        # SQL templates
│   └── platforms/          # Platform-specific code
│       └── aws-lambda/
│           ├── runtime/    # Lambda wrapper utilities
│           └── deploy/     # Deployment tools
│
└── dist/                   # Distribution packages (generated)
```

## Quick Start

### Prerequisites

1. Python 3.10+ (tested with Python 3.10-3.13)
2. AWS credentials with Lambda permissions (see Required AWS Permissions below)
3. Access to a Redshift cluster (for external function deployment)

### Setup

```bash
# Create virtual environment and install dependencies
make venv

# Install development dependencies (for linting/testing)
# This happens automatically when running make lint or make test
```

### Configuration

The gateway can use a shared `.env` file from the core directory (same as clouds) or a gateway-specific one:

**Option 1: Shared .env (recommended for consistency with clouds)**

```bash
# Create .env in the core directory (shared with clouds)
cd ..
cp gateway/.env.template .env
```

**Option 2: Gateway-specific .env**

```bash
# Create .env in the gateway directory only
cp .env.template .env
```

The gateway will:
1. Load `.env` from core directory first (if exists)
2. Then load `.env` from gateway directory (if exists) to override specific values

Edit `.env` with your AWS and Redshift configuration.

#### AWS Credential Configuration

The gateway supports multiple authentication methods. Choose the one that fits your setup:

**Method 1: AWS Profile (Recommended)**
```bash
AWS_PROFILE=default
AWS_REGION=us-east-1
```
This uses credentials from `~/.aws/credentials`. Most secure and convenient for local development.

**Method 2: Explicit Credentials (CI/CD)**
```bash
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<access-key-id>
AWS_SECRET_ACCESS_KEY=<secret-access-key>
# Optional for temporary credentials:
# AWS_SESSION_TOKEN=<session-token>
```
Useful for CI/CD pipelines or when AWS CLI profiles aren't available.

**Method 3: Assume Role (Cross-Account)**
```bash
AWS_PROFILE=default  # or use access keys
AWS_REGION=us-east-1
AWS_ASSUME_ROLE_ARN=arn:aws:iam::123456789:role/DeployerRole
```
Assumes an IAM role, useful for cross-account deployments or temporary elevated permissions.

**Method 4: IAM Role (EC2/ECS/Lambda)**

No configuration needed. When running on AWS infrastructure (EC2, ECS, Lambda), the SDK automatically discovers and uses the attached IAM role.

**Method 5: AWS SSO (Enterprise)**
```bash
# First authenticate:
aws sso login --profile my-sso-profile

# Then set in .env:
AWS_PROFILE=my-sso-profile
AWS_REGION=us-east-1
```
Best for enterprise environments using AWS IAM Identity Center.

#### Lambda Configuration

```bash
# LAMBDA_PREFIX: Prefix for Lambda function names (default: carto-at-)
LAMBDA_PREFIX=carto-at-
```

**Resource Naming:**
- Lambda functions: `{LAMBDA_PREFIX}{function_name}` (kebab-case)
  - Example: `carto-at-quadbin_polyfill`
- IAM execution role: `{PascalCase(LAMBDA_PREFIX)}LambdaExecutionRole` (PascalCase, AWS convention)
  - `LAMBDA_PREFIX=carto-at-` → `CartoATLambdaExecutionRole`
  - `LAMBDA_PREFIX=dev-carto-at-` → `DevCartoATLambdaExecutionRole`
  - Note: 'at' is preserved as 'AT' (acronym for Analytics Toolbox)
- Session name: `{LAMBDA_PREFIX}deployer` with underscores
  - Example: `carto_at_deployer`

**Lambda Execution Role (optional - recommended for production)**

If not specified, will auto-create based on `LAMBDA_PREFIX` (default: `CartoATLambdaExecutionRole`)

To avoid needing IAM create role permissions, pre-create this role:
```bash
LAMBDA_EXECUTION_ROLE_ARN=arn:aws:iam::<account-id>:role/CartoATLambdaExecutionRole
```

#### Redshift Configuration

```bash
# RS_PREFIX: Prefix for development schemas/libraries
#   - Dev mode (default): schema = "{RS_PREFIX}carto" (e.g., "myname_carto")
#   - Prod mode (production=1): schema = "carto" (no prefix)
RS_PREFIX=myname_
RS_DATABASE=<database>

# Redshift Connection (choose one method)
# Method 1: Direct Connection (recommended)
RS_HOST=<cluster>.<account>.<region>.redshift.amazonaws.com
RS_USER=<user>
RS_PASSWORD=<password>

# Method 2: Data API (alternative)
# RS_CLUSTER_IDENTIFIER=<cluster-id>
# RS_USER=<iam-user>
# # OR
# # RS_SECRET_ARN=arn:aws:secretsmanager:<region>:<account>:secret:<secret-name>

# IAM Role(s) for Redshift to invoke Lambda (matches clouds RS_ROLES)
# This role must be attached to your Redshift cluster
RS_ROLES=arn:aws:iam::<account-id>:role/<role-name>
```

**Testing Your Credentials:**

After configuring your credentials, you can test them:

```bash
venv/bin/python scripts/test_credentials.py
```

This script will test all configured authentication methods and report which ones work.

For detailed information about all authentication methods, see [CREDENTIAL_SETUP_GUIDE.md](CREDENTIAL_SETUP_GUIDE.md).

**Deployment Process:**

The gateway now deploys **both** Lambda functions and Redshift external functions in two phases:

1. **Phase 1**: Deploy Lambda functions to AWS
2. **Phase 2**: Create external functions in Redshift that call the Lambdas

If Redshift configuration is incomplete, only Phase 1 will run (Lambda-only deployment).

### Required AWS Permissions

Your AWS user needs Lambda permissions to deploy functions. You have two options:

**Option 1: Use Managed Policy (Simplest)**

Attach the AWS managed policy `AWSLambda_FullAccess` to your IAM user.

**Option 2: Pre-create Lambda Execution Role (Recommended for external users)**

To avoid needing IAM role creation permissions, pre-create the Lambda execution role.

**Default (no custom prefix):**

```bash
# Create the role (name derived from LAMBDA_PREFIX in PascalCase)
# Default LAMBDA_PREFIX=carto-at- → CartoATLambdaExecutionRole
aws iam create-role \
  --role-name CartoATLambdaExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach basic execution policy
aws iam attach-role-policy \
  --role-name CartoATLambdaExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

Then add to your `.env`:
```bash
LAMBDA_EXECUTION_ROLE_ARN=arn:aws:iam::<account-id>:role/CartoATLambdaExecutionRole
```

With this approach, your user only needs these Lambda permissions (no IAM permissions required):
- `lambda:CreateFunction`
- `lambda:UpdateFunctionCode`
- `lambda:UpdateFunctionConfiguration`
- `lambda:GetFunction` (optional, but recommended)

### Validate Functions

```bash
# List all available functions
make list

# List functions in a specific module
make list modules=quadbin
```

### Deploy Functions

**Prerequisites**: Ensure your `.env` file is configured with AWS credentials and Redshift details.

#### Deploy to Development (default)

```bash
# Deploy all functions to dev environment
make deploy

# Deploy specific modules
make deploy modules=quadbin

# Deploy specific functions
make deploy functions=quadbin_polyfill

# Deploy only modified functions (recommended for CI/CD)
make deploy diff=1

# Dry run to preview deployment without making changes
make deploy dry-run=1
```

#### Deploy to Production

```bash
# Deploy all functions to production
make deploy production=1

# Deploy specific modules to production
make deploy modules=quadbin production=1

# Deploy only modified functions to production
make deploy diff=1 production=1

# Dry run for production
make deploy production=1 dry-run=1
```

**What `production=1` does:**

- Deploys to schema `carto` instead of `{RS_PREFIX}carto`
- Matches the clouds pattern for production deployments
- Example with `RS_PREFIX=myname_`:
  - Dev: Functions created in `myname_carto` schema
  - Prod: Functions created in `carto` schema

### Development Workflow

```bash
# Run linters
make lint

# Run tests
make test

# Clean build artifacts
make clean
```

### Create Distribution Package

```bash
# Create a distribution package (defaults to cloud=redshift)
make create-package

# Include only specific functions
make create-package functions=quadbin_polyfill,quadbin_bbox

# Include private/experimental functions
make create-package production=1
```

### Cross-Account Deployment

If your Lambda functions are in a different AWS account than your Redshift cluster:

**Setup:**
1. Deploy Lambda to Account A using Account A credentials in `.env`
2. Set `RS_ROLES` to a role in Account B (Redshift's account)
3. Add Lambda resource policy to allow Account B to invoke:

```bash
# For each deployed function, run (adjust function name based on your LAMBDA_PREFIX):
aws lambda add-permission \
  --function-name carto-at-quadbin_polyfill \
  --statement-id redshift-cross-account-invoke \
  --action lambda:InvokeFunction \
  --principal arn:aws:iam::ACCOUNT-B-ID:role/RedshiftLambdaRole
```

4. Ensure the role in `RS_ROLES` has a trust policy allowing Redshift to assume it

**Example `.env` for cross-account:**
```bash
# Lambda deployed in Account A (123456789)
AWS_ACCESS_KEY_ID=<account-a-key>
AWS_SECRET_ACCESS_KEY=<account-a-secret>

# Redshift in Account B (987654321)
RS_HOST=cluster.account-b.region.redshift.amazonaws.com
RS_USER=<redshift-user>
RS_PASSWORD=<redshift-password>
RS_ROLES=arn:aws:iam::987654321:role/RedshiftLambdaRole
```

The external function will be created with:
- `LAMBDA 'arn:aws:lambda:region:123456789:function:...'` (Account A)
- `IAM_ROLE 'arn:aws:iam::987654321:role/...'` (Account B)

## Function Development

### Creating a New Function

1. **Create the directory structure:**

```bash
mkdir -p gateway/functions/<module>/<function_name>/{code/lambda/python,tests/{unit,integration}}
```

2. **Create `function.yaml`:**

```yaml
function_type: scalar
status: development
author: CARTO
description: |
  Your function description

arguments:
  - name: arg1
    type: geometry
    description: First argument

output:
  name: result
  type: string
  description: Result description

examples:
  - description: "Example usage"
    arguments:
      - "ST_POINT(0, 0)"
    output: "expected_output"

clouds:
  redshift:
    type: lambda
    code_file: code/lambda/python/handler.py
    requirements_file: code/lambda/python/requirements.txt
    external_function_template: code/redshift.sql
    config:
      memory_size: 512
      timeout: 60
      runtime: python3.11
```

3. **Implement the handler** in `code/lambda/python/handler.py`:

```python
from typing import Dict, Any

def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """Handler for Redshift external function"""
    try:
        arguments = event.get('arguments', [])
        results = []

        for row in arguments:
            # Process each row
            result = process_row(row)
            results.append(result)

        return {
            "success": True,
            "num_records": len(arguments),
            "results": results
        }
    except Exception as e:
        return {
            "success": False,
            "error_msg": str(e),
            "num_records": 0,
            "results": []
        }

def process_row(row):
    # Your logic here
    pass
```

4. **Add test cases** in `tests/unit/cases.yaml`:

```yaml
test_cases:
  - name: "basic_test"
    inputs:
      arg1: "value"
    expected: "expected_result"
```

5. **Validate and test:**

```bash
make validate
make test
```

### Using Lambda Wrapper Utilities

For cleaner code, use the provided wrapper decorators:

```python
from logic.platforms.aws_lambda.runtime import redshift_handler

@redshift_handler
def process_row(row):
    """Process a single row - wrapper handles error formatting"""
    if not row or row[0] is None:
        return None
    return row[0] * 2

# The decorator automatically creates lambda_handler
lambda_handler = process_row
```

## Testing

```bash
# Run unit tests
make test

# Run linters
make lint
```

## Configuration

### Function-Specific Configuration

Configure per-function settings in the `function.yaml` under `clouds.redshift.config`:

```yaml
clouds:
  redshift:
    config:
      memory_size: 1024      # MB
      timeout: 120           # seconds
      max_batch_rows: 1000   # rows per batch
      runtime: python3.11
```

## Distribution Package

The distribution package includes:
- Lambda function code for all functions
- Interactive installer script
- Deployment logic (boto3-based)
- Documentation

Customers run:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r scripts/requirements.txt
python scripts/install.py
```

## CI/CD Integration

### GitHub Actions

Example GitHub Actions workflow:

```yaml
name: Gateway CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run linters
        run: make lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: make test

  deploy-dev:
    needs: [lint, test]
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure environment
        run: |
          echo "AWS_REGION=${{ secrets.AWS_REGION }}" >> .env
          echo "AWS_PROFILE=default" >> .env
          echo "REDSHIFT_CLUSTER_ID=${{ secrets.REDSHIFT_CLUSTER_ID }}" >> .env
          echo "REDSHIFT_DATABASE=${{ secrets.REDSHIFT_DATABASE }}" >> .env
          echo "REDSHIFT_SCHEMA=carto" >> .env
          echo "LAMBDA_PREFIX=dev-carto-at-" >> .env
      - name: Deploy to development
        run: make deploy diff=1

  deploy-prod:
    needs: [lint, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure environment
        run: |
          echo "AWS_REGION=${{ secrets.AWS_REGION }}" >> .env
          echo "AWS_PROFILE=default" >> .env
          echo "REDSHIFT_CLUSTER_ID=${{ secrets.REDSHIFT_CLUSTER_ID }}" >> .env
          echo "REDSHIFT_DATABASE=${{ secrets.REDSHIFT_DATABASE }}" >> .env
          echo "REDSHIFT_SCHEMA=carto" >> .env
          echo "LAMBDA_PREFIX=carto-at-prod" >> .env
      - name: Deploy to production
        run: make deploy production=1 diff=1
```

### Incremental Deployment

The system supports deploying only modified functions using the `diff=1` parameter:

```bash
# Deploy only functions modified in git working tree
make deploy diff=1
```

The system uses `git diff` to detect changes and only redeploys affected functions.

## Architecture

### Components

1. **Catalog Loader** - Discovers and loads function definitions
2. **Validator** - Validates function.yaml against schema
3. **Lambda Deployer** - Packages and deploys Lambda functions
4. **SQL Renderer** - Generates external function SQL from templates
5. **CLI** - Command-line interface for deployments

### Deployment Flow

```
function.yaml → Validator → Catalog Loader → Lambda Deployer → AWS Lambda
                                            → SQL Renderer → External Function
```

## Troubleshooting

### Common Issues

**Function validation fails:**
- Check `function.yaml` against schema
- Ensure all referenced code files exist
- Verify cloud configurations are correct

**Lambda deployment fails:**
- Check AWS credentials and permissions
- Verify IAM roles exist
- Check CloudWatch logs for errors

**External function errors:**
- Verify Lambda ARN is correct
- Check Redshift IAM role permissions
- Review Lambda response format

### Getting Help

- Check function README files
- Review CloudWatch logs
- Consult the architecture document

## Make Commands

Summary of all available commands:

- `make help`: Shows the commands available in the Makefile
- `make lint`: Runs linters (black, flake8) to check code quality
- `make lint-fix`: Automatically fixes code style issues with black
- `make test`: Runs all tests (unit + integration)
- `make test-unit`: Runs only unit tests
- `make test-integration`: Runs only integration tests (requires Redshift connection)
- `make validate`: Validates function definitions
- `make deploy`: Deploys Lambda functions and creates external functions in Redshift
- `make create-package`: Creates a distribution package for customer installation
- `make clean`: Cleans build artifacts and cache files
- `make clean-all`: Cleans everything including virtual environment

**Filtering:**

Commands `deploy` and `create-package` can be filtered by:
- `modules`: list of modules to filter (e.g., `modules=quadbin`)
- `functions`: list of functions to filter (e.g., `functions=quadbin_polyfill`)
- `diff`: deploy only modified functions (e.g., `diff=1`)
- `production`: deploy to production schema `carto` instead of `{RS_PREFIX}carto` (e.g., `production=1`)

Examples:
```bash
make deploy modules=quadbin
make deploy functions=quadbin_polyfill production=1
make deploy diff=1
make create-package modules=quadbin
```

## Contributing

When adding new functions:
1. Follow the directory structure
2. Include comprehensive tests (unit and integration)
3. Add documentation in function's README.md
4. Validate before committing (`make validate`)
5. Update CHANGELOG.md with changes

## Related Documentation

- [Architecture Document](../claude_instructions.md)
- [Function Template](functions/FUNCTION_TEMPLATE.yaml) *(to be created)*
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Redshift External Functions](https://docs.aws.amazon.com/redshift/latest/dg/external-function.html)
