import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_fromhilbertquadkey_success():
    results = run_query(
        """WITH context AS(
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
        FROM context;"""
    )

    with open(f'{here}/fixtures/s2_fromhilbertquadkey_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_s2_fromhilbertquadkey_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_FROMHILBERTQUADKEY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
