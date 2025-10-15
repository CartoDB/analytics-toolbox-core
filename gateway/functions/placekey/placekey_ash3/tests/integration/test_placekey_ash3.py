"""
Integration tests for PLACEKEY_ASH3 function
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
class TestPlacekeyAsh3Integration:
    """Integration tests that require database connection"""

    def test_placekey_ash3_valid(self):
        """Test PLACEKEY_ASH3 with valid placekeys"""
        result = run_query(
            """
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@c6z-c2g-dgk')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@63m-vc4-z75')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@7qg-xf9-j5f')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@bhm-9m8-gtv')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@h5z-gcq-kvf')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@7v4-m2p-3t9')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@hvb-5d7-92k')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@ab2-k43-xqz')
        """
        )

        assert result[0][0] == "8a62e9d08a1ffff"
        assert result[1][0] == "8a2a9c580577fff"
        assert result[2][0] == "8a3c9ea2bd4ffff"
        assert result[3][0] == "8a5b4c1047b7fff"
        assert result[4][0] == "8a8e8116a6d7fff"
        assert result[5][0] == "8a3e0ba6659ffff"
        assert result[6][0] == "8a961652a407fff"
        assert result[7][0] == "8a01262c914ffff"

    def test_placekey_ash3_invalid(self):
        """Test PLACEKEY_ASH3 with invalid inputs"""
        result = run_query(
            """
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3(NULL)
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('@abc')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abc-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abcxyz234')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('abc-345@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('ebc-345@abc-234-xyz')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('bcd-345@')
            UNION ALL
            SELECT @@RS_SCHEMA@@.PLACEKEY_ASH3('22-zzz@abc-234-xyz')
        """
        )

        assert result[0][0] is None
        assert result[1][0] is None
        assert result[2][0] is None
        assert result[3][0] is None
        assert result[4][0] is None
        assert result[5][0] is None
        assert result[6][0] is None
        assert result[7][0] is None
