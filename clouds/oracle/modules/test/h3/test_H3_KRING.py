# Copyright (c) 2026, CARTO
from test_utils import run_query


def _kring(origin_sql, distance_sql):
    """Run H3_KRING as a TABLE and return the list of cells."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_KRING({origin_sql}, {distance_sql}))'
    )
    return [r[0] for r in run_query(sql)]


def test_h3_kring_distance_0():
    """K-ring with distance 0 returns only the origin."""
    assert sorted(_kring("'8928308280fffff'", '0')) == ['8928308280fffff']


def test_h3_kring_distance_1():
    """K-ring with distance 1 returns center + 6 neighbors (7 cells)."""
    expected = [
        '89283082803ffff',
        '89283082807ffff',
        '8928308280bffff',
        '8928308280fffff',
        '89283082873ffff',
        '89283082877ffff',
        '8928308283bffff',
    ]
    assert sorted(_kring("'8928308280fffff'", '1')) == sorted(expected)


def test_h3_kring_distance_2():
    """K-ring with distance 2 returns 19 cells."""
    expected = [
        '89283082813ffff',
        '89283082817ffff',
        '8928308281bffff',
        '89283082823ffff',
        '8928308282bffff',
        '89283082833ffff',
        '89283082803ffff',
        '89283082807ffff',
        '8928308280bffff',
        '8928308280fffff',
        '89283082847ffff',
        '89283082857ffff',
        '89283082863ffff',
        '89283082867ffff',
        '89283082873ffff',
        '89283082877ffff',
        '8928308283bffff',
        '8928308287bffff',
        '892830828abffff',
    ]
    assert sorted(_kring("'8928308280fffff'", '2')) == sorted(expected)


def test_h3_kring_all_unique():
    """All cells in the k-ring result should be unique."""
    cells = _kring("'8928308280fffff'", '2')
    assert len(cells) == len(set(cells))


def test_h3_kring_all_valid():
    """All cells in the k-ring result should be valid H3 indexes."""
    invalid = run_query(
        'SELECT t.COLUMN_VALUE AS h3'
        " FROM TABLE(@@ORA_SCHEMA@@.H3_KRING('8928308280fffff', 1)) t"
        ' WHERE @@ORA_SCHEMA@@.H3_ISVALID(t.COLUMN_VALUE) != 1'
    )
    assert (
        invalid == 'No results returned' or invalid == []
    ), f'Invalid cells in k-ring: {invalid}'


def test_h3_kring_null_origin():
    """Returns no rows when origin is NULL (NULL-on-invalid)."""
    assert _kring('NULL', '1') == []


def test_h3_kring_invalid_origin():
    """Returns no rows when origin is not a valid H3 index."""
    assert _kring("'abc'", '1') == []


def test_h3_kring_null_size():
    """Returns no rows when size is NULL."""
    assert _kring("'8928308280fffff'", 'NULL') == []


def test_h3_kring_negative_size():
    """Returns no rows when size is negative."""
    assert _kring("'8928308280fffff'", '-1') == []
