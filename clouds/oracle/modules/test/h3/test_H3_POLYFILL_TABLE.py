# Copyright (c) 2026, CARTO
import os
from test_utils import drop_table, run_query


SCHEMA = os.environ.get('ORA_SCHEMA', '')

POLYGON_WKT = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)


def _call(input_query, resolution, mode, output_table):
    """Build a CALL statement for H3_POLYFILL_TABLE."""
    escaped_query = input_query.replace("'", "''")
    return (
        f'BEGIN @@ORA_SCHEMA@@.H3_POLYFILL_TABLE('
        f"'{escaped_query}', {resolution}, '{mode}', "
        f"'{output_table}'); END;"
    )


def test_h3_polyfill_table_center_mode():
    """Center mode creates table with expected H3 cells."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_CENTER'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                9,
                'center',
                output_table,
            )
        )
        result = run_query(f'SELECT h3 FROM {output_table} ORDER BY h3')
        assert len(result) == 1
        assert result[0][0] == '89390cb1b4bffff'
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_intersects_mode():
    """Intersects mode keeps cells whose boundary intersects the geometry."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_ISECTS'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                9,
                'intersects',
                output_table,
            )
        )
        result = run_query(f'SELECT h3 FROM {output_table} ORDER BY h3')
        h3_values = [r[0] for r in result]
        expected = [
            '89390ca3487ffff',
            '89390ca3497ffff',
            '89390ca34b3ffff',
            '89390cb1b4bffff',
            '89390cb1b4fffff',
            '89390cb1b5bffff',
        ]
        assert h3_values == expected, (
            f'Intersects-mode cells did not match expected fixture.\n'
            f'  expected: {expected}\n'
            f'  got:      {h3_values}'
        )
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_contains_mode():
    """Contains mode keeps only cells whose boundary lies fully inside the
    geometry. The Madrid test polygon is smaller than one res-9 cell, so no
    cell can be fully contained — strictest mode → empty result."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_CONTAINS'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                9,
                'contains',
                output_table,
            )
        )
        result = run_query(f'SELECT h3 FROM {output_table} ORDER BY h3')
        assert (
            result == 'No results returned' or result == []
        ), f'Contains mode at this polygon size expected to be empty, got {result}'
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_preserves_columns():
    """Output table preserves all columns from input query."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_COLS'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom,"
                ' 42 AS val FROM DUAL',
                9,
                'center',
                output_table,
            )
        )
        result = run_query(f'SELECT h3, val FROM {output_table} ORDER BY h3')
        assert len(result) == 1
        assert result[0][0] == '89390cb1b4bffff'
        assert result[0][1] == 42
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_invalid_mode():
    """Invalid mode silently no-ops (NULL-on-invalid): output table not created."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_BADMODE'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                9,
                'invalid_mode',
                output_table,
            )
        )
        # No exception, and the output table was not created.
        rows = run_query(
            'SELECT COUNT(*) FROM USER_TABLES'
            " WHERE TABLE_NAME = 'TEST_POLYFILL_BADMODE'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_invalid_resolution():
    """Out-of-range resolution silently no-ops: output table not created."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_BADRES'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                -1,
                'center',
                output_table,
            )
        )
        rows = run_query(
            "SELECT COUNT(*) FROM USER_TABLES WHERE TABLE_NAME = 'TEST_POLYFILL_BADRES'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_null_inputs():
    """NULL inputs silently no-op: output table not created."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_NULLIN'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                'NULL',
                'center',
                output_table,
            )
        )
        rows = run_query(
            "SELECT COUNT(*) FROM USER_TABLES WHERE TABLE_NAME = 'TEST_POLYFILL_NULLIN'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)
