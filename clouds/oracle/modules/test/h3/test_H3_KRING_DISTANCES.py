# Copyright (c) 2026, CARTO
from test_utils import run_query


def _kring_distances(origin_sql, distance_sql):
    """Run H3_KRING_DISTANCES as a TABLE and return list of (h3, distance)."""
    sql = (
        f'SELECT t.h3, t.distance FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_KRING_DISTANCES({origin_sql}, {distance_sql})) t'
    )
    return [(r[0], int(r[1])) for r in run_query(sql)]


def test_h3_kring_distances_distance_0():
    """K-ring distances with distance 0 returns origin at distance 0."""
    assert _kring_distances("'8928308280fffff'", '0') == [
        ('8928308280fffff', 0)
    ]


def test_h3_kring_distances_distance_1():
    """K-ring distances with distance 1 returns 7 entries."""
    expected = [
        ('8928308280fffff', 0),
        ('89283082803ffff', 1), ('89283082807ffff', 1),
        ('8928308280bffff', 1), ('89283082873ffff', 1),
        ('89283082877ffff', 1), ('8928308283bffff', 1),
    ]
    actual = _kring_distances("'8928308280fffff'", '1')
    assert sorted(actual) == sorted(expected)


def test_h3_kring_distances_distance_2():
    """K-ring distances with distance 2 returns 19 entries."""
    expected = [
        ('8928308280fffff', 0),
        ('89283082803ffff', 1), ('89283082807ffff', 1),
        ('8928308280bffff', 1), ('89283082873ffff', 1),
        ('89283082877ffff', 1), ('8928308283bffff', 1),
        ('89283082813ffff', 2), ('89283082817ffff', 2),
        ('8928308281bffff', 2), ('89283082823ffff', 2),
        ('8928308282bffff', 2), ('89283082833ffff', 2),
        ('89283082847ffff', 2), ('89283082857ffff', 2),
        ('89283082863ffff', 2), ('89283082867ffff', 2),
        ('8928308287bffff', 2), ('892830828abffff', 2),
    ]
    actual = _kring_distances("'8928308280fffff'", '2')
    assert sorted(actual) == sorted(expected)


def test_h3_kring_distances_all_unique():
    """All index values in the result should be unique."""
    rows = _kring_distances("'8928308280fffff'", '2')
    indexes = [h3 for h3, _ in rows]
    assert len(indexes) == len(set(indexes))


def test_h3_kring_distances_null_origin():
    """Returns no rows when origin is NULL (NULL-on-invalid)."""
    assert _kring_distances('NULL', '1') == []


def test_h3_kring_distances_invalid_origin():
    """Returns no rows when origin is not a valid H3 index."""
    assert _kring_distances("'abc'", '1') == []


def test_h3_kring_distances_null_size():
    """Returns no rows when size is NULL."""
    assert _kring_distances("'8928308280fffff'", 'NULL') == []


def test_h3_kring_distances_negative_size():
    """Returns no rows when size is negative."""
    assert _kring_distances("'8928308280fffff'", '-1') == []
