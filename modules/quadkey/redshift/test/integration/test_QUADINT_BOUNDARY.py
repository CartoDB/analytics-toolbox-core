from test_utils import run_query, redshift_connector
import pytest


def test_boundary_success():
    results = run_query(
        """SELECT @@RS_PREFIX@@quadkey.QUADINT_BOUNDARY(12070922) as geog1,
        @@RS_PREFIX@@quadkey.QUADINT_BOUNDARY(791040491538) as geog2,
        @@RS_PREFIX@@quadkey.QUADINT_BOUNDARY(12960460429066265) as geog3"""
    )

    fixture_file = open('./test/integration/boundary_fixtures/out/geojsons.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_boundary_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@quadkey.QUADINT_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
