# Copyright (c) 2026, CARTO
import json
from test_utils import run_query


def test_h3_uncompact_null():
    """Returns empty JSON array when input is NULL."""
    result = run_query(
        'SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT(NULL, 5) FROM DUAL'
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_uncompact_empty_array():
    """Returns empty JSON array when input is empty array."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT('[]', 5) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_uncompact_null_resolution():
    """Returns empty JSON array when resolution is NULL."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        "'[\"8928308280fffff\"]', NULL) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'


def test_h3_uncompact_same_resolution():
    """Cells at the target resolution are returned as-is."""
    cell = '8928308280fffff'
    target_res = 9
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{cell}\"]', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    assert cells == [cell]


def test_h3_uncompact_expand_one_level():
    """A cell expanded one level below produces 7 children."""
    parent = '87283080dffffff'
    target_res = 8
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{parent}\"]', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    expected_children_count = 7
    assert len(cells) == expected_children_count

    # Compare with H3_TOCHILDREN for consistency
    children_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_TOCHILDREN("
        f"'{parent}', {target_res}) FROM DUAL"
    )
    children = json.loads(children_result[0][0])
    assert sorted(cells) == sorted(children)


def test_h3_uncompact_expand_two_levels():
    """A cell expanded two levels below produces 49 children."""
    parent = '87283080dffffff'
    target_res = 9
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{parent}\"]', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    expected_grandchildren_count = 49
    assert len(cells) == expected_grandchildren_count


def test_h3_uncompact_mixed_resolutions():
    """Handles input with cells at different resolutions."""
    # One cell at res 7, one at res 9 -- uncompact to res 9
    parent = '87283080dffffff'
    fine_cell = '8928308280fffff'
    target_res = 9
    input_json = json.dumps([parent, fine_cell])
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'{input_json}', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])

    # Parent at res 7 expands to 49 cells at res 9
    # fine_cell is already at res 9 and may or may not overlap
    # At minimum we should have > 1 cell
    assert len(cells) >= 2

    # All cells should be at target resolution
    for cell in cells:
        res_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('{cell}') FROM DUAL"
        )
        assert res_result[0][0] == target_res


def test_h3_uncompact_resolution_too_coarse():
    """Cells finer than target resolution are skipped."""
    fine_cell = '8928308280fffff'  # res 9
    target_res = 7  # coarser than the cell
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{fine_cell}\"]', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    # The cell at res 9 is finer than target res 7 -- should be excluded
    assert cells == []


def test_h3_uncompact_deduplicates():
    """Duplicate cells in expansion are deduplicated."""
    cell = '87283080dffffff'
    target_res = 8
    # Pass the same cell twice
    input_json = json.dumps([cell, cell])
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'{input_json}', {target_res}) FROM DUAL"
    )
    assert len(result) == 1
    cells = json.loads(result[0][0])
    expected_children_count = 7
    assert len(cells) == expected_children_count
    # All unique
    assert len(cells) == len(set(cells))


def test_h3_uncompact_result_sorted():
    """Result should be a sorted JSON array."""
    parent = '87283080dffffff'
    target_res = 8
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{parent}\"]', {target_res}) FROM DUAL"
    )
    cells = json.loads(result[0][0])
    assert cells == sorted(cells)


def test_h3_uncompact_all_valid():
    """All returned cells should be valid H3 indexes."""
    parent = '87283080dffffff'
    target_res = 8
    result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'[\"{parent}\"]', {target_res}) FROM DUAL"
    )
    cells = json.loads(result[0][0])
    for cell in cells:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{cell}') FROM DUAL"
        )
        assert valid_result[0][0] == 1, f'Cell {cell} is not valid'


def test_h3_uncompact_roundtrip():
    """Compact then uncompact roundtrip preserves the original set."""
    origin = '8928308280fffff'
    origin_res = 9
    # Get KRING cells
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

    # Uncompact back
    compacted_json = json.dumps(compacted)
    uncompact_result = run_query(
        f"SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        f"'{compacted_json}', {origin_res}) FROM DUAL"
    )
    uncompacted = json.loads(uncompact_result[0][0])

    assert sorted(uncompacted) == sorted(cells)


def test_h3_uncompact_invalid_resolution():
    """Returns empty JSON array for resolution out of range."""
    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        "'[\"8928308280fffff\"]', 16) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'

    result = run_query(
        "SELECT @@ORA_SCHEMA@@.H3_UNCOMPACT("
        "'[\"8928308280fffff\"]', -1) FROM DUAL"
    )
    assert len(result) == 1
    assert result[0][0] == '[]'
