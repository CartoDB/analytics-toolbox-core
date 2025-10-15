"""
Integration tests for PLACEKEY_FROMH3 function
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
class TestPlacekeyFromh3Integration:
    """Integration tests that require database connection"""

    def test_placekey_fromh3_valid(self):
        """Test PLACEKEY_FROMH3 with valid H3 indices"""
        result = run_query(
            """
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('847b59dffffffff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a2a9c580577fff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a3c9ea2bd4ffff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a5b4c1047b7fff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a8e8116a6d7fff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a3e0ba6659ffff')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('8a961652a407fff')
        """
        )

        assert result[0][0] == "@ff7-swh-m49"
        assert result[1][0] == "@63m-vc4-z75"
        assert result[2][0] == "@7qg-xf9-j5f"
        assert result[3][0] == "@bhm-9m8-gtv"
        assert result[4][0] == "@h5z-gcq-kvf"
        assert result[5][0] == "@7v4-m2p-3t9"
        assert result[6][0] == "@hvb-5d7-92k"

    def test_placekey_fromh3_invalid(self):
        """Test PLACEKEY_FROMH3 with invalid inputs"""
        result = run_query(
            """
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3(NULL)
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_FROMH3('ff283473fffffff')
        """
        )

        assert result[0][0] is None
        assert result[1][0] is None
