# Copyright (c) 2026, CARTO
import os
import pytest
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
        f"BEGIN @@ORA_SCHEMA@@.H3_POLYFILL_TABLE("
        f"'{escaped_query}', {resolution}, '{mode}', "
        f"'{output_table}'); END;"
    )


def test_h3_polyfill_table_center_mode():
    """Center mode creates table with expected H3 cells."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_CENTER'
    drop_table(output_table)
    try:
        run_query(_call(
            f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
            ' FROM DUAL',
            9, 'center', output_table,
        ))
        result = run_query(
            f'SELECT h3 FROM {output_table} ORDER BY h3'
        )
        assert len(result) == 1
        assert result[0][0] == '89390cb1b4bffff'
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_intersects_mode():
    """Intersects mode creates table with cells overlapping geometry."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_ISECTS'
    drop_table(output_table)
    try:
        run_query(_call(
            f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
            ' FROM DUAL',
            9, 'intersects', output_table,
        ))
        result = run_query(
            f'SELECT h3 FROM {output_table} ORDER BY h3'
        )
        assert len(result) >= 1
        h3_values = [r[0] for r in result]
        assert '89390cb1b4bffff' in h3_values
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_preserves_columns():
    """Output table preserves all columns from input query."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_COLS'
    drop_table(output_table)
    try:
        run_query(_call(
            f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom,"
            ' 42 AS val FROM DUAL',
            9, 'center', output_table,
        ))
        result = run_query(
            f'SELECT h3, val FROM {output_table} ORDER BY h3'
        )
        assert len(result) == 1
        assert result[0][0] == '89390cb1b4bffff'
        assert result[0][1] == 42
    finally:
        drop_table(output_table)


def test_h3_polyfill_table_invalid_mode():
    """Invalid mode raises an error."""
    output_table = f'{SCHEMA}.TEST_POLYFILL_BADMODE'
    drop_table(output_table)
    try:
        with pytest.raises(Exception) as excinfo:
            run_query(_call(
                f"SELECT SDO_UTIL.FROM_WKTGEOMETRY('{POLYGON_WKT}') AS geom"
                ' FROM DUAL',
                9, 'invalid_mode', output_table,
            ))
        assert 'Invalid mode' in str(excinfo.value)
    finally:
        drop_table(output_table)
