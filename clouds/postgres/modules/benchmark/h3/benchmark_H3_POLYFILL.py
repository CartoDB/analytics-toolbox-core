# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_POLYFILL(t.${geom_column}, ${resolution}) AS cells '
        'FROM ${source_table} t',
)
