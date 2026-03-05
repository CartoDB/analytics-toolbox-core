#!/usr/bin/env python3
"""Execute a single Oracle SQL query."""

import sys
import shutil
from oracle_db import get_connection


def run_query(query):
    """Execute a single SQL query against Oracle."""
    conn, wallet_dir = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(query)
            conn.commit()
    finally:
        conn.close()
        shutil.rmtree(wallet_dir, ignore_errors=True)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: run_query.py <query>')
        sys.exit(1)

    run_query(sys.argv[1])
