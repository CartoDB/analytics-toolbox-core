# flake8: noqa
from test_utils import run_query, run_query_without_result, drop_table

polygon = 'POLYGON ((-3.71219873428345 40.413365349070865,-3.7144088745117 40.40965661286395,-3.70659828186035 40.409525904775634,-3.71219873428345 40.413365349070865))'


def test_h3_polyfill_table_only_index():
    drop_table('h3_polyfill_table_test')
    run_query_without_result(
        f"""
        CALL @@PG_SCHEMA@@.H3_POLYFILL_TABLE(
            'SELECT ST_GEOMFROMTEXT(''{polygon}'') AS geom',
            9, 'intersects',
            '@@PG_SCHEMA@@.h3_polyfill_table_test')
        """
    )
    result = run_query(
        'SELECT h3 FROM @@PG_SCHEMA@@.h3_polyfill_table_test ORDER BY h3'
    )
    cells = [row[0] for row in result]
    assert sorted(cells) == sorted(
        [
            '89390cb1b4fffff',
            '89390ca3497ffff',
            '89390ca34b3ffff',
            '89390cb1b4bffff',
            '89390ca3487ffff',
            '89390cb1b5bffff',
        ]
    )
    drop_table('h3_polyfill_table_test')


def test_h3_polyfill_table_extra_columns():
    drop_table('h3_polyfill_table_test')
    run_query_without_result(
        f"""
        CALL @@PG_SCHEMA@@.H3_POLYFILL_TABLE(
            'SELECT ST_GEOMFROMTEXT(''{polygon}'') AS geom, 42 AS value',
            9, 'center',
            '@@PG_SCHEMA@@.h3_polyfill_table_test')
        """
    )
    result = run_query(
        'SELECT h3, value FROM @@PG_SCHEMA@@.h3_polyfill_table_test ORDER BY h3'
    )
    assert result == [('89390cb1b4bffff', 42)]
    drop_table('h3_polyfill_table_test')
