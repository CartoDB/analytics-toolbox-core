"""Integration tests for QUADBIN_BOUNDARY function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinBoundaryIntegration:
    """Integration tests for QUADBIN_BOUNDARY with Redshift"""

    def test_quadbin_boundary(self):
        result = run_query(
            "SELECT ST_ASTEXT(@@RS_SCHEMA@@.QUADBIN_BOUNDARY(5209574053332910079))"
        )

        assert len(result[0]) == 1
        assert result[0][0] == (
            "POLYGON((22.5 -21.9430455334382,22.5 0,"
            "45 0,45 -21.9430455334382,22.5 -21.9430455334382))"
        )
