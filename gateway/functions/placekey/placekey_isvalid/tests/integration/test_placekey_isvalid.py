"""
Integration tests for PLACEKEY_ISVALID function
These tests run against a real Redshift database
"""

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

    # Calculate schema from RS_PREFIX
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
class TestPlacekeyIsvalidIntegration:
    """Integration tests that require database connection"""

    def test_placekey_isvalid(self):
        """Test PLACEKEY_ISVALID with various inputs"""
        result = run_query(
            """
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID(NULL)
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('@abc')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abcxyz234')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('ebc-345@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('bcd-345@')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('22-zzz@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('bcd-2u4-xez')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('zzz@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ISVALID('222-zzz@abc-234-xyz')
        """
        )

        assert result[0][0] is False
        assert result[1][0] is False
        assert result[2][0] is False
        assert result[3][0] is False
        assert result[4][0] is False
        assert result[5][0] is False
        assert result[6][0] is False
        assert result[7][0] is False
        assert result[8][0] is True
        assert result[9][0] is True
        assert result[10][0] is True
        assert result[11][0] is True
        assert result[12][0] is True
