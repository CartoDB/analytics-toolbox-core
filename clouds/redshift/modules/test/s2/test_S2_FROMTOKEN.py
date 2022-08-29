import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_fromtoken_success():
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

    with open(f'{here}/fixtures/s2_fromtoken_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_s2_fromtoken_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_FROMTOKEN(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
