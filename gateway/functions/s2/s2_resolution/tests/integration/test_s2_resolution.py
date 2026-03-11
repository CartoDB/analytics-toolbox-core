import pytest
from test_utils.integration.redshift import run_query


@pytest.mark.integration
def test_s2_resolution():
    """Test S2_RESOLUTION returns the resolution level of S2 cells"""
    results = run_query("""WITH context AS(
            SELECT -8070450532247928832 AS res UNION ALL
            SELECT -7782220156096217088 UNION ALL
            SELECT -7854277750134145024 UNION ALL
            SELECT -7836263351624663040 UNION ALL
            SELECT -7840766951252033536 UNION ALL
            SELECT -7844144650972561408 UNION ALL
            SELECT -7843300226042429440 UNION ALL
            SELECT -7843229857298251776 UNION ALL
            SELECT -7843177080740118528
        )
        SELECT @@RS_SCHEMA@@.S2_RESOLUTION(res) AS resolution
        FROM context;""")

    for idx, result in enumerate(results):
        assert result[0] == idx
