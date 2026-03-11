# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_distance():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_DISTANCE('
        '    5207251884775047167, 5207128739472736255'
        ')'
    )

    assert result[0][0] == 1


def test_quadbin_distance_same_index():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_DISTANCE('
        '    5209574053332910079, 5209574053332910079'
        ')'
    )

    assert result[0][0] == 0


def test_quadbin_distance_different_resolution():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_DISTANCE('
        '    5209574053332910079, 5205105638077628415'
        ')'
    )

    assert result[0][0] is None


def test_quadbin_distance_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_DISTANCE(NULL, 5207128739472736255),'
        '    @@DB_SCHEMA@@.QUADBIN_DISTANCE(5207251884775047167, NULL)'
    )

    assert result[0][0] is None
    assert result[0][1] is None
