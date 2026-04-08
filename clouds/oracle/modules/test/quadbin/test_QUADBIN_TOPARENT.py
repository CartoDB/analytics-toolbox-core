# Copyright (c) 2026, CARTO

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


QUADBIN_INDEX = 5209574053332910079

# Resolution-26 quadbin from the FROMLONGLAT highest-resolution test
QUADBIN_RES26 = 5306319089810035706


def test_quadbin_toparent():
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT(5209574053332910079, 3) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] == 5205105638077628415


def test_quadbin_toparent_null():
    result = run_query(
        """
        SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT(NULL, 3) FROM DUAL
        UNION ALL
        SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT(5209574053332910079, NULL) FROM DUAL
        """,
        fetch=True,
    )

    assert result[0][0] is None
    assert result[1][0] is None


def test_quadbin_toparent_negative_resolution():
    """Negative resolution returns NULL (invalid)."""
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, -1) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None


def test_quadbin_toparent_resolution_overflow():
    """Resolution > 26 returns NULL (invalid)."""
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, 27) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None


def test_quadbin_toparent_resolution_larger_than_index():
    """Resolution larger than the index's own resolution returns NULL."""
    # QUADBIN_INDEX is at resolution 4; requesting parent at resolution 5 is invalid
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_INDEX}, 5) FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None


def test_quadbin_toparent_high_resolution():
    """TOPARENT works at maximum resolution (26 -> 25) without integer overflow."""
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_TOPARENT({QUADBIN_RES26}, 25) FROM DUAL',
        fetch=True,
    )

    parent = result[0][0]
    assert parent is not None

    res_result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_RESOLUTION({parent}) FROM DUAL',
        fetch=True,
    )
    assert res_result[0][0] == 25
