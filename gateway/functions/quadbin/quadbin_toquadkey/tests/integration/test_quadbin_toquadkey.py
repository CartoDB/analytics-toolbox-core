"""Integration tests for QUADBIN_TOQUADKEY function"""

import pytest
from test_utils.integration.redshift import run_query

input = [
    # quadkey, quadbin
    ("", 5192650370358181887),
    ("0", 5193776270265024511),
    ("13020310", 5226184719091105791),
    ("0231001222", 5233974874938015743),
]


@pytest.mark.integration
class TestQuadbinToquadkeyIntegration:
    """Integration tests for QUADBIN_TOQUADKEY with Redshift"""

    @pytest.mark.parametrize("quadkey, quadbin", input)
    def test_quadbin_toquadkey(self, quadkey, quadbin):
        result = run_query(f"SELECT @@RS_SCHEMA@@.QUADBIN_TOQUADKEY({quadbin})")
        assert len(result[0]) == 1
        assert result[0][0] == quadkey
