# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql='SELECT COUNT(*) FROM ('
        'SELECT @@RS_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution}) AS poly '
        'FROM (SELECT * FROM ${source_table}) t'
        ') sub, sub.poly AS p',
)
