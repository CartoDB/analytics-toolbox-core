# Copyright (c) 2026, CARTO

from test_utils import run_query


QUADBIN_INDEX = 5209574053332910079

EXPECTED_KRING_DISTANCES = sorted(
    [
        (5208043533147045887, 1),
        (5208061125333090303, 1),
        (5208113901891223551, 1),
        (5209556461146865663, 1),
        (5209574053332910079, 0),
        (5209626829891043327, 1),
        (5209591645518954495, 1),
        (5209609237704998911, 1),
        (5209662014263132159, 1),
    ]
)


def test_quadbin_kring_distances():
    rows = run_query(
        f"""SELECT t.quadbin_index, t.distance
        FROM TABLE(
            @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES({QUADBIN_INDEX}, 1)
        ) t"""
    )
    actual = sorted((int(r[0]), int(r[1])) for r in rows)
    assert actual == EXPECTED_KRING_DISTANCES


def test_quadbin_kring_distances_null():
    """NULL inputs yield an empty pipeline (zero rows)."""
    rows = run_query(
        f"""SELECT t.quadbin_index, t.distance
        FROM TABLE(
            @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES(NULL, 1)
        ) t
        UNION ALL
        SELECT t.quadbin_index, t.distance
        FROM TABLE(
            @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES({QUADBIN_INDEX}, NULL)
        ) t"""
    )
    assert rows == [] or rows == 'No results returned'
