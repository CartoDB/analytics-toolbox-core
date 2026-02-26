# CARTO Analytics Toolbox Core for Oracle - Installation

## Prerequisites

- Oracle Autonomous Database (or Oracle Database 19c+)
- User with CREATE FUNCTION and CREATE PROCEDURE privileges
- SQL*Plus, SQL Developer, or any Oracle client

## Installation Steps

### 1. Extract the Package

```bash
unzip carto-analytics-toolbox-core-oracle-*.zip
cd carto-analytics-toolbox-core-oracle-*/
```

### 2. Connect to Oracle

Connect to your Oracle database with a user that has privileges to create functions:

```bash
# Using SQL*Plus
sqlplus user/password@database

# Or use SQL Developer, DBeaver, etc.
```

### 3. Deploy Functions

Run the SQL script in your connected session:

```sql
@modules.sql
```

This will:

- Remove any existing Analytics Toolbox functions (if present)
- Create all core functions in your current schema

### 4. Verify Installation

Check the installed version:

```sql
SELECT VERSION_CORE() FROM DUAL;
```

Expected output: `1.0.0` (or current version)

## Schema Management

Functions are created in the schema of the connected user.

**Examples:**

- Development: Connect as `DEV_CARTO` user → functions in `DEV_CARTO` schema
- Production: Connect as `CARTO` user → functions in `CARTO` schema

## Cross-Schema Access

To allow other users to execute the functions:

```sql
-- Grant to specific user
GRANT EXECUTE ON YOUR_SCHEMA.VERSION_CORE TO app_user;

-- Or create a role (recommended)
CREATE ROLE carto_analytics_user;
GRANT EXECUTE ON YOUR_SCHEMA.VERSION_CORE TO carto_analytics_user;
GRANT carto_analytics_user TO app_user;
```

Users can then call functions with the schema prefix:

```sql
SELECT YOUR_SCHEMA.VERSION_CORE() FROM DUAL;
```

## Uninstallation

To remove all Analytics Toolbox functions:

```sql
BEGIN
  FOR rec IN (
    SELECT object_name, object_type
    FROM user_objects
    WHERE object_type IN ('FUNCTION', 'PROCEDURE')
    ORDER BY
      CASE object_type WHEN 'PROCEDURE' THEN 1 ELSE 2 END,
      object_name
  ) LOOP
    EXECUTE IMMEDIATE 'DROP ' || rec.object_type || ' ' || rec.object_name;
  END LOOP;
END;
/
```

## Troubleshooting

### Permission Denied

If you see permission errors, ensure your user has:

```sql
GRANT CREATE PROCEDURE TO your_user;
GRANT CREATE FUNCTION TO your_user;
```

### Objects Already Exist

The deployment script automatically drops existing objects before recreating them. If you see errors about existing objects, they will be resolved during the script execution.

## Support

- Documentation: <https://github.com/CartoDB/analytics-toolbox-core>
- Issues: <https://github.com/CartoDB/analytics-toolbox-core/issues>
