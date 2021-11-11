from test_utils import run_query, redshift_connector
import pytest


def test_id_fromuint64repr_success():
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
        SELECT @@RS_PREFIX@@carto.S2_IDFROMUINT64REPR(uint64_id) AS id
        FROM context;"""
    )

    fixture_file = open(
        './test/integration/id_fromuint64repr_fixtures/out/ids.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_id_fromuint64repr_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.S2_IDFROMUINT64REPR(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
