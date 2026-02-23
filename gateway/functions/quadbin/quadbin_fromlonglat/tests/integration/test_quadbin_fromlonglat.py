"""Integration tests for QUADBIN_FROMLONGLAT function"""

import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
class TestQuadbinFromlonglatIntegration:
    """Integration tests for QUADBIN_FROMLONGLAT with Redshift"""

    def test_quadbin_fromlonglat(self):
        result = run_query("""
                WITH inputs AS (
                    SELECT 1 AS ID,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4)
                        UNION ALL SELECT 2,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 85.05112877980659, 26)
                        UNION ALL SELECT 3,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 88, 26)
                        UNION ALL SELECT 4,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 90, 26)
                        UNION ALL SELECT 5,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(
                            0, -85.05112877980659, 26)
                        UNION ALL SELECT 6,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -88, 26)
                        UNION ALL SELECT 7,
                        @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -90, 26)
                )
                SELECT * FROM inputs ORDER BY id ASC""")
        assert result[0][1] == 5209574053332910079
        assert result[1][1] == 5306366260949286912
        assert result[2][1] == 5306366260949286912
        assert result[3][1] == 5306366260949286912
        assert result[4][1] == 5309368660700867242
        assert result[5][1] == 5309368660700867242
        assert result[6][1] == 5309368660700867242

    def test_quadbin_fromlonglat_null(self):
        result = run_query("""
            SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4),
                   @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, NULL, 4),
                   @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL)
        """)

        assert len(result[0]) == 3
        assert result[0][0] is None
        assert result[0][1] is None
        assert result[0][2] is None

    def test_quadbin_negative_resolution_failure(self):
        error = "Invalid resolution: should be between 0 and 26"
        with pytest.raises(Exception, match=error):
            run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, -1)")

    def test_quadbin_fromlonglat_resolution_overflow_failure(self):
        error = "Invalid resolution: should be between 0 and 26"
        with pytest.raises(Exception, match=error):
            run_query("SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 27)")

    def test_quadbin_longlat_highest_resolution(self):
        """Computes quadbin for longitude latitude at highest resolution.

        This test is useful to get a reference value to build test and check SQL
        implementation against this python implementation of quadbin
        """
        result = run_query("""
            SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(
                40.413365349070865,
                -3.71219873428345,
                26)
            """)
        assert result[0][0] == 5308641755410858449

        query = """
            SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(
                -3.71219873428345,
                40.413365349070865,
                26)
        """
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5306319089810035706

        query = """
            SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(
                40.413365349070865,
                -3.71219873428345,
                26)
        """
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5308641755410858449

        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 3.552713678800501e-15, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5308618060762972160

        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, -3.552713678800501e-15, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5308618060762972160

        query = """
            SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(
                -89.71219873428345,
                -84.413365349070865,
                26)
        """
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5308521992464067502

        # set of call giving the same result with slightly different lat
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.3644180297851546e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785155e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785156e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785157e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785158e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
        query = (
            "SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(0.0, 5.364418029785156e-06, 26)"
        )
        result = run_query(query)
        assert len(result[0]) == 1
        assert result[0][0] == 5307116860887181994
