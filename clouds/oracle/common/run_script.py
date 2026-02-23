#!/usr/bin/env python3
"""
Execute Oracle SQL scripts.

This script connects to Oracle using wallet-based authentication and executes
SQL scripts with variable replacement support.
"""

import os
import sys
import io
import oracledb
import base64
import tempfile
import zipfile
from pathlib import Path
from tqdm import tqdm


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


def replace_variables(sql, variables):
    """Replace @@VARIABLE@@ placeholders in SQL."""
    for var, value in variables.items():
        sql = sql.replace(f'@@{var}@@', str(value))
    return sql


def parse_statement_info(statement):
    """Extract information about what SQL statement is doing."""
    import re

    # Remove comments and normalize whitespace
    clean = re.sub(r'--.*$', '', statement, flags=re.MULTILINE)
    clean = re.sub(r'/\*.*?\*/', '', clean, flags=re.DOTALL)
    clean = ' '.join(clean.split()).upper()

    # Try to extract object type and name
    patterns = [
        # CREATE OR REPLACE FUNCTION schema.function_name
        (r'CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+(?:\w+\.)?(\w+)', 'function'),
        # CREATE OR REPLACE PROCEDURE schema.procedure_name
        (r'CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+(?:\w+\.)?(\w+)', 'procedure'),
        # DROP FUNCTION schema.function_name
        (r'DROP\s+FUNCTION\s+(?:\w+\.)?(\w+)', 'drop function'),
        # DROP PROCEDURE schema.procedure_name
        (r'DROP\s+PROCEDURE\s+(?:\w+\.)?(\w+)', 'drop procedure'),
    ]

    for pattern, obj_type in patterns:
        match = re.search(pattern, clean)
        if match:
            obj_name = match.group(1)
            return obj_type, obj_name

    return None, None


def execute_script(script_path):
    """Execute SQL script against Oracle."""
    # Get credentials from environment
    user = os.getenv('ORA_USER')
    password = os.getenv('ORA_PASSWORD')
    wallet_zip = os.getenv('ORA_WALLET_ZIP')
    wallet_password = os.getenv('ORA_WALLET_PASSWORD')
    schema = os.getenv('ORA_SCHEMA', 'ADMIN')

    if not all([user, password, wallet_zip, wallet_password]):
        print(
            'ERROR: Missing Oracle credentials. '
            'Set ORA_USER, ORA_PASSWORD, '
            'ORA_WALLET_ZIP, ORA_WALLET_PASSWORD'
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

        # Read SQL script
        with open(script_path, 'r') as f:
            sql = f.read()

        # Replace variables
        # Note: These are set by Makefile from version file and exports
        variables = {
            'ORA_SCHEMA': schema,
            'PACKAGE_VERSION': os.getenv('ORA_PACKAGE_VERSION'),
            'VERSION_FUNCTION': os.getenv('ORA_VERSION_FUNCTION'),
        }
        sql = replace_variables(sql, variables)

        # Execute SQL (split by statement terminator)
        cursor = connection.cursor()
        statements = sql.split('/\n')  # Oracle uses / as statement terminator

        # Filter out empty and comment-only statements to get accurate count
        valid_statements = [
            s.strip()
            for s in statements
            if s.strip() and not s.strip().startswith('--')
        ]

        executed_count = 0

        # Use tqdm for consistent progress bar style with gateway
        with tqdm(valid_statements, desc='Deploying', ncols=80, unit='stmt') as pbar:
            for statement in pbar:
                try:
                    # Parse what we're doing
                    obj_type, obj_name = parse_statement_info(statement)

                    # Execute the statement
                    cursor.execute(statement)
                    executed_count += 1

                    # Show detailed output above the progress bar
                    if obj_type and obj_name:
                        if obj_type.startswith('drop'):
                            obj_type_clean = obj_type.replace('drop ', '')
                            tqdm.write(f'  - Dropping {obj_type_clean}: {obj_name}')
                        else:
                            tqdm.write(f'  + Creating {obj_type}: {obj_name}')
                    else:
                        # Fallback for statements we can't parse
                        first_words = ' '.join(statement.split()[:5])
                        tqdm.write(f'  • Executing: {first_words}...')

                except Exception as e:
                    # tqdm automatically closes on exception
                    tqdm.write(f'  ✗ ERROR: {e}')
                    tqdm.write(f'    Statement preview: {statement[:200]}...')
                    raise

        connection.commit()
        cursor.close()
        connection.close()

        print(f'\n✓ Successfully deployed {executed_count} statements to {schema}')

    finally:
        # Cleanup wallet directory
        import shutil

        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: run_script.py <script.sql>')
        sys.exit(1)

    execute_script(sys.argv[1])
