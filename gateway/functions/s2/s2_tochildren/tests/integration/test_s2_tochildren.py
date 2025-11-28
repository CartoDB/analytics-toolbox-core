import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_tochildren():
    """Test S2_TOCHILDREN gets children cells at various resolutions"""
    results = run_query(
        """WITH context AS(
            SELECT
            -7843177080740118528 AS id,
            *
            FROM generate_series(8, 12) resolution
        )
        SELECT @@RS_SCHEMA@@.S2_TOCHILDREN(id, resolution) AS children_ids
        FROM context;"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_tochildren_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
