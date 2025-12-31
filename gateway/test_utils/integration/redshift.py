"""
Amazon Redshift integration test utilities.

Provides helpers for testing Redshift external functions against a real database.
"""

import os
import pytest
from pathlib import Path
from dotenv import load_dotenv

# Load .env files (gateway or core root)
_gateway_root = Path(__file__).parent.parent.parent
_core_root = _gateway_root.parent
_core_env = _core_root / ".env"
_gateway_env = _gateway_root / ".env"

if _core_env.exists():
    load_dotenv(_core_env)
elif _gateway_env.exists():
    load_dotenv(_gateway_env)

# Check if redshift_connector is available
try:
    import redshift_connector

    HAS_REDSHIFT_CONNECTOR = True
except ImportError:
    HAS_REDSHIFT_CONNECTOR = False


def run_query(query):
    """
    Execute a SQL query against Redshift for integration testing.

    This automatically handles:
    - Checking if redshift_connector is installed
    - Loading connection credentials from environment
    - Calculating schema from RS_PREFIX
    - Replacing @@RS_SCHEMA@@ placeholder
    - Connection management

    Args:
        query: SQL query string, use @@RS_SCHEMA@@ as schema placeholder

    Returns:
        Query results as list of tuples

    Example:
        from test_utils.integration.redshift import run_query

        result = run_query('''
            SELECT @@RS_SCHEMA@@.MY_FUNCTION('test')
        ''')
        assert result[0][0] == 'expected_value'
    """
    if not HAS_REDSHIFT_CONNECTOR:
        pytest.skip("redshift_connector not installed")

    host = os.getenv("RS_HOST")
    database = os.getenv("RS_DATABASE")
    user = os.getenv("RS_USER")
    password = os.getenv("RS_PASSWORD")

    if not all([host, database, user, password]):
        pytest.skip(
            "Redshift connection not configured. "
            "Set RS_HOST, RS_DATABASE, RS_USER, RS_PASSWORD in .env"
        )

    # Calculate schema from RS_PREFIX (same as clouds RS_SCHEMA)
    prefix = os.getenv("RS_PREFIX", "")
    schema = f"{prefix}carto" if prefix else "carto"

    conn = redshift_connector.connect(
        host=host, database=database, user=user, password=password
    )
    conn.autocommit = True
    cursor = conn.cursor()
    cursor.execute(query.replace("@@RS_SCHEMA@@", schema))
    try:
        return cursor.fetchall()
    except Exception:
        return "No results returned"
    finally:
        cursor.close()
        conn.close()


@pytest.fixture
def redshift_query():
    """
    Fixture that provides the run_query function for integration tests.

    Example:
        def test_my_function(redshift_query):
            result = redshift_query("SELECT @@RS_SCHEMA@@.MY_FUNCTION('test')")
            assert result[0][0] == 'expected'
    """
    return run_query
