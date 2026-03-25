# Copyright (c) 2026, CARTO

from test_utils import run_query


TOLERANCE = 1e-6


def test_quadbin_center():
    result = run_query(
        'SELECT'
        '    ST_X(@@DB_SCHEMA@@.QUADBIN_CENTER(5209574053332910079)),'
        '    ST_Y(@@DB_SCHEMA@@.QUADBIN_CENTER(5209574053332910079))'
    )

    assert abs(result[0][0] - 33.75) < TOLERANCE
    assert abs(result[0][1] - (-11.178401873711792)) < TOLERANCE


def test_quadbin_center_srid():
    result = run_query(
        'SELECT ST_SRID(@@DB_SCHEMA@@.QUADBIN_CENTER(5209574053332910079))'
    )

    assert result[0][0] == 4326


def test_quadbin_center_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_CENTER(NULL)')

    assert result[0][0] is None
