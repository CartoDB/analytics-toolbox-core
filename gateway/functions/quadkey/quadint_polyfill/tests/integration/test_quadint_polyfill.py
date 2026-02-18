"""Integration tests for QUADINT_POLYFILL function"""

import os
import json
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
class TestQuadintPolyfillIntegration:
    """Integration tests for QUADINT_POLYFILL with Redshift"""

    def test_polyfill_success(self):
        """Test polyfilling a geometry with quadints"""
        with open(f"{here}/fixtures/quadint_polyfill_in.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        fixture_file.close()
        feature_wkt = lines[0].rstrip()

        result = run_query(f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
                ST_GeomFromText('{feature_wkt}'), 10) UNION ALL
            SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
                ST_GeomFromText('{feature_wkt}'), 14)""")

        with open(f"{here}/fixtures/quadint_polyfill_out.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        # polyfill10 - compare sorted arrays since order is not guaranteed
        result_array_10 = sorted(json.loads(result[0][0]))
        expected_array_10 = sorted(json.loads(lines[0].rstrip()))
        assert result_array_10 == expected_array_10

        # polyfill14 - compare sorted arrays since order is not guaranteed
        result_array_14 = sorted(json.loads(result[1][0]))
        expected_array_14 = sorted(json.loads(lines[1].rstrip()))
        assert result_array_14 == expected_array_14

    def test_polyfill_collection_success(self):
        """Test polyfilling a GeometryCollection"""
        with open(f"{here}/fixtures/quadint_polyfill_in.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        feature_wkt = lines[1].rstrip()

        result = run_query(f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
                ST_GeomFromText('{feature_wkt}'), 22)""")

        with open(f"{here}/fixtures/quadint_polyfill_out.txt", "r") as fixture_file:
            lines = fixture_file.readlines()

        # polyfill22 - compare sorted arrays since order is not guaranteed
        result_array_22 = sorted(json.loads(result[0][0]))
        expected_array_22 = sorted(json.loads(lines[2].rstrip()))
        assert result_array_22 == expected_array_22

    def test_polyfill_failure(self):
        """Test that NULL arguments raise errors"""
        with pytest.raises(Exception) as excinfo:
            run_query("SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(NULL, 10)")
        assert "NULL argument passed to UDF" in str(excinfo.value)

        feature_wkt = "POINT(10 2)"
        with pytest.raises(Exception) as excinfo:
            run_query(f"""SELECT @@RS_SCHEMA@@.QUADINT_POLYFILL(
                    ST_GeomFromText('{feature_wkt}'), NULL)""")
        assert "NULL argument passed to UDF" in str(excinfo.value)
