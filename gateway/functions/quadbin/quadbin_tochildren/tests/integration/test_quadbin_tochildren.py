"""Integration tests for QUADBIN_TOCHILDREN function"""

import json
import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinTochildrenIntegration:
    """Integration tests for QUADBIN_TOCHILDREN with Redshift"""

    def test_quadbin_tochildren(self):
        result = run_query(
            "SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079,5)"
        )

        assert len(result[0]) == 1
        assert (
            json.loads(result[0][0]).sort()
            == [
                5214064458820747263,
                5214073254913769471,
                5214068856867258367,
                5214077652960280575,
            ].sort()
        )

    def test_quadbin_tochildren_negative_resolution_failure(self):
        """Test that negative resolution raises error"""
        with pytest.raises(Exception) as excinfo:
            run_query(
                "SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, -1)"
            )
        assert "Invalid resolution" in str(excinfo.value)

    def test_quadbin_tochildren_resolution_overflow_failure(self):
        """Test that resolution overflow raises error"""
        with pytest.raises(Exception) as excinfo:
            run_query(
                "SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079, 27)"
            )
        assert "Invalid resolution" in str(excinfo.value)

    def test_quadbin_tochildren_resolution_smaller_than_index_failure(self):
        """Test that resolution smaller than index raises error"""
        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADBIN_TOCHILDREN(5209574053332910079,3)")
        assert "Invalid resolution" in str(excinfo.value)
