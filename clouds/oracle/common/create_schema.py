#!/usr/bin/env python3
"""
Create Oracle schema for CI/CD deployments.

This script creates a schema-only user (NO AUTHENTICATION) for Analytics Toolbox
deployments in CI/CD environments. Schema-only users:
- Cannot log in (no authentication method)
- Can own objects (procedures, functions, tables)
- Can be accessed by other users via cross-schema calls with GRANT permissions

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
import oracledb
import base64
import tempfile
import zipfile
import io
from pathlib import Path


def extract_wallet(wallet_zip_b64, wallet_password):
    """Extract Oracle wallet from base64-encoded ZIP."""
    # Decode base64 ZIP
    zip_data = base64.b64decode(wallet_zip_b64)

    # Create temporary directory for wallet
    wallet_dir = tempfile.mkdtemp(prefix='oracle_wallet_')

    # Extract ZIP to wallet directory
    with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
        z.extractall(wallet_dir)

    # Update sqlnet.ora to point to wallet directory
    sqlnet_path = Path(wallet_dir) / 'sqlnet.ora'
    if sqlnet_path.exists():
        content = sqlnet_path.read_text()
        content = content.replace('?/network/admin', wallet_dir)
        sqlnet_path.write_text(content)

    # Extract connection string from tnsnames.ora
    tnsnames_path = Path(wallet_dir) / 'tnsnames.ora'
    if tnsnames_path.exists():
        content = tnsnames_path.read_text()
        # Extract first connection name
        for line in content.split('\n'):
            if '=' in line and not line.strip().startswith('#'):
                conn_name = line.split('=')[0].strip()
                return wallet_dir, conn_name

    raise Exception('Could not extract connection string from tnsnames.ora')


def create_schema(schema_name):
    """Create Oracle schema (user with NO AUTHENTICATION)."""
    # Get credentials from environment
    user = os.getenv('ORA_USER')
    password = os.getenv('ORA_PASSWORD')
    wallet_zip = os.getenv('ORA_WALLET_ZIP')
    wallet_password = os.getenv('ORA_WALLET_PASSWORD')

    if not all([user, password, wallet_zip, wallet_password, schema_name]):
        print(
            'ERROR: Missing Oracle credentials or schema name. '
            'Set ORA_USER, ORA_PASSWORD, '
            'ORA_WALLET_ZIP, ORA_WALLET_PASSWORD, ORA_SCHEMA'
        )
        sys.exit(1)

    # Extract wallet and get connection string
    wallet_dir, conn_string = extract_wallet(wallet_zip, wallet_password)

    try:
        # Set TNS_ADMIN environment variable
        os.environ['TNS_ADMIN'] = wallet_dir

        # Initialize Oracle client (if not already initialized)
        try:
            oracledb.init_oracle_client(config_dir=wallet_dir)
        except Exception:
            pass  # Already initialized

        # Connect to Oracle
        connection = oracledb.connect(user=user, password=password, dsn=conn_string)
        cursor = connection.cursor()

        print(f'Setting up schema: {schema_name}')

        # Check if user/schema already exists
        cursor.execute(
            "SELECT COUNT(*) FROM dba_users WHERE username = :username",
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
        # These grants are REQUIRED for the schema to create AT objects:
        # - CREATE PROCEDURE: Allows creating procedures (SETUP, INTERNAL_CREATE_BUILDER_MAP, etc.)
        # - CREATE FUNCTION: Allows creating functions (VERSION_CORE, INTERNAL_ENDPOINT, etc.)
        # - UNLIMITED TABLESPACE: Allows storing procedure/function definitions and tables
        cursor.execute(f'GRANT CREATE PROCEDURE TO {schema_name}')
        print(f'  ✓ Granted CREATE PROCEDURE')

        cursor.execute(f'GRANT CREATE FUNCTION TO {schema_name}')
        print(f'  ✓ Granted CREATE FUNCTION')

        cursor.execute(f'GRANT UNLIMITED TABLESPACE TO {schema_name}')
        print(f'  ✓ Granted UNLIMITED TABLESPACE')

        connection.commit()
        cursor.close()
        connection.close()

        print(f'\n✓ Schema {schema_name} ready for Analytics Toolbox deployment')
        print(f'\nNote: Schema-only user (NO AUTHENTICATION)')
        print(f'      - Cannot log in directly')
        print(f'      - Has privileges to create procedures, functions, and tables')
        print(f'      - Other users can access via: {schema_name}.FUNCTION_NAME()')
        print(f'      - Existing objects in schema (if any) are preserved')

    finally:
        # Cleanup wallet directory
        import shutil

        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    schema_name = os.getenv('ORA_SCHEMA')

    if not schema_name:
        print('ERROR: ORA_SCHEMA environment variable not set')
        print('Usage: ORA_SCHEMA=CI_12345678_123456 python create_schema.py')
        sys.exit(1)

    create_schema(schema_name)
