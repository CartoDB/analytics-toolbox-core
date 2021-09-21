from test_utils import run_query, redshift_connector
import pytest


def test_boundary_success():
    results = run_query(
        """SELECT @@RS_PREFIX@@s2.ST_BOUNDARY(955484400630366208) as geog1,
        @@RS_PREFIX@@s2.ST_BOUNDARY(936748722493063168) as geog2,
        @@RS_PREFIX@@s2.ST_BOUNDARY(5731435257080539263) as geog3"""
    )

    fixture_file = open('./test/integration/boundary_fixtures/out/wkts.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_boundary_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@s2.ST_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
