# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution}) AS cells '
        'FROM (SELECT * FROM ${source_table}) t',
)
