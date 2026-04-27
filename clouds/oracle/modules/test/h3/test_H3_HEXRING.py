# Copyright (c) 2026, CARTO
from test_utils import run_query


def _hexring(origin_sql, distance_sql):
    """Run H3_HEXRING as a TABLE and return the list of cells."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_HEXRING({origin_sql}, {distance_sql}))'
    )
    return [r[0] for r in run_query(sql)]


def test_h3_hexring_distance_0():
    """Hex ring with distance 0 returns only the origin (matches BQ/SF/PG)."""
    assert sorted(_hexring("'8928308280fffff'", '0')) == ['8928308280fffff']


def test_h3_hexring_distance_1():
    """Hex ring with distance 1 returns 6 neighbors (NOT including center)."""
    expected = [
        '89283082803ffff', '89283082807ffff', '8928308280bffff',
        '89283082873ffff', '89283082877ffff', '8928308283bffff',
    ]
    assert sorted(_hexring("'8928308280fffff'", '1')) == sorted(expected)


def test_h3_hexring_distance_2():
    """Hex ring with distance 2 returns 12 cells on the outer ring only."""
    expected = [
        '89283082813ffff', '89283082817ffff', '8928308281bffff',
        '89283082823ffff', '8928308282bffff', '89283082833ffff',
        '89283082847ffff', '89283082857ffff', '89283082863ffff',
        '89283082867ffff', '8928308287bffff', '892830828abffff',
    ]
    assert sorted(_hexring("'8928308280fffff'", '2')) == sorted(expected)


def test_h3_hexring_all_unique():
    """All cells in the hex ring result should be unique."""
    cells = _hexring("'8928308280fffff'", '2')
    assert len(cells) == len(set(cells))


def test_h3_hexring_all_valid():
    """All cells in the hex ring result should be valid H3 indexes."""
    cells = _hexring("'8928308280fffff'", '1')
    for cell in cells:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{cell}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Cell {cell} is not valid'


def test_h3_hexring_null_origin():
    """Returns no rows when origin is NULL (NULL-on-invalid)."""
    assert _hexring('NULL', '1') == []


def test_h3_hexring_invalid_origin():
    """Returns no rows when origin is not a valid H3 index."""
    assert _hexring("'abc'", '1') == []


def test_h3_hexring_null_size():
    """Returns no rows when size is NULL."""
    assert _hexring("'8928308280fffff'", 'NULL') == []


def test_h3_hexring_negative_size():
    """Returns no rows when size is negative."""
    assert _hexring("'8928308280fffff'", '-1') == []
