# Copyright (c) 2026, CARTO

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..', 'common'))
from run_query import run_query


QUADBIN_INDEX = 5209574053332910079

EXPECTED_KRING_DISTANCES = [
    {'index': 5208043533147045887, 'distance': 1},
    {'index': 5208061125333090303, 'distance': 1},
    {'index': 5208113901891223551, 'distance': 1},
    {'index': 5209556461146865663, 'distance': 1},
    {'index': 5209574053332910079, 'distance': 0},
    {'index': 5209626829891043327, 'distance': 1},
    {'index': 5209591645518954495, 'distance': 1},
    {'index': 5209609237704998911, 'distance': 1},
    {'index': 5209662014263132159, 'distance': 1},
]


def _parse_kring_distances(raw):
    """Parse a KRING_DISTANCES result into a sorted list of dicts."""
    if hasattr(raw, 'read'):
        raw = raw.read()
    items = json.loads(raw) if isinstance(raw, str) else raw
    return sorted(items, key=lambda x: x['index'])


def test_quadbin_kring_distances():
    result = run_query(
        f'SELECT @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES({QUADBIN_INDEX}, 1) FROM DUAL',
        fetch=True,
    )

    kring_distances = _parse_kring_distances(result[0][0])
    sorted_expected = sorted(EXPECTED_KRING_DISTANCES, key=lambda x: x['index'])

    assert len(kring_distances) == len(sorted_expected)
    for actual, expected in zip(kring_distances, sorted_expected):
        assert actual['index'] == expected['index']
        assert actual['distance'] == expected['distance']


def test_quadbin_kring_distances_null():
    result = run_query(
        'SELECT'
        '    @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES(NULL, 1),'
        f'    @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES({QUADBIN_INDEX}, NULL)'
        ' FROM DUAL',
        fetch=True,
    )

    assert result[0][0] is None
    assert result[0][1] is None
