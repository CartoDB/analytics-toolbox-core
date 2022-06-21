from test_utils import run_query, redshift_connector
import pytest


def test_boundary_success():
    results = run_query(
        """SELECT @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(2943806043928395776) as geog1,
        @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(5249649090228125696) as geog2,
        @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(7267261723292729856) as geog3"""
    )

    fixture_file = open('./test/integration/boundary_fixtures/out/geojsons.txt', 'r')
    lines = fixture_file.readlines()
    fixture_file.close()

    for idx, result in enumerate(results):
        assert str(result[0]) == lines[idx].rstrip()


def test_boundary_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@carto.QUADBIN_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
