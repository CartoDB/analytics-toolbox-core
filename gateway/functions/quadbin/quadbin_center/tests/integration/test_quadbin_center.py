"""Integration tests for QUADBIN_CENTER function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinCenterIntegration:
    """Integration tests for QUADBIN_CENTER with Redshift"""

    def test_quadbin_center(self):
        result = run_query(
            "SELECT ST_ASTEXT(@@RS_SCHEMA@@.QUADBIN_CENTER(5209574053332910079))"
        )

        assert len(result[0]) == 1
        assert result[0][0] == "POINT(33.75 -11.1784018737118)"
