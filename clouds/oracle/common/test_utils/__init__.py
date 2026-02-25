import os
import sys

# Add parent directory to path to import oracle_db
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from oracle_db import get_connection  # noqa: E402
from oracledb.exceptions import DatabaseError  # noqa: E402

__all__ = ['DatabaseError', 'quote_table_name']


def quote_table_name(table_name):
    """Quote table name for Oracle queries (handles underscore-prefixed names)."""
    if '.' in table_name:
        schema, table = table_name.rsplit('.', 1)
        return f'{schema}."{table.upper()}"'
    return f'"{table_name.upper()}"'


def run_query(query):
    """Execute a query and return results."""
    conn, _wallet_dir = get_connection()
    conn.autocommit = True
    cursor = conn.cursor()

    # Replace schema placeholder
    query = query.replace('@@ORA_SCHEMA@@', os.environ['ORA_SCHEMA'])

    cursor.execute(query)
    try:
        return cursor.fetchall()
    except Exception:
        return 'No results returned'
    finally:
        cursor.close()
        conn.close()
        # Note: Wallet directory cleanup handled by OS temp cleanup


def run_queries(queries):
    """Execute multiple queries and return results from the last one."""
    conn, _wallet_dir = get_connection()
    conn.autocommit = True
    cursor = conn.cursor()

    for query in queries:
        # Replace schema placeholder
        query = query.replace('@@ORA_SCHEMA@@', os.environ['ORA_SCHEMA'])
        cursor.execute(query)

    try:
        return cursor.fetchall()
    except Exception:
        return 'No results returned'
    finally:
        cursor.close()
        conn.close()
        # Note: Wallet directory cleanup handled by OS temp cleanup


def get_cursor():
    """Get a database cursor for manual operations."""
    conn, _wallet_dir = get_connection()
    return conn.cursor()
