import os
import pytest

from test_utils import run_query, redshift_connector

here = os.path.dirname(__file__)


def test_s2_fromuint64repr_success():
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

    with open(f'{here}/fixtures/s2_fromuint64repr_out.txt', 'r') as fixture_file:
        lines = fixture_file.readlines()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_s2_fromuint64repr_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_SCHEMA@@.S2_FROMUINT64REPR(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
