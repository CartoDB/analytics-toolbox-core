#!/usr/bin/env python3
"""Execute a single Oracle SQL query."""

import os
import sys
import shutil
from oracle_db import get_connection


def run_query(query, fetch=False):
    """Execute a single SQL query against Oracle.

    Args:
        query: SQL query string. @@ORA_SCHEMA@@ placeholders are replaced
               with the ORA_SCHEMA environment variable if set.
        fetch: If True, return results from cursor.fetchall().
               If False (default), commit and return None.
    """
    query = query.replace('@@ORA_SCHEMA@@', os.environ.get('ORA_SCHEMA', ''))
    conn, wallet_dir = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        if fetch:
            try:
                return cursor.fetchall()
            except Exception:
                return 'No results returned'
        else:
            conn.commit()
    finally:
        conn.close()
        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: run_query.py <query>')
        sys.exit(1)

    run_query(sys.argv[1])
