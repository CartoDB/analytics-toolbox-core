import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_boundary():
    """Test S2_BOUNDARY returns WKT polygons for S2 cells"""
    results = run_query(
        """SELECT @@RS_SCHEMA@@.S2_BOUNDARY(955484400630366208) as geog1,
        @@RS_SCHEMA@@.S2_BOUNDARY(936748722493063168) as geog2,
        @@RS_SCHEMA@@.S2_BOUNDARY(5731435257080539263) as geog3"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_boundary_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results[0]):
        assert str(result) == lines[idx].rstrip()
