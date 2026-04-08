# Copyright (c) 2026, CARTO

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


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


def _parse_kring(raw):
    """Parse a KRING result into a sorted list of quadbin indices."""
    if hasattr(raw, 'read'):
        raw = raw.read()
    return sorted(json.loads(raw) if isinstance(raw, str) else raw)


def test_quadbin_kring():
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_KRING({QUADBIN_INDEX}, 1) FROM DUAL',
        fetch=True,
    )

    kring = _parse_kring(result[0][0])
    assert kring == EXPECTED_KRING


def test_quadbin_kring_distance_zero():
    """Distance 0 returns only the origin cell."""
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_KRING({QUADBIN_INDEX}, 0) FROM DUAL',
        fetch=True,
    )

    kring = _parse_kring(result[0][0])
    assert kring == [QUADBIN_INDEX]


def test_quadbin_kring_null():
    result = run_query(
        'SELECT'
        '    @@ORA_SCHEMA@@.QUADBIN_KRING(NULL, 1),'
        f'    @@ORA_SCHEMA@@.QUADBIN_KRING({QUADBIN_INDEX}, NULL)'
        ' FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None
    assert result[0][1] is None
