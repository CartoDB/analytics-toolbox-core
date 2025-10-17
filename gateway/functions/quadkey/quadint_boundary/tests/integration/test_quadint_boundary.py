"""Integration tests for QUADINT_BOUNDARY function"""

import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
class TestQuadintBoundaryIntegration:
    """Integration tests for QUADINT_BOUNDARY with Redshift"""

    def test_boundary_success(self):
        """Test getting boundary geometries for quadints"""
        results = run_query(
            """SELECT @@RS_SCHEMA@@.QUADINT_BOUNDARY(12070922) as geog1,
            @@RS_SCHEMA@@.QUADINT_BOUNDARY(791040491538) as geog2,
            @@RS_SCHEMA@@.QUADINT_BOUNDARY(12960460429066265) as geog3"""
        )

        with open(f"{here}/fixtures/quadint_boundary_out.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        for idx, result in enumerate(results):
            assert str(result[0]) == lines[idx].rstrip()

    def test_boundary_null_failure(self):
        """Test that NULL argument raises error"""
        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADINT_BOUNDARY(NULL)")
        assert "NULL argument passed to UDF" in str(excinfo.value)
