# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_TOCHILDREN',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT t.${h3_column} AS input, @@PG_SCHEMA@@.H3_TOCHILDREN(t.${h3_column}, ${resolution}) AS cells '
        'FROM ${source_table} t',
)
