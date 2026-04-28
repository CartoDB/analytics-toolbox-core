# Copyright (c) 2026, CARTO

from test_utils import run_query


def test_quadbin_fromlonglat():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 4) FROM DUAL
        """,
    )
    assert result[0][0] == 5209574053332910079


def test_quadbin_fromlonglat_high_latitude():
    result = run_query(
        """
        SELECT
            @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 85.05112877980659, 26)
        FROM DUAL
        """,
    )
    assert result[0][0] == 5306366260949286912


def test_quadbin_fromlonglat_clamped_positive():
    """Latitudes above 89 should be clamped to 89."""
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 88, 26) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, 90, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5306366260949286912
    assert result[1][0] == 5306366260949286912


def test_quadbin_fromlonglat_high_negative_latitude():
    result = run_query(
        """
        SELECT
            @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -85.05112877980659, 26)
        FROM DUAL
        """,
    )
    assert result[0][0] == 5309368660700867242


def test_quadbin_fromlonglat_clamped_negative():
    """Latitudes below -89 should be clamped to -89."""
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -88, 26) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(0, -90, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5309368660700867242
    assert result[1][0] == 5309368660700867242


def test_quadbin_fromlonglat_null():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(NULL, -3.7038, 4) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, NULL, 4) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, NULL) FROM DUAL
        """,
    )
    assert result[0][0] is None
    assert result[1][0] is None
    assert result[2][0] is None


def test_quadbin_fromlonglat_invalid_resolution():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, -1) FROM DUAL',
    )
    assert result[0][0] is None


def test_quadbin_fromlonglat_resolution_overflow():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(40.4168, -3.7038, 27) FROM DUAL',
    )
    assert result[0][0] is None


def test_quadbin_fromlonglat_highest_resolution():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            -3.71219873428345, 40.413365349070865, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5306319089810035706

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            40.413365349070865, -3.71219873428345, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5308641755410858449

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 3.552713678800501e-15, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5308618060762972160

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, -3.552713678800501e-15, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5308618060762972160

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            -89.71219873428345, -84.413365349070865, 26) FROM DUAL
        """,
    )
    assert result[0][0] == 5308521992464067502


def test_quadbin_fromlonglat_highest_resolution_fp_stability():
    """Slightly different latitudes that should all map to the same quadbin."""
    expected_quadbin = 5307116860887181994

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 5.3644180297851546e-06, 26) FROM DUAL
        """,
    )
    assert result[0][0] == expected_quadbin

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 5.364418029785155e-06, 26) FROM DUAL
        """,
    )
    assert result[0][0] == expected_quadbin

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 5.364418029785156e-06, 26) FROM DUAL
        """,
    )
    assert result[0][0] == expected_quadbin

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 5.364418029785157e-06, 26) FROM DUAL
        """,
    )
    assert result[0][0] == expected_quadbin

    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
            0.0, 5.364418029785158e-06, 26) FROM DUAL
        """,
    )
    assert result[0][0] == expected_quadbin
