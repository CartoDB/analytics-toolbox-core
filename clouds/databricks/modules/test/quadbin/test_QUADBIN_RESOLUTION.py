# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_resolution():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_RESOLUTION(5209574053332910079)')

    assert result[0][0] == 4


def test_quadbin_resolution_null():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_RESOLUTION(NULL)')

    assert result[0][0] is None
