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

# Expected quadbin coverage of the test polygon at resolution 17. The procedure
# produces this set regardless of the requested mode until a mode-aware
# QUADBIN_POLYFILL_MODE exists.
EXPECTED_CELLS = [
    5265786693153193983,
    5265786693163941887,
    5265786693164204031,
    5265786693164466175,
    5265786693164728319,
    5265786693165514751,
]


def _call(input_query, resolution, mode, output_table):
    """Build a CALL statement for QUADBIN_POLYFILL_TABLE."""
    escaped_query = input_query.replace("'", "''")
    return (
        f'BEGIN @@ORA_SCHEMA@@.QUADBIN_POLYFILL_TABLE('
        f"'{escaped_query}', {resolution}, '{mode}', "
        f"'{output_table}'); END;"
    )


def test_quadbin_polyfill_table_creates_cells():
    """The procedure materializes the quadbin coverage into a table."""
    output_table = f'{SCHEMA}.TEST_QB_POLYFILL_ISECTS'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                17,
                'intersects',
                output_table,
            )
        )
        result = run_query(f'SELECT quadbin FROM {output_table} ORDER BY quadbin')
        cells = [int(r[0]) for r in result]
        assert cells == sorted(EXPECTED_CELLS)
    finally:
        drop_table(output_table)


def test_quadbin_polyfill_table_preserves_columns():
    """Output table preserves all columns from input query."""
    output_table = f'{SCHEMA}.TEST_QB_POLYFILL_COLS'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom,"
                ' 42 AS val FROM DUAL',
                17,
                'intersects',
                output_table,
            )
        )
        result = run_query(f'SELECT quadbin, val FROM {output_table} ORDER BY quadbin')
        cells = [int(r[0]) for r in result]
        assert cells == sorted(EXPECTED_CELLS)
        assert all(r[1] == 42 for r in result)
    finally:
        drop_table(output_table)


def test_quadbin_polyfill_table_invalid_mode():
    """Invalid mode silently no-ops (NULL-on-invalid): output table not created."""
    output_table = f'{SCHEMA}.TEST_QB_POLYFILL_BADMODE'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                17,
                'invalid_mode',
                output_table,
            )
        )
        rows = run_query(
            'SELECT COUNT(*) FROM USER_TABLES'
            " WHERE TABLE_NAME = 'TEST_QB_POLYFILL_BADMODE'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)


def test_quadbin_polyfill_table_invalid_resolution():
    """Out-of-range resolution silently no-ops: output table not created."""
    output_table = f'{SCHEMA}.TEST_QB_POLYFILL_BADRES'
    drop_table(output_table)
    try:
        run_query(
            _call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                27,
                'center',
                output_table,
            )
        )
        rows = run_query(
            'SELECT COUNT(*) FROM USER_TABLES'
            " WHERE TABLE_NAME = 'TEST_QB_POLYFILL_BADRES'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)


def test_quadbin_polyfill_table_null_inputs():
    """NULL inputs silently no-op: output table not created."""
    output_table = f'{SCHEMA}.TEST_QB_POLYFILL_NULLIN'
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
            'SELECT COUNT(*) FROM USER_TABLES'
            " WHERE TABLE_NAME = 'TEST_QB_POLYFILL_NULLIN'"
        )
        assert rows[0][0] == 0
    finally:
        drop_table(output_table)
