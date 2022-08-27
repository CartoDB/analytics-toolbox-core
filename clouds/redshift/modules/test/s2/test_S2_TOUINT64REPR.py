import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_touint64repr_success():
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

    with open(f'{here}/fixtures/s2_touint64repr_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_s2_touint64repr_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_TOUINT64REPR(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
