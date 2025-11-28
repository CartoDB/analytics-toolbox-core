"""Integration tests for QUADBIN_FROMZXY function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinFromzxyIntegration:
    """Integration tests for QUADBIN_FROMZXY with Redshift"""

    def test_quadbin_fromzxy(self):
        result = run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMZXY(4,9,8)")

        assert len(result[0]) == 1
        assert result[0][0] == 5209574053332910079
