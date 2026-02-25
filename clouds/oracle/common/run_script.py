#!/usr/bin/env python3
"""
Execute Oracle SQL scripts.

This script connects to Oracle using wallet-based authentication and executes
SQL scripts with variable replacement support.
"""

import os
import re
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
    # Normalize whitespace (line comments already removed by build_modules.js)
    # Remove block comments (/* ... */) if any remain
    clean = re.sub(r'/\*.*?\*/', '', statement, flags=re.DOTALL)
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

        # Remove line comments
        sql = re.sub(r'--.*\n', '\n', sql)

        # Execute SQL (split by statement terminator)
        cursor = connection.cursor()
        statements = sql.split('/\n')  # Oracle uses / as statement terminator
        statements = [s.strip() for s in statements if s.strip()]

        executed_count = 0

        # Use tqdm for consistent progress bar style with gateway
        with tqdm(statements, desc='Deploying', ncols=80, unit='stmt') as pbar:
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

                            # Validate compilation for procedures and functions
                            if obj_type in ('procedure', 'function'):
                                # Check object status using all_objects
                                # (not user_objects) because we may be
                                # deploying to a different schema
                                cursor.execute(
                                    """
                                    SELECT status
                                    FROM all_objects
                                    WHERE owner = :schema
                                    AND object_name = :obj_name
                                    AND object_type = :obj_type
                                """,
                                    {
                                        'schema': schema.upper(),
                                        'obj_name': obj_name.upper(),
                                        'obj_type': obj_type.upper(),
                                    },
                                )

                                result = cursor.fetchone()
                                if result and result[0] == 'INVALID':
                                    # Object is invalid, get compilation
                                    # errors from all_errors
                                    cursor.execute(
                                        """
                                        SELECT line, position, text
                                        FROM all_errors
                                        WHERE owner = :schema
                                        AND name = :obj_name
                                        AND type = :obj_type
                                        ORDER BY sequence
                                    """,
                                        {
                                            'schema': schema.upper(),
                                            'obj_name': obj_name.upper(),
                                            'obj_type': obj_type.upper(),
                                        },
                                    )

                                    errors = cursor.fetchall()
                                    tqdm.write(f'  ✗ COMPILATION ERRORS in {obj_name}:')
                                    if errors:
                                        for line, pos, text in errors:
                                            tqdm.write(
                                                f'      Line {line}, '
                                                f'Position {pos}: {text}'
                                            )
                                    else:
                                        tqdm.write(
                                            '      Object is INVALID but no '
                                            'errors in all_errors'
                                        )
                                    raise Exception(
                                        f'Compilation failed for {obj_type} {obj_name}'
                                    )
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
