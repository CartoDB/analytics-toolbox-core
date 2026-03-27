# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromgeogpoint():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT('
        '    ST_POINT(40.4168, -3.7038, 4326), 4'
        ')'
    )

    assert result[0][0] == 5209574053332910079


def test_quadbin_fromgeogpoint_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT(NULL, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT('
        '        ST_POINT(40.4168, -3.7038, 4326), NULL'
        '    )'
    )

    assert result[0][0] is None
    assert result[0][1] is None
