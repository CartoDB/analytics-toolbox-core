# CARTO Analytics Toolbox for Oracle

The Analytics Toolbox for Oracle contains SQL functions and procedures. The functions are deployed in a schema called `CARTO` inside the Oracle database. In Oracle, the functions can be used with cross-schema access using fully qualified names or by granting EXECUTE permissions.

Note: Oracle requires wallet-based authentication for Autonomous Database connections.

## Tools

Make sure you have installed the following tools:

- `make`: <https://www.gnu.org/software/make/>
- `Python3`: <https://www.python.org/downloads/> (v3.10+)
- `node`: <https://nodejs.org/> (v20+)
- `yarn`: <https://yarnpkg.com/>
- `virtualenv`: <https://virtualenv.pypa.io/en/latest/>

## Environment variables

The `.env` file contains the variables required to deploy and run the toolbox. Replace each `<template>` with your values.

```
# Oracle
ORACLE_SCHEMA=<schema-name>
ORACLE_USER=<database-user>
ORACLE_PASSWORD=<user-password>
ORACLE_WALLET_ZIP=<base64-encoded-wallet-zip>
ORACLE_WALLET_PASSWORD=<wallet-password>
```

**ORACLE_SCHEMA** (required)

The Oracle schema name to deploy Analytics Toolbox functions. Unlike other clouds where schemas can be created dynamically, Oracle schemas are tied to database users and typically pre-created.

**This variable is required** - deployment will fail if not set.

Examples:

- Development: `ORACLE_SCHEMA=DEV_CARTO` or `ORACLE_SCHEMA=MYNAME_CARTO`
- CI/CD: `ORACLE_SCHEMA=CI_USER_12345678`
- Production: `ORACLE_SCHEMA=CARTO`
- Testing: `ORACLE_SCHEMA=ADMIN`

**ORACLE_USER**

The Oracle database user with privileges to create functions and procedures in the target schema. This could be `ADMIN` for Autonomous Database, or any user with appropriate privileges.

**ORACLE_PASSWORD**

The password for the Oracle database user.

**ORACLE_WALLET_ZIP**

Base64-encoded Oracle wallet ZIP file. To generate:

```bash
# macOS/Linux
base64 -i Wallet_YourDB.zip | tr -d '\n' > wallet_base64.txt

# Windows PowerShell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("Wallet_YourDB.zip")) | Out-File -Encoding ASCII wallet_base64.txt
```

Then copy the contents of `wallet_base64.txt` to this variable.

**ORACLE_WALLET_PASSWORD**

The password you set when downloading the Oracle wallet ZIP file.

## Structure

- `common`: Common build scripts and utilities
- `modules`
  - `doc`: contains the functions' documentation
  - `sql`: contains the functions' SQL code
  - `test`: contains the functions' tests

## Make commands

- `make help`: shows the commands available in the Makefile
- `make lint`: runs a linter (flake8, sqlfluff) and fixes the trivial issues (brunette)
- `make build-modules`: builds the final SQL scripts
- `make deploy`: builds and deploys SQL scripts to the Oracle database
- `make test`: runs the modules tests with the Oracle database (pytest)
- `make remove`: removes SQL functions from the Oracle database
- `make clean`: cleans the installed dependencies and generated files locally
- `make create-package`: creates a distributable package (ZIP file)

**Filtering**

Commands `build-modules`, `deploy-modules`, and `test-modules` can be filtered by the following. All the filters are additive:

- `diff`: list of changed files
- `modules`: list of modules to filter
- `functions`: list of functions to filter

Example:

```
make build-modules diff=modules/sql/utils/VERSION_ADVANCED.sql
make deploy-modules modules=utils
make test-modules functions=VERSION_CORE
```

## Oracle-Specific Notes

### Wallet Authentication

Oracle Autonomous Database uses wallet-based authentication. The deployment script (`common/run_script.py`):

1. Decodes the base64 wallet ZIP
2. Extracts to a temporary directory
3. Updates `sqlnet.ora` with the correct path
4. Reads connection string from `tnsnames.ora`
5. Connects using the wallet
6. Executes SQL scripts
7. Cleans up the temporary wallet directory

### Schema Naming

Oracle schemas are directly specified via `ORACLE_SCHEMA` environment variable:

- Set `ORACLE_SCHEMA=DEV_CARTO` for development
- Set `ORACLE_SCHEMA=CI_USER_12345678` for CI/CD
- Set `ORACLE_SCHEMA=CARTO` for production
- Defaults to `CARTO` if not specified

**Note**: Unlike Snowflake/BigQuery where schemas can be created on-the-fly, Oracle schemas are tied to database users and must be pre-created.

### Cross-Schema Access

To call functions from a different schema, grant EXECUTE permission:

```sql
-- Grant to specific user
GRANT EXECUTE ON CARTO.VERSION_CORE TO app_user;

-- Grant to role
CREATE ROLE carto_analytics_user;
GRANT EXECUTE ON CARTO.VERSION_CORE TO carto_analytics_user;
GRANT carto_analytics_user TO app_user;

-- Call cross-schema
SELECT CARTO.VERSION_CORE() FROM DUAL;
```

### SQL Terminator

Oracle uses `/` as the statement terminator (on a new line by itself), not `;`. The build system handles this correctly.

Example:

```sql
CREATE OR REPLACE FUNCTION VERSION_CORE
RETURN VARCHAR2
IS
BEGIN
    RETURN '1.0.0';
END VERSION_CORE;
/
```

### Version Function

The core package generates `VERSION_CORE` function to identify the package version:

```sql
SELECT VERSION_CORE() FROM DUAL;
-- Returns: 1.0.0
```
