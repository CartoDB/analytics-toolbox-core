import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_fromhilbertquadkey():
    """Test S2_FROMHILBERTQUADKEY converts Hilbert quadkeys to cell IDs"""
    results = run_query("""WITH context AS(
            SELECT '4/' AS hilbert_quadkey UNION ALL
            SELECT '4/2' UNION ALL
            SELECT '4/21' UNION ALL
            SELECT '4/212' UNION ALL
            SELECT '4/2121' UNION ALL
            SELECT '4/21210' UNION ALL
            SELECT '4/212103' UNION ALL
            SELECT '4/2121032' UNION ALL
            SELECT '4/21210323'
        )
        SELECT @@RS_SCHEMA@@.S2_FROMHILBERTQUADKEY(hilbert_quadkey) AS id
        FROM context;""")

    fixture_path = os.path.join(here, "fixtures/s2_fromhilbertquadkey_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
