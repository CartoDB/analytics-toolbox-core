import os
import sys
import shutil

# Add parent directory to path to import oracle_db and run_query
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from oracle_db import get_connection  # noqa: E402
from oracledb.exceptions import DatabaseError  # noqa: E402

__all__ = [
    'DatabaseError',
    'quote_table_name',
    'run_query',
    'run_queries',
    'get_cursor',
    'drop_table',
]


def quote_table_name(table_name):
    """Quote table name for Oracle queries (handles underscore-prefixed names)."""
    if '.' in table_name:
        schema, table = table_name.rsplit('.', 1)
        return f'{schema}."{table.upper()}"'
    return f'"{table_name.upper()}"'


def run_query(query):
    """Execute a query and return results.

    Note: wallet directory is intentionally not cleaned up here —
    oracledb caches the tnsnames.ora path per session, so deleting
    the wallet between calls causes subsequent connections to fail.
    OS temp cleanup handles reclamation.
    """
    query = query.replace('@@ORA_SCHEMA@@', os.environ.get('ORA_SCHEMA', ''))
    conn, _wallet_dir = get_connection()
    conn.autocommit = True
    cursor = conn.cursor()
    cursor.execute(query)
    try:
        return cursor.fetchall()
    except Exception:
        return 'No results returned'
    finally:
        cursor.close()
        conn.close()


def run_queries(queries):
    """Execute multiple queries and return results from the last one."""
    conn, wallet_dir = get_connection()
    try:
        cursor = conn.cursor()
        for query in queries:
            query = query.replace('@@ORA_SCHEMA@@', os.environ.get('ORA_SCHEMA', ''))
            cursor.execute(query)
        try:
            return cursor.fetchall()
        except Exception:
            return 'No results returned'
        finally:
            cursor.close()
            conn.close()
    finally:
        shutil.rmtree(wallet_dir, ignore_errors=True)


def get_cursor():
    """Get a database cursor for manual operations."""
    conn, _wallet_dir = get_connection()
    return conn.cursor()


def drop_table(*table_names):
    """Drop one or more tables, ignoring non-existent ones.

    Equivalent to DROP TABLE IF EXISTS, which Oracle does not support
    natively. Accepts @@ORA_SCHEMA@@ placeholders which are resolved by
    run_query.
    """
    for table_name in table_names:
        try:
            run_query(f'DROP TABLE {quote_table_name(table_name)}')
        except Exception:
            pass
