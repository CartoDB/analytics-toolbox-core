#!/usr/bin/env python3
"""
Shared Oracle database utilities.
Provides common functionality for connecting to Oracle databases.
"""

import os
import sys
import io
import base64
import tempfile
import zipfile
import atexit
import shutil
import oracledb
from pathlib import Path

# Module-level wallet directory cache: reuse across all connections in a process
# so that oracledb's internal TNS cache remains valid throughout the session.
_wallet_dir = None
_conn_string = None


def _cleanup_wallet():
    """Remove cached wallet directory at process exit."""
    global _wallet_dir
    if _wallet_dir and os.path.exists(_wallet_dir):
        shutil.rmtree(_wallet_dir, ignore_errors=True)


atexit.register(_cleanup_wallet)


def extract_wallet(wallet_zip_b64, wallet_password):
    """Extract Oracle wallet from base64-encoded ZIP."""
    global _wallet_dir, _conn_string

    if _wallet_dir and os.path.exists(_wallet_dir):
        return _wallet_dir, _conn_string

    zip_data = base64.b64decode(wallet_zip_b64)
    wallet_dir = tempfile.mkdtemp(prefix='oracle_wallet_')

    with zipfile.ZipFile(io.BytesIO(zip_data)) as z:
        z.extractall(wallet_dir)

    sqlnet_path = Path(wallet_dir) / 'sqlnet.ora'
    if sqlnet_path.exists():
        content = sqlnet_path.read_text()
        content = content.replace('?/network/admin', wallet_dir)
        sqlnet_path.write_text(content)

    tnsnames_path = Path(wallet_dir) / 'tnsnames.ora'
    if tnsnames_path.exists():
        content = tnsnames_path.read_text()
        for line in content.split('\n'):
            if '=' in line and not line.strip().startswith('#'):
                conn_name = line.split('=')[0].strip()
                _wallet_dir = wallet_dir
                _conn_string = conn_name
                return wallet_dir, conn_name

    raise Exception('Could not extract connection string from tnsnames.ora')


def get_connection():
    """
    Create Oracle database connection using environment variables.

    Returns:
        oracledb.Connection: Active database connection
        str: Wallet directory path (kept alive for process lifetime)
    """
    user = os.getenv('ORA_USER')
    password = os.getenv('ORA_PASSWORD')
    wallet_zip = os.getenv('ORA_WALLET_ZIP')
    wallet_password = os.getenv('ORA_WALLET_PASSWORD')
    conn_string_override = os.getenv('ORA_CONNECTION_STRING')

    if not all([user, password, wallet_zip, wallet_password]):
        print(
            'ERROR: Missing Oracle credentials. '
            'Set ORA_USER, ORA_PASSWORD, ORA_WALLET_ZIP, ORA_WALLET_PASSWORD'
        )
        sys.exit(1)

    wallet_dir, conn_string = extract_wallet(wallet_zip, wallet_password)

    if conn_string_override:
        conn_string = conn_string_override

    os.environ['TNS_ADMIN'] = wallet_dir
    try:
        oracledb.init_oracle_client(config_dir=wallet_dir)
    except Exception:
        pass  # Already initialized

    connection = oracledb.connect(user=user, password=password, dsn=conn_string)
    return connection, wallet_dir
