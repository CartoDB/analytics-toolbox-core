from test_utils import run_query, redshift_connector
import pytest


def test_boundary_success():
    result = run_query(
        'SELECT @@RS_PREFIX@@quadkey.ST_BOUNDARY(12070922) as geog1, '
        '@@RS_PREFIX@@quadkey.ST_BOUNDARY(791040491538) as geog2, '
        '@@RS_PREFIX@@quadkey.ST_BOUNDARY(12960460429066265) as geog3'
    )

    assert (
        result[0][0]
        == "{'type': 'Polygon', 'coordinates': [[[-45.0, 44.84029065139799], [-45.0, 45.089035564831015], [-44.6484375, 45.089035564831015], [-44.6484375, 44.84029065139799], [-45.0, 44.84029065139799]]]}"
    )
    assert (
        result[0][1]
        == "{'type': 'Polygon', 'coordinates': [[[-45.0, 44.99976701918129], [-45.0, 45.000738078290674], [-44.998626708984375, 45.000738078290674], [-44.998626708984375, 44.99976701918129], [-45.0, 44.99976701918129]]]}"
    )
    assert (
        result[0][2]
        == "{'type': 'Polygon', 'coordinates': [[[-45.0, 44.99999461263668], [-45.0, 45.00000219906962], [-44.99998927116394, 45.00000219906962], [-44.99998927116394, 44.99999461263668], [-45.0, 44.99999461263668]]]}"
    )


def test_boundary_null_failure():
    with pytest.raises(redshift_connector.error.ProgrammingError) as excinfo:
        run_query('SELECT @@RS_PREFIX@@quadkey.ST_BOUNDARY(NULL)')
    assert 'NULL argument passed to UDF' in str(excinfo.value)
