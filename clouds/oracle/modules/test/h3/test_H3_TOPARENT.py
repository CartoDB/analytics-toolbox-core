# Copyright (c) 2026, CARTO
import pytest
from test_utils import run_query


def test_h3_toparent_null_index():
    """Returns NULL when H3 index is NULL."""
    result = run_query('SELECT @@ORA_SCHEMA@@.H3_TOPARENT(NULL, 1) FROM DUAL')
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_toparent_null_resolution():
    """Returns NULL when resolution is NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOPARENT('85283473fffffff', NULL)" ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_toparent_invalid_index():
    """Returns NULL for an invalid H3 index."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOPARENT('ff283473fffffff', 1)" ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_toparent_resolution_too_high():
    """Returns NULL when target resolution >= current resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOPARENT('85283473fffffff', 5)" ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_toparent_resolution_above_current():
    """Returns NULL when target resolution > current resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOPARENT('85283473fffffff', 10)" ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


def test_h3_toparent_negative_resolution():
    """Returns NULL for negative resolution."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_TOPARENT('85283473fffffff', -1)" ' FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] is None


@pytest.mark.parametrize('parent_res', range(1, 11))
def test_h3_toparent_hierarchy(parent_res):
    """H3_TOPARENT of a child matches H3_FROMGEOGPOINT at parent resolution.

    For resolutions 1 through 10, verifies that computing the parent of a
    child cell (at parent_res + 1) yields the same index as computing the
    H3 index directly at the parent resolution.
    """
    child_res = parent_res + 1
    result = run_query(
        f'SELECT'
        f' @@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        f'SDO_GEOMETRY(2001, 4326,'
        f' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        f' NULL, NULL), {parent_res}) AS direct,'
        f' @@ORA_SCHEMA@@.H3_TOPARENT('
        f'@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        f'SDO_GEOMETRY(2001, 4326,'
        f' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        f' NULL, NULL), {child_res}), {parent_res}) AS via_parent'
        f' FROM DUAL'
    )
    assert len(result) == 1
    direct, via_parent = result[0]
    assert direct == via_parent


@pytest.mark.parametrize('parent_res', range(1, 10))
def test_h3_toparent_grandparent(parent_res):
    """H3_TOPARENT of a grandchild matches H3_FROMGEOGPOINT at parent res.

    For resolutions 1 through 9, verifies that computing the parent at
    parent_res from a grandchild cell (at parent_res + 2) yields the same
    index as computing the H3 index directly at the parent resolution.
    """
    grandchild_res = parent_res + 2
    result = run_query(
        f'SELECT'
        f' @@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        f'SDO_GEOMETRY(2001, 4326,'
        f' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        f' NULL, NULL), {parent_res}) AS direct,'
        f' @@ORA_SCHEMA@@.H3_TOPARENT('
        f'@@ORA_SCHEMA@@.H3_FROMGEOGPOINT('
        f'SDO_GEOMETRY(2001, 4326,'
        f' SDO_POINT_TYPE(-122.409290778685, 37.81331899988944, NULL),'
        f' NULL, NULL), {grandchild_res}), {parent_res}) AS via_parent'
        f' FROM DUAL'
    )
    assert len(result) == 1
    direct, via_parent = result[0]
    assert direct == via_parent
