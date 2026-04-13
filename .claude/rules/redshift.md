---
paths:
  - "clouds/redshift/**"
---

# Redshift

## Configuration

Create a `.env` file in the repository root or `gateway/` (template: `gateway/.env.template`):

```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>

# Lambda Configuration
RS_LAMBDA_PREFIX=yourname-at-dev  # Prefix for Lambda functions (max 46 chars, total name <=64)
RS_LAMBDA_OVERRIDE=1              # Override existing Lambdas (1=yes, 0=no)

# Redshift Connection
RS_SCHEMA=yourname_carto          # Schema name (used directly)
# OR
RS_PREFIX=yourname_               # Schema prefix (concatenated with "carto")
                                  # RS_SCHEMA takes priority if both are set
RS_HOST=<cluster>.redshift.amazonaws.com
RS_DATABASE=<database>
RS_USER=<user>
RS_PASSWORD=<password>
RS_LAMBDA_INVOKE_ROLE=arn:aws:iam::<account>:role/<role>
```

## RS_SCHEMA vs RS_PREFIX

- **RS_SCHEMA**: Use directly as schema name (e.g., `yourname_carto`)
- **RS_PREFIX**: Concatenated with "carto" (e.g., `yourname_` → `yourname_carto`)
- **RS_SCHEMA takes priority** if both are set

## Commands

```bash
cd clouds/redshift
make test                          # Run all tests (pytest)
make test modules=h3               # Specific module
make test functions=H3_POLYFILL    # Specific function
make deploy                        # Deploy SQL UDFs
make lint                          # Run linter

# Gateway deployment (from gateway/)
cd gateway
make deploy cloud=redshift
make deploy cloud=redshift diff=1  # Deploy only modified functions
```

## SQL Naming Conventions

```sql
-- Definition: parentheses on separate line
CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.H3_POLYFILL
(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR ...

-- Invocation: no space before parentheses
SELECT @@RS_SCHEMA@@.H3_POLYFILL(geom, 5)
```

## Key Details

- Schema placeholder: `@@RS_SCHEMA@@`
- Python libraries: `clouds/redshift/libraries/python/`
- Modules: h3, quadbin, s2, placekey, constructors, transformations, processing, clustering, random
