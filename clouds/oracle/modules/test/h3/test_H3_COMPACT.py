# Copyright (c) 2026, CARTO
from test_utils import run_query


def _index_array_literal(cells):
    """Build an H3_INDEX_ARRAY constructor literal from a Python list."""
    if not cells:
        return '@@ORA_SCHEMA@@.H3_INDEX_ARRAY()'
    quoted = ', '.join(f"'{c}'" for c in cells)
    return f'@@ORA_SCHEMA@@.H3_INDEX_ARRAY({quoted})'


def _compact(input_sql):
    """Run H3_COMPACT as a TABLE and return the list of cells."""
    sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_COMPACT({input_sql}))'
    )
    return [r[0] for r in run_query(sql)]


def _tochildren(parent, res):
    """Helper: list children of `parent` at resolution `res`."""
    sql = (
        f"SELECT COLUMN_VALUE FROM TABLE("
        f"@@ORA_SCHEMA@@.H3_TOCHILDREN('{parent}', {res}))"
    )
    return [r[0] for r in run_query(sql)]


def _kring(origin, k):
    """Helper: list k-ring of `origin`."""
    sql = (
        f"SELECT COLUMN_VALUE FROM TABLE("
        f"@@ORA_SCHEMA@@.H3_KRING('{origin}', {k}))"
    )
    return [r[0] for r in run_query(sql)]


def test_h3_compact_null():
    """Returns no rows when input is NULL."""
    assert _compact('CAST(NULL AS @@ORA_SCHEMA@@.H3_INDEX_ARRAY)') == []


def test_h3_compact_empty_array():
    """Returns no rows when input is an empty array."""
    assert _compact('@@ORA_SCHEMA@@.H3_INDEX_ARRAY()') == []


def test_h3_compact_single_cell():
    """A single cell cannot be compacted, returns as-is."""
    cell = '8928308280fffff'
    assert _compact(_index_array_literal([cell])) == [cell]


def test_h3_compact_already_compact():
    """Cells that cannot compact further stay the same."""
    input_cells = ['8928308280fffff', '8928308283bffff']
    compacted = _compact(_index_array_literal(input_cells))
    assert sorted(compacted) == sorted(input_cells)


def test_h3_compact_full_sibling_set():
    """All 7 children of a hex parent compact to the parent."""
    parent = '87283080dffffff'
    children = _tochildren(parent, 8)
    assert len(children) == 7
    assert _compact(_index_array_literal(children)) == [parent]


def test_h3_compact_partial_sibling_set():
    """A partial sibling set (fewer than 7) does not compact."""
    parent = '87283080dffffff'
    children = _tochildren(parent, 8)
    partial_children = children[:-1]
    assert len(partial_children) == 6
    compacted = _compact(_index_array_literal(partial_children))
    assert sorted(compacted) == sorted(partial_children)


def test_h3_compact_roundtrip_kring():
    """Compact/uncompact roundtrip: KRING at distance 2 (19 cells)."""
    origin = '8928308280fffff'
    origin_res = 9
    cells = _kring(origin, 2)
    assert len(cells) == 19

    compacted = _compact(_index_array_literal(cells))
    assert len(compacted) <= len(cells)

    uncompact_sql = (
        f'SELECT COLUMN_VALUE FROM TABLE('
        f'@@ORA_SCHEMA@@.H3_UNCOMPACT('
        f'{_index_array_literal(compacted)}, {origin_res}))'
    )
    uncompacted = [r[0] for r in run_query(uncompact_sql)]
    assert sorted(uncompacted) == sorted(cells)


def test_h3_compact_deduplicates():
    """Duplicate cells in input should be handled (treated as one)."""
    cell = '8928308280fffff'
    compacted = _compact(_index_array_literal([cell, cell, cell]))
    assert compacted == [cell]


def test_h3_compact_result_sorted():
    """Result rows arrive in lexicographic order."""
    parent = '87283080dffffff'
    children = _tochildren(parent, 8)
    compacted = _compact(_index_array_literal(children))
    assert compacted == sorted(compacted)


def test_h3_compact_multilevel():
    """Compaction should work across multiple resolution levels."""
    grandparent = '87283080dffffff'
    grandchildren = _tochildren(grandparent, 9)
    assert len(grandchildren) == 49
    compacted = _compact(_index_array_literal(grandchildren))
    assert compacted == [grandparent]
