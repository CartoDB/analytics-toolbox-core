# Copyright (c) 2026, CARTO
import json
from test_utils import run_query


def test_h3_tochildren_null_index():
    """Returns empty JSON array when H3 index is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN(NULL, 1) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_null_resolution():
    """Returns empty JSON array when resolution is NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN('85283473fffffff', NULL)"
        " FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_invalid_index():
    """Returns empty JSON array for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN('ff283473fffffff', 1)"
        " FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_coarser_resolution():
    """Returns empty JSON array when target resolution < current."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7), 6) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_same_resolution():
    """Returns JSON array with self when target resolution == current."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "'87283080dffffff', 7) FROM DUAL"
    )
    assert len(result) == 1
    children = json.loads(result[0][0])
    assert children == ['87283080dffffff']


def test_h3_tochildren_direct_children():
    """A res-7 cell has exactly 7 children at res 8."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7), 8) FROM DUAL"
    )
    assert len(result) == 1
    children = json.loads(result[0][0])
    assert len(children) == 7


def test_h3_tochildren_grandchildren():
    """A res-7 cell has exactly 49 grandchildren at res 9 (7*7)."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 7), 9) FROM DUAL"
    )
    assert len(result) == 1
    children = json.loads(result[0][0])
    assert len(children) == 49


def test_h3_tochildren_all_valid():
    """All returned children should be valid H3 indexes."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "'87283080dffffff', 8) FROM DUAL"
    )
    children = json.loads(result[0][0])
    for child in children:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{child}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Child {child} is not valid'


def test_h3_tochildren_correct_resolution():
    """All returned children should have the target resolution."""
    target_res = 8
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'87283080dffffff', {target_res}) FROM DUAL"
    )
    children = json.loads(result[0][0])
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
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{parent_hex}', {child_res}) FROM DUAL"
    )
    children = json.loads(result[0][0])
    for child in children:
        parent_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_TOPARENT("
            f"'{child}', {parent_res}) FROM DUAL"
        )
        assert parent_result[0][0] == parent_hex, (
            f'Parent of {child} is {parent_result[0][0]}, '
            f'expected {parent_hex}'
        )


def test_h3_tochildren_unique():
    """All returned children should be unique."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "'87283080dffffff', 9) FROM DUAL"
    )
    children = json.loads(result[0][0])
    assert len(children) == len(set(children))


def test_h3_tochildren_negative_resolution():
    """Returns empty JSON array for negative resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "'85283473fffffff', -1) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_resolution_above_max():
    """Returns empty JSON array for resolution > 15."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "'85283473fffffff', 16) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_tochildren_res0_to_res1():
    """A resolution 0 cell should have 7 children at res 1."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        "@@ORA_SCHEMA@@.H3_FROMGEOGPOINT("
        "SDO_GEOMETRY(2001, 4326,"
        " SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),"
        " NULL, NULL), 0), 1) FROM DUAL"
    )
    assert len(result) == 1
    children = json.loads(result[0][0])
    assert len(children) == 7
