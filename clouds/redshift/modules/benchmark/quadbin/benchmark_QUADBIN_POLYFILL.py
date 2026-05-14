# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@RS_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution}) AS cells '
        'FROM ${source_table} t',
)
