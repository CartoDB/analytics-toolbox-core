"""Integration tests for QUADINT_KRING_DISTANCES function"""

import json
import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadintKringDistancesIntegration:
    """Integration tests for QUADINT_KRING_DISTANCES with Redshift"""

    def test_kring_distances_success(self):
        """Test getting k-ring with distances"""
        result = run_query(
            """SELECT @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(162, 1),
                @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(12070922, 1),
                @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(12070922, 2)"""
        )

        assert json.loads(result[0][0]) == [
            {"index": 2, "distance": 1},
            {"index": 34, "distance": 1},
            {"index": 66, "distance": 1},
            {"index": 130, "distance": 1},
            {"index": 162, "distance": 0},
            {"index": 194, "distance": 1},
            {"index": 258, "distance": 1},
            {"index": 290, "distance": 1},
            {"index": 322, "distance": 1},
        ]
        assert json.loads(result[0][1]) == [
            {"index": 12038122, "distance": 1},
            {"index": 12038154, "distance": 1},
            {"index": 12038186, "distance": 1},
            {"index": 12070890, "distance": 1},
            {"index": 12070922, "distance": 0},
            {"index": 12070954, "distance": 1},
            {"index": 12103658, "distance": 1},
            {"index": 12103690, "distance": 1},
            {"index": 12103722, "distance": 1},
        ]
        assert json.loads(result[0][2]) == [
            {"index": 12005322, "distance": 2},
            {"index": 12005354, "distance": 2},
            {"index": 12005386, "distance": 2},
            {"index": 12005418, "distance": 2},
            {"index": 12005450, "distance": 2},
            {"index": 12038090, "distance": 2},
            {"index": 12038122, "distance": 1},
            {"index": 12038154, "distance": 1},
            {"index": 12038186, "distance": 1},
            {"index": 12038218, "distance": 2},
            {"index": 12070858, "distance": 2},
            {"index": 12070890, "distance": 1},
            {"index": 12070922, "distance": 0},
            {"index": 12070954, "distance": 1},
            {"index": 12070986, "distance": 2},
            {"index": 12103626, "distance": 2},
            {"index": 12103658, "distance": 1},
            {"index": 12103690, "distance": 1},
            {"index": 12103722, "distance": 1},
            {"index": 12103754, "distance": 2},
            {"index": 12136394, "distance": 2},
            {"index": 12136426, "distance": 2},
            {"index": 12136458, "distance": 2},
            {"index": 12136490, "distance": 2},
            {"index": 12136522, "distance": 2},
        ]

    def test_kring_distances_invalid_failure(self):
        """Test that invalid inputs raise errors"""
        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(NULL, NULL)")
        assert "Invalid input origin" in str(excinfo.value)

        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(-1, 1)")
        assert "Invalid input origin" in str(excinfo.value)

        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADINT_KRING_DISTANCES(162, -1)")
        assert "Invalid input size" in str(excinfo.value)
