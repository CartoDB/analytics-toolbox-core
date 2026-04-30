# Copyright (c) 2026, CARTO

from test_utils import run_query


# Note: In Oracle '' IS NULL, so the zoom-0 quadbin's quadkey (empty string)
# is returned as NULL. The zoom-0 quadbin is tested separately below.

QUADBIN_QUADKEY_PAIRS = [
    (5193776270265024511, '0'),
    (5226184719091105791, '13020310'),
    (5233974874938015743, '0231001222'),
]

ZOOM_0_QUADBIN = 5192650370358181887


def test_quadbin_toquadkey():
    for quadbin, expected_quadkey in QUADBIN_QUADKEY_PAIRS:
        result = run_query(
            f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY({quadbin}) FROM DUAL',
        )

        assert (
            result[0][0] == expected_quadkey
        ), f"TOQUADKEY({quadbin}): expected '{expected_quadkey}', got '{result[0][0]}'"


def test_quadbin_toquadkey_zoom0():
    """Zoom-0 quadbin returns empty string, which is NULL in Oracle."""
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY({ZOOM_0_QUADBIN}) FROM DUAL',
    )

    # In Oracle '' IS NULL, so TOQUADKEY at zoom 0 returns NULL
    assert result[0][0] is None


def test_quadbin_toquadkey_null():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY(NULL) FROM DUAL',
    )

    assert result[0][0] is None


def test_quadbin_toquadkey_roundtrip():
    """Verify TOQUADKEY -> FROMQUADKEY roundtrip returns original quadbin."""
    for quadbin, _ in QUADBIN_QUADKEY_PAIRS:
        result = run_query(
            f"""SELECT @@ORA_SCHEMA@@.QUADBIN_FROMQUADKEY(
                @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY({quadbin})
            ) FROM DUAL""",
        )

        assert (
            result[0][0] == quadbin
        ), f'Roundtrip for {quadbin}: expected {quadbin}, got {result[0][0]}'
