"""Integration tests for QUADBIN_KRING_DISTANCES function"""

import json
import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinKringDistancesIntegration:
    """Integration tests for QUADBIN_KRING_DISTANCES with Redshift"""

    def test_quadbin_kring_distances(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_KRING_DISTANCES(5209574053332910079, 1)"
        )

        assert len(result[0]) == 1
        assert json.loads(result[0][0]) == [
            {"index": 5208043533147045887, "distance": 1},
            {"index": 5208061125333090303, "distance": 1},
            {"index": 5208113901891223551, "distance": 1},
            {"index": 5209556461146865663, "distance": 1},
            {"index": 5209574053332910079, "distance": 0},
            {"index": 5209626829891043327, "distance": 1},
            {"index": 5209591645518954495, "distance": 1},
            {"index": 5209609237704998911, "distance": 1},
            {"index": 5209662014263132159, "distance": 1},
        ]
