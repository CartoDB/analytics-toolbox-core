# Copyright (c) 2026, CARTO

import json

from test_utils import run_query


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


def test_quadbin_kring_distances():
    result = run_query(
        'SELECT @@DB_SCHEMA@@.QUADBIN_KRING_DISTANCES(    5209574053332910079, 1)'
    )

    raw = result[0][0]
    kring_distances = json.loads(raw) if isinstance(raw, str) else raw
    sorted_result = sorted(kring_distances, key=lambda x: x['index'])
    sorted_expected = sorted(EXPECTED_KRING_DISTANCES, key=lambda x: x['index'])

    assert len(sorted_result) == len(sorted_expected)
    for actual, expected in zip(sorted_result, sorted_expected):
        assert actual['index'] == expected['index']
        assert actual['distance'] == expected['distance']


def test_quadbin_kring_distances_null():
    result = run_query(
        'SELECT'
        '    @@DB_SCHEMA@@.QUADBIN_KRING_DISTANCES(NULL, 1),'
        '    @@DB_SCHEMA@@.QUADBIN_KRING_DISTANCES(5209574053332910079, NULL)'
    )

    assert result[0][0] is None
    assert result[0][1] is None
