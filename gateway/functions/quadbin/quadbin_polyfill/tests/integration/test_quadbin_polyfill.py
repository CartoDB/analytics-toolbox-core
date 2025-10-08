"""
Integration tests for QUADBIN_POLYFILL function
These tests run against a real Redshift database
Uses the same pattern as core/clouds/redshift/modules/test
"""

import json
import os
import pytest
from pathlib import Path
from dotenv import load_dotenv

# Load .env from core root (shared with clouds)
gateway_root = Path(__file__).parent.parent.parent.parent.parent.parent
core_root = gateway_root.parent
core_env = core_root / ".env"
gateway_env = gateway_root / ".env"

if core_env.exists():
    load_dotenv(core_env)
elif gateway_env.exists():
    load_dotenv(gateway_env)

try:
    import redshift_connector

    HAS_REDSHIFT_CONNECTOR = True
except ImportError:
    HAS_REDSHIFT_CONNECTOR = False


def run_query(query):
    """
    Execute a query against Redshift
    Similar to clouds test_utils.run_query but uses RS_PREFIX instead of RS_SCHEMA
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


@pytest.mark.integration
class TestQuadbinPolyfillIntegration:
    """Integration tests that require database connection"""

    def test_quadbin_polyfill(self):
        """
        Test QUADBIN_POLYFILL function with polygon
        Same test case as core/clouds/redshift/modules/test/quadbin
        """
        polygon = (
            "POLYGON ((-363.71219873428345 40.413365349070865,"
            "-363.7144088745117 40.40965661286395,"
            "-363.70659828186035 40.409525904775634,"
            "-363.71219873428345 40.413365349070865))"
        )
        result = run_query(
            f"SELECT @@RS_SCHEMA@@.QUADBIN_POLYFILL("
            f"ST_GEOMFROMTEXT('{polygon}'), 17)"
        )

        assert len(result[0]) == 1
        assert (
            json.loads(result[0][0]).sort()
            == [
                5265786693164204031,
                5265786693163941887,
                5265786693153193983,
                5265786693164466175,
                5265786693164728319,
                5265786693165514751,
            ].sort()
        )
