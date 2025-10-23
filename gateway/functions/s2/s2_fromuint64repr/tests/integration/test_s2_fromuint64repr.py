import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_fromuint64repr():
    """Test S2_FROMUINT64REPR converts UINT64 string to cell IDs"""
    results = run_query(
        """WITH context AS(
            SELECT '10376293541461622784' AS uint64_id UNION ALL
            SELECT '10664523917613334528' UNION ALL
            SELECT '10592466323575406592' UNION ALL
            SELECT '10610480722084888576' UNION ALL
            SELECT '10605977122457518080' UNION ALL
            SELECT '10602599422736990208' UNION ALL
            SELECT '10603443847667122176' UNION ALL
            SELECT '10603514216411299840' UNION ALL
            SELECT '10603566992969433088'
        )
        SELECT @@RS_SCHEMA@@.S2_FROMUINT64REPR(uint64_id) AS id
        FROM context;"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_fromuint64repr_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
