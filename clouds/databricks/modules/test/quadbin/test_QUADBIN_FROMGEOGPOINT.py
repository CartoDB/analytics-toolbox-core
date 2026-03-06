# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromgeogpoint():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT(40.4168, -3.7038, 4)'
    )

    assert result[0][0] == 5209574053332910079


def test_quadbin_fromgeogpoint_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT(NULL, -3.7038, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT(40.4168, NULL, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT(40.4168, -3.7038, NULL)'
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None
