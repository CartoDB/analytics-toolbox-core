#!/usr/bin/env python3
"""
Execute Oracle SQL scripts.

This script connects to Oracle using wallet-based authentication and executes
SQL scripts with variable replacement support.
"""

import os
import sys
import shutil
from tqdm import tqdm
from oracle_db import get_connection


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
    schema = os.getenv('ORA_SCHEMA', 'ADMIN')

    # Get connection from shared module
    connection, wallet_dir = get_connection()

    try:
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
        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: run_script.py <script.sql>')
        sys.exit(1)

    execute_script(sys.argv[1])
