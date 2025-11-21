# CARTO Analytics Toolbox Gateway

The Gateway lets you write Python functions that can be called from SQL in Redshift (and other clouds in the future). Your Python code runs on AWS Lambda, making it easy to use external libraries and complex logic from your database queries.

**All deployment logic lives in `gateway/logic/`**. See [CLAUDE.md](../CLAUDE.md) for the complete technical guide.

## What You'll Need

Before starting, make sure you have:

1. Python 3.10 or newer
2. AWS credentials with permissions to create Lambda functions
3. A Redshift cluster (if you want to deploy functions)

## Getting Started

### 1. Set Up Your Environment

```bash
# Create a Python virtual environment
make venv

# Copy the configuration template
cp .env.template .env

# Edit .env and add your AWS and Redshift credentials
```

The `.env.template` file has detailed comments explaining each setting.

### 2. Configure Your Credentials

Here's a minimal example of what you need in your `.env` file:

```bash
# AWS settings
AWS_REGION=us-east-1
AWS_PROFILE=my-profile           # Or use AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY

# Lambda settings
RS_LAMBDA_PREFIX=yourname-       # Short prefix for dev (leave empty for production)

# Redshift settings
RS_PREFIX=yourname_              # Schema prefix for dev (leave empty for production)
RS_HOST=<your-cluster>.redshift.amazonaws.com
RS_DATABASE=<database>
RS_USER=<user>
RS_PASSWORD=<password>
RS_LAMBDA_INVOKE_ROLE=arn:aws:iam::<account>:role/<role>
```

### 3. Try It Out

```bash
# Build your functions (this copies shared code where it's needed)
make build cloud=redshift

# Run the tests
make test-unit cloud=redshift

# Deploy to your dev environment
make deploy cloud=redshift
```

## Creating a New Function

Each function lives in its own folder with this structure:

```
gateway/functions/<module>/<function_name>/
├── function.yaml          # Describes your function
├── code/
│   ├── lambda/python/
│   │   ├── handler.py     # Your Python code
│   │   └── requirements.txt (optional - Python dependencies)
│   └── redshift.sql (optional - can be auto-generated)
└── tests/
    ├── unit/              # Unit tests
    └── integration/       # Integration tests (optional)
```

### Simple Example

For a simple function, you just need to describe it in `function.yaml`:

```yaml
name: s2_fromtoken
module: s2

# Define your parameters and return type
parameters:
  - name: token
    type: string
  - name: resolution
    type: int
returns: bigint

clouds:
  redshift:
    type: lambda
    lambda_name: s2_ftok      # Keep this short (≤18 chars total with your prefix)
    code_file: code/lambda/python/handler.py
```

The SQL will be generated automatically! Generic types like `string` and `int` are converted to the right types for each cloud.

### More Complex Example

If you need custom SQL or want to use external Python packages:

```yaml
name: quadbin_polyfill
module: quadbin

clouds:
  redshift:
    type: lambda
    lambda_name: qb_polyfill
    code_file: code/lambda/python/handler.py
    requirements_file: code/lambda/python/requirements.txt
    external_function_template: code/redshift.sql
    shared_libs:
      - quadbin                # Reuses code from _shared/python/quadbin/
    config:
      memory_size: 512         # MB of memory
      timeout: 300             # Seconds
      max_batch_rows: 50       # How many rows to process at once
```

### Writing the Handler

Your `handler.py` file processes the data:

```python
from carto.lambda_wrapper import redshift_handler

@redshift_handler
def process_row(row):
    """Process a single row of data."""
    if not row or row[0] is None:
        return None

    # Your logic here
    result = do_something(row[0])
    return result

lambda_handler = process_row
```

The `@redshift_handler` decorator handles batching and error handling for you.

### Sharing Code Between Functions

If multiple functions need the same code, put it in `gateway/functions/_shared/python/<lib_name>/` and list it in your `function.yaml`:

```yaml
shared_libs:
  - quadbin
  - utils
```

When you build, this code gets copied to each function that needs it.

## Common Tasks

### Testing Your Functions

```bash
# Always build first (copies shared code)
make build cloud=redshift

# Run all tests
make test-unit cloud=redshift

# Test a specific module
make test-unit cloud=redshift modules=quadbin

# Test a specific function
make test-unit cloud=redshift functions=quadbin_polyfill

# Integration tests (needs a real Redshift cluster)
make test-integration cloud=redshift
```

### Deploying Functions

```bash
# Deploy everything to your dev environment
make deploy cloud=redshift

# Deploy to production (no dev prefixes)
make deploy cloud=redshift production=1

# Deploy just one function
make deploy cloud=redshift functions=quadbin_polyfill

# Deploy all functions in a module
make deploy cloud=redshift modules=quadbin

# Deploy only what changed
make deploy cloud=redshift diff=1
```

When you deploy, the system:
1. Packages your code and dependencies into a .zip file
2. Uploads it to AWS Lambda
3. Creates the SQL function in Redshift that calls your Lambda

### Code Quality

```bash
# Check your code
make lint

# Auto-fix issues
make lint-fix
```

### Creating Distribution Packages

```bash
# Create a package for distribution
make create-package cloud=redshift

# Production package
make create-package cloud=redshift production=1
```

This creates `dist/carto-analytics-toolbox-redshift-<version>.zip`.

## Things to Remember

- **Build before testing**: Always run `make build` before `make test-unit`. This copies shared libraries where they're needed.
- **Short Lambda names**: Keep the `lambda_name` field short (≤18 characters including your prefix) to avoid AWS limits.
- **Dev vs Production**: Dev mode adds prefixes to your schema and function names. Production mode doesn't.
- **Check .env.template**: It has detailed documentation for all configuration options.

## Need More Details?

For everything technical:
- **[CLAUDE.md](../CLAUDE.md)** - Complete architecture, type mapping system, troubleshooting, and development guidelines
- **[.env.template](.env.template)** - All configuration options explained

## Getting Help

If something isn't working:
1. Check the troubleshooting section in [CLAUDE.md](../CLAUDE.md)
2. Verify your `.env` file has the right credentials
3. Make sure your `function.yaml` follows the structure shown above
4. Check that your AWS credentials have the necessary permissions
