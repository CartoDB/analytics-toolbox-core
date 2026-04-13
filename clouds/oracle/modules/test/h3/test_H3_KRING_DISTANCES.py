# Copyright (c) 2026, CARTO
import json
import pytest
from test_utils import run_query


def index_key(item):
    """Sort key for distance entries."""
    return item['index']


def test_h3_kring_distances_distance_0():
    """K-ring distances with distance 0 returns origin at distance 0."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
        "'8928308280fffff', 0) FROM DUAL"
    )
    assert len(result) == 1
    entries = json.loads(result[0][0])
    assert entries == [{'index': '8928308280fffff', 'distance': 0}]


def test_h3_kring_distances_distance_1():
    """K-ring distances with distance 1 returns 7 entries with correct distances."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
        "'8928308280fffff', 1) FROM DUAL"
    )
    assert len(result) == 1
    entries = json.loads(result[0][0])
    expected = [
        {'index': '8928308280fffff', 'distance': 0},
        {'index': '89283082803ffff', 'distance': 1},
        {'index': '89283082807ffff', 'distance': 1},
        {'index': '8928308280bffff', 'distance': 1},
        {'index': '89283082873ffff', 'distance': 1},
        {'index': '89283082877ffff', 'distance': 1},
        {'index': '8928308283bffff', 'distance': 1},
    ]
    assert sorted(entries, key=index_key) == sorted(expected, key=index_key)


def test_h3_kring_distances_distance_2():
    """K-ring distances with distance 2 returns 19 entries with correct distances."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
        "'8928308280fffff', 2) FROM DUAL"
    )
    assert len(result) == 1
    entries = json.loads(result[0][0])
    expected = [
        {'index': '8928308280fffff', 'distance': 0},
        {'index': '89283082803ffff', 'distance': 1},
        {'index': '89283082807ffff', 'distance': 1},
        {'index': '8928308280bffff', 'distance': 1},
        {'index': '89283082873ffff', 'distance': 1},
        {'index': '89283082877ffff', 'distance': 1},
        {'index': '8928308283bffff', 'distance': 1},
        {'index': '89283082813ffff', 'distance': 2},
        {'index': '89283082817ffff', 'distance': 2},
        {'index': '8928308281bffff', 'distance': 2},
        {'index': '89283082823ffff', 'distance': 2},
        {'index': '8928308282bffff', 'distance': 2},
        {'index': '89283082833ffff', 'distance': 2},
        {'index': '89283082847ffff', 'distance': 2},
        {'index': '89283082857ffff', 'distance': 2},
        {'index': '89283082863ffff', 'distance': 2},
        {'index': '89283082867ffff', 'distance': 2},
        {'index': '8928308287bffff', 'distance': 2},
        {'index': '892830828abffff', 'distance': 2},
    ]
    assert sorted(entries, key=index_key) == sorted(expected, key=index_key)


def test_h3_kring_distances_all_unique():
    """All index values in the result should be unique."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
        "'8928308280fffff', 2) FROM DUAL"
    )
    entries = json.loads(result[0][0])
    indexes = [e['index'] for e in entries]
    assert len(indexes) == len(set(indexes))


def test_h3_kring_distances_null_origin():
    """Raises error when origin is NULL."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            'SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES(NULL, 1) FROM DUAL'
        )
    assert 'Invalid input origin' in str(excinfo.value)


def test_h3_kring_distances_invalid_origin():
    """Raises error when origin is not a valid H3 index."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES('abc', 1)"
            " FROM DUAL"
        )
    assert 'Invalid input origin' in str(excinfo.value)


def test_h3_kring_distances_null_size():
    """Raises error when size is NULL."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
            "'8928308280fffff', NULL) FROM DUAL"
        )
    assert 'Invalid input size' in str(excinfo.value)


def test_h3_kring_distances_negative_size():
    """Raises error when size is negative."""
    with pytest.raises(Exception) as excinfo:
        run_query(
            "SELECT @@ORA_SCHEMA@@.H3_KRING_DISTANCES("
            "'8928308280fffff', -1) FROM DUAL"
        )
    assert 'Invalid input size' in str(excinfo.value)
