# Copyright (c) 2026, CARTO

from test_utils import run_query


OUTPUT_TABLE = '@@DB_SCHEMA@@.quadbin_polyfill_table_test'

POLYGON_WKT = (
    'POLYGON ((-3.71219873428345 40.413365349070865,'
    '-3.7144088745117 40.40965661286395,'
    '-3.70659828186035 40.409525904775634,'
    '-3.71219873428345 40.413365349070865))'
)

# Expected quadbin coverage of the test polygon at resolution 17.
EXPECTED_CELLS = sorted(
    [
        5265786693153193983,
        5265786693163941887,
        5265786693164204031,
        5265786693164466175,
        5265786693164728319,
        5265786693165514751,
    ]
)


def _call(input_query, resolution, mode):
    escaped = input_query.replace("'", "''")
    return (
        f'CALL @@DB_SCHEMA@@.QUADBIN_POLYFILL_TABLE('
        f"    '{escaped}', {resolution}, '{mode}', '{OUTPUT_TABLE}'"
        f')'
    )


def test_quadbin_polyfill_table_creates_cells():
    try:
        run_query(
            _call(
                f"SELECT ST_GEOMFROMTEXT('{POLYGON_WKT}', 4326) AS geom",
                17,
                'intersects',
            )
        )
        result = run_query(f'SELECT quadbin FROM {OUTPUT_TABLE} ORDER BY quadbin')
        cells = sorted(int(row[0]) for row in result)
        assert cells == EXPECTED_CELLS
    finally:
        run_query(f'DROP TABLE IF EXISTS {OUTPUT_TABLE}')


def test_quadbin_polyfill_table_preserves_columns():
    try:
        run_query(
            _call(
                f"SELECT ST_GEOMFROMTEXT('{POLYGON_WKT}', 4326) AS geom," ' 42 AS val',
                17,
                'intersects',
            )
        )
        result = run_query(f'SELECT quadbin, val FROM {OUTPUT_TABLE} ORDER BY quadbin')
        cells = sorted(int(row[0]) for row in result)
        assert cells == EXPECTED_CELLS
        assert all(int(row[1]) == 42 for row in result)
    finally:
        run_query(f'DROP TABLE IF EXISTS {OUTPUT_TABLE}')
