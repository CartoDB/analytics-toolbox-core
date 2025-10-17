"""Integration tests for QUADBIN_ISVALID function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinIsvalidIntegration:
    """Integration tests for QUADBIN_ISVALID with Redshift"""

    def test_quadbin_isvalid(self):
        result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_ISVALID(5209574053332910079)")

        assert len(result[0]) == 1
        assert result[0][0] is True

    def test_quadbin_isvalid_invalid_index(self):
        result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_ISVALID(1234)")

        assert len(result[0]) == 1
        assert result[0][0] is False

    def test_quadbin_isvalid_invalid_index_trailing_bits(self):
        result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_ISVALID(5209538868960821248)")

        assert len(result[0]) == 1
        assert result[0][0] is False
