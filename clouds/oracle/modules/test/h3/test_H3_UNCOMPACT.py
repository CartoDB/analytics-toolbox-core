# Copyright (c) 2026, CARTO
from test_utils import run_query


def _index_array_literal(cells):
    """Build an H3_INDEX_ARRAY constructor literal from a Python list."""
    if not cells:
        return '@@ORA_SCHEMA@@.H3_INDEX_ARRAY()'
    quoted = ', '.join(f"'{c}'" for c in cells)
    return f'@@ORA_SCHEMA@@.H3_INDEX_ARRAY({quoted})'


def _uncompact(input_sql, resolution):
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_UNCOMPACT({input_sql}, {resolution}))'
    )
    return [r[0] for r in run_query(sql)]


def _tochildren(parent, res):
    sql = (
        f"SELECT COLUMN_VALUE FROM TABLE("
        f"@@ORA_SCHEMA@@.H3_TOCHILDREN('{parent}', {res}))"
    )
    return [r[0] for r in run_query(sql)]


def _kring(origin, k):
    sql = (
        f"SELECT COLUMN_VALUE FROM TABLE("
        f"@@ORA_SCHEMA@@.H3_KRING('{origin}', {k}))"
    )
    return [r[0] for r in run_query(sql)]


def _compact(cells):
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_COMPACT({_index_array_literal(cells)}))'
    )
    return [r[0] for r in run_query(sql)]


def test_h3_uncompact_null():
    """Returns no rows when input is NULL."""
    assert _uncompact('CAST(NULL AS @@ORA_SCHEMA@@.H3_INDEX_ARRAY)', 5) == []


def test_h3_uncompact_empty_array():
    """Returns no rows when input is an empty array."""
    assert _uncompact('@@ORA_SCHEMA@@.H3_INDEX_ARRAY()', 5) == []


def test_h3_uncompact_null_resolution():
    """Returns no rows when resolution is NULL."""
    assert _uncompact(_index_array_literal(['8928308280fffff']), 'NULL') == []


def test_h3_uncompact_same_resolution():
    """Cells at the target resolution are returned as-is."""
    cell = '8928308280fffff'
    assert _uncompact(_index_array_literal([cell]), 9) == [cell]


def test_h3_uncompact_expand_one_level():
    """A cell expanded one level below produces 7 children."""
    parent = '87283080dffffff'
    target_res = 8
    cells = _uncompact(_index_array_literal([parent]), target_res)
    assert len(cells) == 7
    assert sorted(cells) == sorted(_tochildren(parent, target_res))


def test_h3_uncompact_expand_two_levels():
    """A cell expanded two levels below produces 49 children."""
    parent = '87283080dffffff'
    cells = _uncompact(_index_array_literal([parent]), 9)
    assert len(cells) == 49


def test_h3_uncompact_mixed_resolutions():
    """Handles input with cells at different resolutions."""
    parent = '87283080dffffff'
    fine_cell = '8928308280fffff'
    target_res = 9
    cells = _uncompact(_index_array_literal([parent, fine_cell]), target_res)
    assert len(cells) >= 2
    for cell in cells:
        res_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_RESOLUTION('{cell}') FROM DUAL"
        )
        assert res_result[0][0] == target_res


def test_h3_uncompact_resolution_too_coarse():
    """Cells finer than target resolution are skipped."""
    fine_cell = '8928308280fffff'  # res 9
    assert _uncompact(_index_array_literal([fine_cell]), 7) == []


def test_h3_uncompact_deduplicates():
    """Duplicate cells in expansion are deduplicated."""
    cell = '87283080dffffff'
    cells = _uncompact(_index_array_literal([cell, cell]), 8)
    assert len(cells) == 7
    assert len(cells) == len(set(cells))


def test_h3_uncompact_result_sorted():
    """Result rows arrive in lexicographic order."""
    parent = '87283080dffffff'
    cells = _uncompact(_index_array_literal([parent]), 8)
    assert cells == sorted(cells)


def test_h3_uncompact_all_valid():
    """All returned cells should be valid H3 indexes."""
    parent = '87283080dffffff'
    cells = _uncompact(_index_array_literal([parent]), 8)
    for cell in cells:
        valid_result = run_query(
            f"SELECT @@ORA_SCHEMA@@.H3_ISVALID('{cell}') FROM DUAL"
        )
        assert valid_result[0][0] == 1


def test_h3_uncompact_roundtrip():
    """Compact then uncompact roundtrip preserves the original set."""
    origin = '8928308280fffff'
    origin_res = 9
    cells = _kring(origin, 2)
    assert len(cells) == 19
    compacted = _compact(cells)
    uncompacted = _uncompact(_index_array_literal(compacted), origin_res)
    assert sorted(uncompacted) == sorted(cells)


def test_h3_uncompact_invalid_resolution():
    """Returns no rows for resolution out of range."""
    assert _uncompact(_index_array_literal(['8928308280fffff']), 16) == []
    assert _uncompact(_index_array_literal(['8928308280fffff']), -1) == []
