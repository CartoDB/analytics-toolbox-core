import os
import pytest
from test_utils.integration.redshift import run_query

here = os.path.dirname(__file__)


@pytest.mark.integration
def test_s2_touint64repr():
    """Test S2_TOUINT64REPR converts cell IDs to UINT64 string representation"""
    results = run_query(
        """WITH context AS(
            SELECT -8070450532247928832 AS id UNION ALL
            SELECT -7782220156096217088 UNION ALL
            SELECT -7854277750134145024 UNION ALL
            SELECT -7836263351624663040 UNION ALL
            SELECT -7840766951252033536 UNION ALL
            SELECT -7844144650972561408 UNION ALL
            SELECT -7843300226042429440 UNION ALL
            SELECT -7843229857298251776 UNION ALL
            SELECT -7843177080740118528
        )
        SELECT @@RS_SCHEMA@@.S2_TOUINT64REPR(id) AS uint64_id
        FROM context;"""
    )

    fixture_path = os.path.join(here, "fixtures/s2_touint64repr_out.txt")
    with open(fixture_path, "r") as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()
