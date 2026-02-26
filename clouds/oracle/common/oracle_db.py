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
import oracledb
from pathlib import Path


def extract_wallet(wallet_zip_b64, wallet_password):
    """Extract Oracle wallet from base64-encoded ZIP."""
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
                return wallet_dir, conn_name

    raise Exception('Could not extract connection string from tnsnames.ora')


def get_connection():
    """
    Create Oracle database connection using environment variables.

    Returns:
        oracledb.Connection: Active database connection
        str: Wallet directory path (for cleanup)
    """
    user = os.getenv('ORA_USER')
    password = os.getenv('ORA_PASSWORD')
    wallet_zip = os.getenv('ORA_WALLET_ZIP')
    wallet_password = os.getenv('ORA_WALLET_PASSWORD')

    if not all([user, password, wallet_zip, wallet_password]):
        print(
            'ERROR: Missing Oracle credentials. '
            'Set ORA_USER, ORA_PASSWORD, ORA_WALLET_ZIP, ORA_WALLET_PASSWORD'
        )
        sys.exit(1)

    wallet_dir, conn_string = extract_wallet(wallet_zip, wallet_password)

    os.environ['TNS_ADMIN'] = wallet_dir
    try:
        oracledb.init_oracle_client(config_dir=wallet_dir)
    except Exception:
        pass  # Already initialized

    connection = oracledb.connect(user=user, password=password, dsn=conn_string)
    return connection, wallet_dir
