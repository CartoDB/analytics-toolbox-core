# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


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


def test_quadbin_kring():
    result = run_query('SELECT @@DB_SCHEMA@@.QUADBIN_KRING(5209574053332910079, 1)')

    raw = result[0][0]
    kring = sorted(json.loads(raw) if isinstance(raw, str) else raw)
    assert kring == EXPECTED_KRING


def test_quadbin_kring_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_KRING(NULL, 1),'
        '    @@DB_SCHEMA@@.QUADBIN_KRING(5209574053332910079, NULL)'
    )

    assert result[0][0] is None
    assert result[0][1] is None
