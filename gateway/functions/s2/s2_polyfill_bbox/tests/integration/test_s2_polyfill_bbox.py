import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_polyfill_bbox():
    """Test S2_POLYFILL_BBOX fills bounding boxes with S2 cells"""
    results = run_query(
        """WITH resContext AS(
            SELECT
              -3.69 AS min_lng,
              -3.68 AS max_lng,
              40.41 AS min_lat,
              40.42 AS max_lat,
              0 AS min_res,
              30 AS max_res UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 0, 2 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 3, 17 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 8, 25 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 12, 12 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 6, 6 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 1, 29 UNION ALL
            SELECT -3.69, -3.68, 40.41, 40.42, 4, 8
        )
        SELECT @@RS_SCHEMA@@.S2_POLYFILL_BBOX(
            min_lng, max_lng, min_lat, max_lat, min_res, max_res
        ) as ids
        FROM resContext;"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_polyfill_bbox_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
