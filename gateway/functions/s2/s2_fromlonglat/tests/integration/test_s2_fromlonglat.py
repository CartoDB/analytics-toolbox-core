import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_fromlonglat():
    """Test S2_FROMLONGLAT with various coordinates and resolutions"""
    results = run_query("""WITH resContext AS(
            SELECT 0 AS res, -150 AS long, 60 AS lat UNION ALL
            SELECT 1, -150, 60 UNION ALL
            SELECT 2, 150, 60 UNION ALL
            SELECT 3, -150, -60 UNION ALL
            SELECT 4, 150, -60 UNION ALL
            SELECT 5, -30, 30 UNION ALL
            SELECT 6, 30, 30 UNION ALL
            SELECT 7, -30, -30 UNION ALL
            SELECT 8, 30, -30 UNION ALL
            SELECT 9, -100, 0 UNION ALL
            SELECT 10, 100, 0 UNION ALL
            SELECT 11, -100, 0 UNION ALL
            SELECT 12, 100, 0 UNION ALL
            SELECT 13, 0, 45 UNION ALL
            SELECT 14, 0, 45 UNION ALL
            SELECT 15, 0, -45 UNION ALL
            SELECT 16, 0, -45 UNION ALL
            SELECT 17, -70, 10 UNION ALL
            SELECT 18, 70, 10 UNION ALL
            SELECT 19, -70, -10 UNION ALL
            SELECT 20, 70, -10 UNION ALL
            SELECT 21, -10, 80 UNION ALL
            SELECT 22, 10, 80 UNION ALL
            SELECT 23, -10, -80 UNION ALL
            SELECT 24, 10, -80 UNION ALL
            SELECT 25, -45, 25 UNION ALL
            SELECT 26, 45, 25 UNION ALL
            SELECT 27, -45, -25 UNION ALL
            SELECT 28, 45, -25 UNION ALL
            SELECT 29, 0, 0 UNION ALL
            SELECT 30, -3, 40
        )
        SELECT @@RS_SCHEMA@@.S2_FROMLONGLAT(long, lat, res) as ids
            FROM resContext;""")

    fixture_path = os.path.join(here, "fixtures/s2_fromlonglat_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
