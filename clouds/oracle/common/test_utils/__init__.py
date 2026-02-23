import os
import oracledb
import base64
import tempfile
import zipfile
import io
from pathlib import Path

from oracledb.exceptions import DatabaseError

__all__ = ['DatabaseError']


def _get_connection():
    """Create Oracle connection using wallet authentication."""
    user = os.environ['ORA_USER']
    password = os.environ['ORA_PASSWORD']
    wallet_zip = os.environ['ORA_WALLET_ZIP']
    wallet_password = os.environ['ORA_WALLET_PASSWORD']

    # Decode and extract wallet
    zip_data = base64.b64decode(wallet_zip)
    wallet_dir = tempfile.mkdtemp(prefix='oracle_wallet_test_')

    with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
        z.extractall(wallet_dir)

    # Update sqlnet.ora
    sqlnet_path = Path(wallet_dir) / 'sqlnet.ora'
    if sqlnet_path.exists():
        content = sqlnet_path.read_text()
        content = content.replace('?/network/admin', wallet_dir)
        sqlnet_path.write_text(content)

    # Extract connection string
    tnsnames_path = Path(wallet_dir) / 'tnsnames.ora'
    conn_string = None
    if tnsnames_path.exists():
        content = tnsnames_path.read_text()
        for line in content.split('\n'):
            if '=' in line and not line.strip().startswith('#'):
                conn_string = line.split('=')[0].strip()
                break

    # Set TNS_ADMIN
    os.environ['TNS_ADMIN'] = wallet_dir

    # Initialize Oracle client (if not already initialized)
    try:
        oracledb.init_oracle_client(config_dir=wallet_dir)
    except Exception:
        pass  # Already initialized

    return oracledb.connect(user=user, password=password, dsn=conn_string)


def run_query(query):
    """Execute a query and return results."""
    conn = _get_connection()
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


def run_queries(queries):
    """Execute multiple queries and return results from the last one."""
    conn = _get_connection()
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


def get_cursor():
    """Get a database cursor for manual operations."""
    conn = _get_connection()
    return conn.cursor()
