"""
Integration tests for PLACEKEY_FROMH3 function
These tests run against a real Redshift database
"""

import pytest
from test_utils.integration.redshift import run_query


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
