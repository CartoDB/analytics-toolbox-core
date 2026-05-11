# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql='SELECT SUM(s) FROM ('
        'SELECT SIZE(@@DB_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution})) AS s '
        'FROM (SELECT * FROM ${source_table}) t'
        ') sub',
)
