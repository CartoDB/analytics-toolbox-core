# Copyright (c) 2026, CARTO
from test_utils import run_query


def _tochildren(idx_sql, res_sql):
    """Run H3_TOCHILDREN as a TABLE and return the list of children."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_TOCHILDREN({idx_sql}, {res_sql}))'
    )
    return [r[0] for r in run_query(sql)]


def test_h3_tochildren_null_index():
    """Returns no rows when H3 index is NULL."""
    assert _tochildren('NULL', '1') == []


def test_h3_tochildren_null_resolution():
    """Returns no rows when resolution is NULL."""
    assert _tochildren("'85283473fffffff'", 'NULL') == []


def test_h3_tochildren_invalid_index():
    """Returns no rows for an invalid H3 index."""
    assert _tochildren("'ff283473fffffff'", '1') == []


def test_h3_tochildren_coarser_resolution():
    """Returns no rows when target resolution < current."""
    children = _tochildren(
        '@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        'SDO_GEOMETRY(2001, 4326,'
        ' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        ' NULL, NULL), 7)',
        '6',
    )
    assert children == []


def test_h3_tochildren_same_resolution():
    """Returns the cell itself when target resolution == current."""
    assert _tochildren("'87283080dffffff'", '7') == ['87283080dffffff']


def test_h3_tochildren_direct_children():
    """A res-7 cell has exactly 7 children at res 8."""
    children = _tochildren(
        '@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        'SDO_GEOMETRY(2001, 4326,'
        ' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        ' NULL, NULL), 7)',
        '8',
    )
    assert len(children) == 7


def test_h3_tochildren_grandchildren():
    """A res-7 cell has exactly 49 grandchildren at res 9 (7*7)."""
    children = _tochildren(
        '@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        'SDO_GEOMETRY(2001, 4326,'
        ' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        ' NULL, NULL), 7)',
        '9',
    )
    assert len(children) == 49


def test_h3_tochildren_all_valid():
    """All returned children should be valid H3 indexes."""
    invalid = run_query(
        'SELECT t.COLUMN_VALUE AS h3'
        " FROM TABLE(@@ORA_SCHEMA@@.H3_TOCHILDREN('87283080dffffff', 8)) t"
        ' WHERE @@ORA_SCHEMA@@.H3_ISVALID(t.COLUMN_VALUE) != 1'
    )
    assert (
        invalid == 'No results returned' or invalid == []
    ), f'Invalid children: {invalid}'


def test_h3_tochildren_correct_resolution():
    """All returned children should have the target resolution."""
    target_res = 8
    wrong = run_query(
        f'SELECT t.COLUMN_VALUE AS h3'
        f" FROM TABLE(@@ORA_SCHEMA@@.H3_TOCHILDREN('87283080dffffff',"
        f' {target_res})) t'
        f' WHERE @@ORA_SCHEMA@@.H3_RESOLUTION(t.COLUMN_VALUE) != {target_res}'
    )
    assert (
        wrong == 'No results returned' or wrong == []
    ), f'Children at wrong resolution: {wrong}'


def test_h3_tochildren_parent_roundtrip():
    """Each child's parent should equal the original cell."""
    parent_hex = '87283080dffffff'
    parent_res = 7
    child_res = 8
    wrong = run_query(
        f'SELECT t.COLUMN_VALUE AS h3,'
        f' @@ORA_SCHEMA@@.H3_TOPARENT(t.COLUMN_VALUE, {parent_res}) AS p'
        f" FROM TABLE(@@ORA_SCHEMA@@.H3_TOCHILDREN('{parent_hex}',"
        f' {child_res})) t'
        f' WHERE @@ORA_SCHEMA@@.H3_TOPARENT(t.COLUMN_VALUE, {parent_res})'
        f" != '{parent_hex}'"
    )
    assert (
        wrong == 'No results returned' or wrong == []
    ), f'Children with wrong parent: {wrong}'


def test_h3_tochildren_unique():
    """All returned children should be unique."""
    children = _tochildren("'87283080dffffff'", '9')
    assert len(children) == len(set(children))


def test_h3_tochildren_negative_resolution():
    """Returns no rows for negative resolution."""
    assert _tochildren("'85283473fffffff'", '-1') == []


def test_h3_tochildren_resolution_above_max():
    """Returns no rows for resolution > 15."""
    assert _tochildren("'85283473fffffff'", '16') == []


def test_h3_tochildren_res0_to_res1():
    """A resolution 0 cell should have 7 children at res 1."""
    children = _tochildren(
        '@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        'SDO_GEOMETRY(2001, 4326,'
        ' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        ' NULL, NULL), 0)',
        '1',
    )
    assert len(children) == 7
