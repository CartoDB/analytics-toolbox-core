# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079

EXPECTED_KRING = sorted(
    [
        5208043533147045887,
        5208061125333090303,
        5208113901891223551,
        5209556461146865663,
        5209574053332910079,
        5209626829891043327,
        5209591645518954495,
        5209609237704998911,
        5209662014263132159,
    ]
)


def _kring(origin, distance):
    """Run QUADBIN_KRING and return a sorted list of indices."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_KRING({origin}, {distance}))"""
    )
    return sorted(int(r[0]) for r in rows)


def test_quadbin_kring():
    assert _kring(QUADBIN_INDEX, 1) == EXPECTED_KRING


def test_quadbin_kring_distance_zero():
    """Distance 0 returns only the origin cell."""
    assert _kring(QUADBIN_INDEX, 0) == [QUADBIN_INDEX]


def test_quadbin_kring_null():
    """NULL inputs yield an empty pipeline (zero rows)."""
    rows = run_query(
        f"""SELECT COLUMN_VALUE FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_KRING(NULL, 1))
        UNION ALL
        SELECT COLUMN_VALUE
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_KRING({QUADBIN_INDEX}, NULL))"""
    )
    assert rows == [] or rows == 'No results returned'
