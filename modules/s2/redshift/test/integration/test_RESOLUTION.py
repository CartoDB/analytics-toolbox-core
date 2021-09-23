from test_utils import run_query, redshift_connector
import pytest


def test_resolution_success():
    results = run_query(
        """WITH context AS(
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
        SELECT @@RS_PREFIX@@s2.RESOLUTION(res) AS resolution
        FROM context;"""
    )

    for idx, result in enumerate(results):
        assert result[0] == idx


def test_resolution_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.RESOLUTION(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
