# Copyright (c) 2026, CARTO
import json
import pytest
from test_utils import run_query


def test_h3_compact_null():
    """Returns empty JSON array when input is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_COMPACT(NULL) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_compact_empty_array():
    """Returns empty JSON array when input is empty array."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_COMPACT('[]') FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_compact_single_cell():
    """A single cell cannot be compacted, returns as-is."""
    cell = '8928308280fffff'
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT("
        f"'[\"{cell}\"]') FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    assert cells == [cell]


def test_h3_compact_already_compact():
    """Cells at mixed resolutions that cannot compact further stay the same."""
    # Two cells that are NOT siblings (different parents) cannot compact
    input_cells = ['8928308280fffff', '8928308283bffff']
    input_json = json.dumps(input_cells)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{input_json}') FROM DUAL"
    )
    assert len(result) == 1
    compacted = json.loads(result[0][0])
    assert sorted(compacted) == sorted(input_cells)


def test_h3_compact_full_sibling_set():
    """All 7 children of a hex parent compact to the parent."""
    parent = '87283080dffffff'
    parent_res = 7
    child_res = 8
    # Get all children of this parent
    children_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{parent}', {child_res}) FROM DUAL"
    )
    children = json.loads(children_result[0][0])
    num_children = len(children)
    assert num_children == 7

    # Compact all children -- should yield the parent
    children_json = json.dumps(children)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{children_json}') FROM DUAL"
    )
    compacted = json.loads(result[0][0])
    assert compacted == [parent]


def test_h3_compact_partial_sibling_set():
    """A partial sibling set (fewer than 7) does not compact."""
    parent = '87283080dffffff'
    child_res = 8
    children_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{parent}', {child_res}) FROM DUAL"
    )
    children = json.loads(children_result[0][0])
    # Remove one child so compaction should not occur
    partial_children = children[:-1]
    assert len(partial_children) == 6

    partial_json = json.dumps(partial_children)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{partial_json}') FROM DUAL"
    )
    compacted = json.loads(result[0][0])
    assert sorted(compacted) == sorted(partial_children)


def test_h3_compact_roundtrip_kring():
    """Compact/uncompact roundtrip: KRING at distance 2 (19 cells)."""
    origin = '8928308280fffff'
    origin_res = 9
    kring_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_KRING('{origin}', 2) FROM DUAL"
    )
    cells = json.loads(kring_result[0][0])
    expected_kring_size = 19
    assert len(cells) == expected_kring_size

    # Compact
    cells_json = json.dumps(cells)
    compact_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{cells_json}') FROM DUAL"
    )
    compacted = json.loads(compact_result[0][0])
    # Compacted should have fewer or equal cells
    assert len(compacted) <= len(cells)

    # Uncompact back to original resolution
    compacted_json = json.dumps(compacted)
    uncompact_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'{compacted_json}', {origin_res}) FROM DUAL"
    )
    uncompacted = json.loads(uncompact_result[0][0])

    # Should match original set exactly
    assert sorted(uncompacted) == sorted(cells)


def test_h3_compact_deduplicates():
    """Duplicate cells in input should be handled (treated as one)."""
    cell = '8928308280fffff'
    input_cells = [cell, cell, cell]
    input_json = json.dumps(input_cells)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{input_json}') FROM DUAL"
    )
    compacted = json.loads(result[0][0])
    # Should contain the cell exactly once
    assert compacted == [cell]


def test_h3_compact_result_sorted():
    """Result should be a sorted JSON array."""
    parent = '87283080dffffff'
    child_res = 8
    children_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{parent}', {child_res}) FROM DUAL"
    )
    children = json.loads(children_result[0][0])
    children_json = json.dumps(children)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{children_json}') FROM DUAL"
    )
    compacted = json.loads(result[0][0])
    assert compacted == sorted(compacted)


def test_h3_compact_multilevel():
    """Compaction should work across multiple resolution levels."""
    # Get all grandchildren of a res-7 cell at res-9 (49 cells)
    grandparent = '87283080dffffff'
    grandchildren_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{grandparent}', 9) FROM DUAL"
    )
    grandchildren = json.loads(grandchildren_result[0][0])
    expected_grandchildren_count = 49
    assert len(grandchildren) == expected_grandchildren_count

    # Compact should reduce all the way back to the grandparent
    gc_json = json.dumps(grandchildren)
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_COMPACT('{gc_json}') FROM DUAL"
    )
    compacted = json.loads(result[0][0])
    assert compacted == [grandparent]
