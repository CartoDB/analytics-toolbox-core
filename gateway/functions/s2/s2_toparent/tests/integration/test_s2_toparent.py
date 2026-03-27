import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_toparent():
    """Test S2_TOPARENT gets parent cells at various resolutions"""
    results = run_query("""WITH context AS(
            SELECT
            -7843177080740118528 AS id,
            *
            FROM generate_series(0, 8) resolution
        )
        SELECT @@RS_SCHEMA@@.S2_TOPARENT(id, resolution) AS parent_id
        FROM context;""")

    fixture_path = os.path.join(here, "fixtures/s2_toparent_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
