from test_utils import run_query, redshift_connector
import pytest


def test_id_fromhilbertquadkey_success():
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
        SELECT @@RS_PREFIX@@carto.S2_FROMHILBERTQUADKEY(hilbert_quadkey) AS id
        FROM context;"""
    )

    fixture_file = open(
        './test/integration/id_fromhilbertquadkey_fixtures/out/ids.txt', 'r'
    )
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_id_fromhilbertquadkey_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.S2_FROMHILBERTQUADKEY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
