import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_fromtoken():
    """Test S2_FROMTOKEN converts tokens to cell IDs"""
    results = run_query(
        """WITH context AS(
            SELECT '9' AS token UNION ALL
            SELECT '94' UNION ALL
            SELECT '93' UNION ALL
            SELECT '934' UNION ALL
            SELECT '933' UNION ALL
            SELECT '9324' UNION ALL
            SELECT '9327' UNION ALL
            SELECT '93274' UNION ALL
            SELECT '93277'
        )
        SELECT @@RS_SCHEMA@@.S2_FROMTOKEN(token) AS id
        FROM context;"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_fromtoken_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
