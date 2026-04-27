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
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7)",
        '6',
    )
    assert children == []


def test_h3_tochildren_same_resolution():
    """Returns the cell itself when target resolution == current."""
    assert _tochildren("'87283080dffffff'", '7') == ['87283080dffffff']


def test_h3_tochildren_direct_children():
    """A res-7 cell has exactly 7 children at res 8."""
    children = _tochildren(
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7)",
        '8',
    )
    assert len(children) == 7


def test_h3_tochildren_grandchildren():
    """A res-7 cell has exactly 49 grandchildren at res 9 (7*7)."""
    children = _tochildren(
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7)",
        '9',
    )
    assert len(children) == 49


def test_h3_tochildren_all_valid():
    """All returned children should be valid H3 indexes."""
    children = _tochildren("'87283080dffffff'", '8')
    for child in children:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{child}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Child {child} is not valid'


def test_h3_tochildren_correct_resolution():
    """All returned children should have the target resolution."""
    target_res = 8
    children = _tochildren("'87283080dffffff'", str(target_res))
    for child in children:
        res_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('{child}') FROM DUAL"
        )
        assert res_result[0][0] == target_res, (
            f'Child {child} has resolution {res_result[0][0]}, '
            f'expected {target_res}'
        )


def test_h3_tochildren_parent_roundtrip():
    """Each child's parent should equal the original cell."""
    parent_hex = '87283080dffffff'
    parent_res = 7
    child_res = 8
    children = _tochildren(f"'{parent_hex}'", str(child_res))
    for child in children:
        parent_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_TOPARENT("
            f"'{child}', {parent_res}) FROM DUAL"
        )
        assert parent_result[0][0] == parent_hex


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
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 0)",
        '1',
    )
    assert len(children) == 7
