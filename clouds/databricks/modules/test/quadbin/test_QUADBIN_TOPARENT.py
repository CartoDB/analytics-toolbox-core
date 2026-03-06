# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079


def test_quadbin_toparent():
    result = run_query(f"SELECT @@DB_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, 3)")

    assert result[0][0] == 5205105638077628415


def test_quadbin_toparent_null():
    result = run_query(
        "SELECT"
        f"    @@DB_SCHEMA@@.QUADBIN_TOPARENT(NULL, 3),"
        f"    @@DB_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, NULL)"
    )

    assert result[0][0] is None
    assert result[0][1] is None


def test_quadbin_toparent_negative_resolution():
    """Negative resolution returns NULL (invalid)."""
    result = run_query(f"SELECT @@DB_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, -1)")

    assert result[0][0] is None


def test_quadbin_toparent_resolution_overflow():
    """Resolution > 26 returns NULL (invalid)."""
    result = run_query(f"SELECT @@DB_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, 27)")

    assert result[0][0] is None
