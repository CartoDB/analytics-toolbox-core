# flake8: noqa
from test_utils import run_query, run_query_without_result, drop_table

polygon = 'POLYGON ((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865))'


def test_quadbin_polyfill_table_only_index():
    drop_table('quadbin_polyfill_table_test')
    run_query_without_result(
        f"""
        CALL @@PG_SCHEMA@@.QUADBIN_POLYFILL_TABLE(
            'SELECT ST_GEOMFROMTEXT(''{polygon}'') AS geom',
            17, 'intersects',
            '@@PG_SCHEMA@@.quadbin_polyfill_table_test')
        """
    )
    result = run_query(
        'SELECT quadbin FROM @@PG_SCHEMA@@.quadbin_polyfill_table_test ORDER BY quadbin'
    )
    cells = [row[0] for row in result]
    assert sorted(cells) == sorted(
        [
            5265786693153193983,
            5265786693163941887,
            5265786693164204031,
            5265786693164466175,
            5265786693164728319,
            5265786693165514751,
        ]
    )
    drop_table('quadbin_polyfill_table_test')


def test_quadbin_polyfill_table_extra_columns():
    drop_table('quadbin_polyfill_table_test')
    run_query_without_result(
        f"""
        CALL @@PG_SCHEMA@@.QUADBIN_POLYFILL_TABLE(
            'SELECT ST_GEOMFROMTEXT(''{polygon}'') AS geom, 42 AS value',
            17, 'center',
            '@@PG_SCHEMA@@.quadbin_polyfill_table_test')
        """
    )
    result = run_query(
        'SELECT quadbin, value FROM @@PG_SCHEMA@@.quadbin_polyfill_table_test '
        'ORDER BY quadbin'
    )
    assert result == [
        (5265786693163941887, 42),
        (5265786693164466175, 42),
        (5265786693164728319, 42),
    ]
    drop_table('quadbin_polyfill_table_test')
