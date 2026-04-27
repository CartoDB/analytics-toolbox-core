# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079
QUADBIN_LEVEL_0 = 5192650370358181887


def test_quadbin_sibling_up():
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING({QUADBIN_INDEX}, 'up') FROM DUAL",
    )

    assert result[0][0] == 5208061125333090303


def test_quadbin_sibling_down():
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING({QUADBIN_INDEX}, 'down') FROM DUAL",
    )

    assert result[0][0] == 5209609237704998911


def test_quadbin_sibling_left():
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING({QUADBIN_INDEX}, 'left') FROM DUAL",
    )

    assert result[0][0] == 5209556461146865663


def test_quadbin_sibling_right():
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING({QUADBIN_INDEX}, 'right') FROM DUAL",
    )

    assert result[0][0] == 5209626829891043327


def test_quadbin_sibling_none():
    """Level-0 quadbin has no upward sibling (y goes out of bounds)."""
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING({QUADBIN_LEVEL_0}, 'up') FROM DUAL",
    )

    assert result[0][0] is None


def test_quadbin_sibling_wrong_direction():
    try:
        run_query(
            'SELECT @@ORA_SCHEMA@@.QUADBIN_SIBLING('
            f"{QUADBIN_INDEX}, 'wrong') FROM DUAL",
        )
        assert False, 'Expected an error for wrong direction'
    except Exception as e:
        assert 'Wrong direction' in str(e), f'Unexpected error: {e}'
