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


def drop_schema(schema_name):
    """Drop Oracle schema with CASCADE (removes all objects)."""
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
        # Cleanup wallet directory
        import shutil

        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    schema_name = os.getenv('ORA_SCHEMA')

    if not schema_name:
        print('ERROR: ORA_SCHEMA environment variable not set')
        print('Usage: ORA_SCHEMA=CI_12345678_123456 python drop_schema.py')
        sys.exit(1)

    drop_schema(schema_name)
