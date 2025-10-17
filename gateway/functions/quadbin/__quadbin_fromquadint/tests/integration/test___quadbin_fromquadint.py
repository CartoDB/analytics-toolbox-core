"""Integration tests for __QUADBIN_FROMQUADINT function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinFromquadintIntegration:
    """Integration tests for __QUADBIN_FROMQUADINT with Redshift"""

    def test_quadbin_fromquadint(self):
        result = run_query("SELECT @@RS_SCHEMA@@.__QUADBIN_FROMQUADINT(12521547919)")

        assert len(result[0]) == 1
        assert result[0][0] == 5256684166837174271
