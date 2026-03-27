# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079
TOLERANCE = 1e-6

# Expected boundary coordinates for quadbin 5209574053332910079
EXPECTED_WEST = 22.5
EXPECTED_SOUTH = -21.943045533438166
EXPECTED_EAST = 45.0
EXPECTED_NORTH = 0.0


def test_quadbin_boundary():
    result = run_query(
        f'SELECT ST_ASTEXT(@@DB_SCHEMA@@.QUADBIN_BOUNDARY({QUADBIN_INDEX}))'
    )

    boundary_wkt = result[0][0]
    assert boundary_wkt is not None
    assert 'POLYGON' in boundary_wkt


def test_quadbin_boundary_srid():
    result = run_query(
        f'SELECT ST_SRID(@@DB_SCHEMA@@.QUADBIN_BOUNDARY({QUADBIN_INDEX}))'
    )

    assert result[0][0] == 4326


def test_quadbin_boundary_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_BOUNDARY(NULL)')

    assert result[0][0] is None
