# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromlonglat():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 85.05112877980659, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 88, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 90, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -85.05112877980659, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -88, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -90, 26)'
    )

    assert result[0][0] == 5209574053332910079
    assert result[0][1] == 5306366260949286912
    assert result[0][2] == 5306366260949286912
    assert result[0][3] == 5306366260949286912
    assert result[0][4] == 5309368660700867242
    assert result[0][5] == 5309368660700867242
    assert result[0][6] == 5309368660700867242


def test_quadbin_fromlonglat_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, NULL, 4),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL)'
    )

    assert result[0][0] is None
    assert result[0][1] is None
    assert result[0][2] is None


def test_quadbin_fromlonglat_invalid_resolution():
    try:
        run_query('SELECT @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, -1)')
        assert False, 'Expected an error for negative resolution'
    except Exception as e:
        assert 'Invalid resolution' in str(e), f'Unexpected error: {e}'


def test_quadbin_fromlonglat_resolution_overflow():
    try:
        run_query('SELECT @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 27)')
        assert False, 'Expected an error for resolution > 26'
    except Exception as e:
        assert 'Invalid resolution' in str(e), f'Unexpected error: {e}'


def test_quadbin_fromlonglat_highest_resolution():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        -3.71219873428345, 40.413365349070865, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        40.413365349070865, -3.71219873428345, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 3.552713678800501e-15, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, -3.552713678800501e-15, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        -89.71219873428345, -84.413365349070865, 26)'
    )

    # Swapped lon/lat
    assert result[0][0] == 5306319089810035706
    assert result[0][1] == 5308641755410858449
    # Near-zero positive/negative latitude (epsilon symmetry at equator)
    assert result[0][2] == 5308618060762972160
    assert result[0][3] == 5308618060762972160
    # Extreme negative coordinates (near south pole)
    assert result[0][4] == 5308521992464067502


def test_quadbin_fromlonglat_highest_resolution_fp_stability():
    """Slightly different latitudes that should all map to the same quadbin."""
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 5.3644180297851546e-06, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 5.364418029785155e-06, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 5.364418029785156e-06, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 5.364418029785157e-06, 26),'
        '    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT('
        '        0.0, 5.364418029785158e-06, 26)'
    )

    expected_quadbin = 5307116860887181994
    for i in range(5):
        assert result[0][i] == expected_quadbin
