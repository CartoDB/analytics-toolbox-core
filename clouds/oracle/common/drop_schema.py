#!/usr/bin/env python3
"""
Drop Oracle schema (CI cleanup).

This script fully drops an Oracle schema including all objects (CASCADE).
Used for CI/CD cleanup to remove ephemeral test schemas.

⚠️ WARNING: This drops the entire schema and ALL its objects!
   Use only for ephemeral CI schemas, not production environments.

Usage:
    python drop_schema.py

Environment Variables:
    ORA_USER            - Admin user with DROP USER privilege
    ORA_PASSWORD        - Admin user password
    ORA_WALLET_ZIP      - Base64-encoded Oracle wallet ZIP
    ORA_WALLET_PASSWORD - Oracle wallet password
    ORA_SCHEMA          - Schema name to drop (e.g., CI_12345678_123456)
"""

import os
import sys
import shutil
from oracle_db import get_connection


def drop_schema(schema_name):
    """Drop Oracle schema with CASCADE (removes all objects)."""
    if not schema_name:
        print(
            'ERROR: Missing Oracle credentials or schema name. '
            'Set ORA_USER, ORA_PASSWORD, '
            'ORA_WALLET_ZIP, ORA_WALLET_PASSWORD, ORA_SCHEMA'
        )
        sys.exit(1)

    connection, wallet_dir = get_connection()

    try:
        cursor = connection.cursor()

        print(f'Dropping schema: {schema_name}')

        # Check if user/schema exists
        cursor.execute(
            'SELECT COUNT(*) FROM dba_users WHERE username = :username',
            username=schema_name.upper(),
        )
        exists = cursor.fetchone()[0] > 0

        if not exists:
            print(f'  ℹ Schema {schema_name} does not exist, nothing to drop')
        else:
            # Drop user cascade (removes all objects)
            cursor.execute(f'DROP USER {schema_name} CASCADE')
            print(f'  ✓ Dropped schema {schema_name} and all its objects')

        connection.commit()
        cursor.close()
        connection.close()

        print(f'\n✓ Cleanup complete for {schema_name}')

    except Exception as e:
        # Don't fail CI if schema doesn't exist or can't be dropped
        print(f'⚠ Warning: Could not drop schema {schema_name}: {e}')
        print('  (This may be expected if schema was already removed)')

    finally:
        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    schema_name = os.getenv('ORA_SCHEMA')

    if not schema_name:
        print('ERROR: ORA_SCHEMA environment variable not set')
        print('Usage: ORA_SCHEMA=CI_12345678_123456 python drop_schema.py')
        sys.exit(1)

    drop_schema(schema_name)
