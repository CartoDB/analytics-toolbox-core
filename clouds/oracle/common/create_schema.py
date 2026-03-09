#!/usr/bin/env python3
"""
Create Oracle schema for CI/CD deployments.

This script creates a schema-only user (NO AUTHENTICATION) for Analytics Toolbox
deployments in CI/CD environments. Schema-only users:
- Cannot log in (no authentication method)
- Can own objects (procedures, functions, tables)
- Can be accessed by other users via cross-schema calls with GRANT permissions

Grants:
- CREATE PROCEDURE (includes functions)
- CREATE TABLE (for map, statistics, tiler modules)
- CREATE VIEW (for LDS and data modules)
- UNLIMITED TABLESPACE
- INHERIT PRIVILEGES ON USER (for AUTHID CURRENT_USER procedures)
- Network ACL permissions (connect, resolve) for AT Gateway features

Usage:
    python create_schema.py

Environment Variables:
    ORA_USER            - Admin user with CREATE USER privilege
    ORA_PASSWORD        - Admin user password
    ORA_WALLET_ZIP      - Base64-encoded Oracle wallet ZIP
    ORA_WALLET_PASSWORD - Oracle wallet password
    ORA_SCHEMA          - Schema name to create (e.g., CI_12345678_123456)
"""

import os
import sys
import shutil
from oracle_db import get_connection


def create_schema(schema_name):
    """Create Oracle schema (user with NO AUTHENTICATION)."""
    user = os.getenv('ORA_USER')

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

        print(f'Setting up schema: {schema_name}')

        # Check if user/schema already exists
        cursor.execute(
            'SELECT COUNT(*) FROM dba_users WHERE username = :username',
            username=schema_name.upper(),
        )
        exists = cursor.fetchone()[0] > 0

        if exists:
            print(f'  ℹ Schema {schema_name} already exists, skipping creation')
        else:
            # Create schema-only user (NO AUTHENTICATION = cannot log in)
            cursor.execute(f'CREATE USER {schema_name} NO AUTHENTICATION')
            print(f'  ✓ Created schema {schema_name}')

        # Grant necessary privileges for Analytics Toolbox deployment
        # These grants are REQUIRED for the schema to create and use AT objects:
        # - CREATE PROCEDURE: Allows creating procedures AND functions
        #   (covers both)
        # - CREATE TABLE: Allows creating tables
        #   (required for map, statistics, tiler, etc.)
        # - CREATE VIEW: Allows creating views
        #   (required for LDS and data modules)
        # - UNLIMITED TABLESPACE: Allows storing procedure/function
        #   definitions, tables, and views
        # - Network ACL: Allows HTTP/HTTPS requests (granted below)
        cursor.execute(f'GRANT CREATE PROCEDURE TO {schema_name}')
        print('  ✓ Granted CREATE PROCEDURE (covers procedures and functions)')

        cursor.execute(f'GRANT CREATE TABLE TO {schema_name}')
        print('  ✓ Granted CREATE TABLE')

        cursor.execute(f'GRANT CREATE VIEW TO {schema_name}')
        print('  ✓ Granted CREATE VIEW')

        cursor.execute(f'GRANT UNLIMITED TABLESPACE TO {schema_name}')
        print('  ✓ Granted UNLIMITED TABLESPACE')

        # Grant INHERIT PRIVILEGES to allow AUTHID CURRENT_USER procedures
        # This is required for procedures like INTERNAL_CREATE_BUILDER_MAP
        # that use AUTHID CURRENT_USER and need to execute with caller's privileges
        try:
            cursor.execute(f'GRANT INHERIT PRIVILEGES ON USER {user} TO {schema_name}')
            print(f'  ✓ Granted INHERIT PRIVILEGES ON USER {user}')
        except Exception as e:
            # INHERIT PRIVILEGES might fail if user doesn't have the privilege
            # or if it's already granted. Required for AUTHID CURRENT_USER procedures.
            print(f'  ⚠ Could not grant INHERIT PRIVILEGES: {e}')
            print('    AUTHID CURRENT_USER procedures may fail without this grant')
            print(
                '    Manual grant required: '
                f'GRANT INHERIT PRIVILEGES ON USER {user} TO {schema_name};'
            )

        # Grant network ACL permissions for AT Gateway features
        # Required for UTL_HTTP calls (INTERNAL_GENERIC_HTTP, gateway functions)
        try:
            cursor.execute(
                """
                BEGIN
                    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
                        host => '*',
                        ace  => xs$ace_type(
                            privilege_list => xs$name_list('connect', 'resolve'),
                            principal_name => :schema_name,
                            principal_type => xs_acl.ptype_db
                        )
                    );
                END;
                """,
                schema_name=schema_name.upper(),
            )
            print('  ✓ Granted network ACL permissions (connect, resolve)')
        except Exception as e:
            # ACL grants might fail if user doesn't have EXECUTE on
            # DBMS_NETWORK_ACL_ADMIN. SETUP will validate and error.
            print(f'  ⚠ Could not grant network ACL permissions: {e}')
            print('    Gateway features will require manual ACL grant by DBA')

        connection.commit()
        cursor.close()
        connection.close()

        print(f'✓ Schema {schema_name} ready for Analytics Toolbox deployment')

    finally:
        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    schema_name = os.getenv('ORA_SCHEMA')

    if not schema_name:
        print('ERROR: ORA_SCHEMA environment variable not set')
        print('Usage: ORA_SCHEMA=CI_12345678_123456 python create_schema.py')
        sys.exit(1)

    create_schema(schema_name)
