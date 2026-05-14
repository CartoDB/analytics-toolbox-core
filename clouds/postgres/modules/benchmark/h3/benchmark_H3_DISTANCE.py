# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_DISTANCE',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_DISTANCE(t.${h3_column}, t.${h3_column}) AS result '
        'FROM ${source_table} t',
)
