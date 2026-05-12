# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_KRING_DISTANCES',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT t.${h3_column} AS input, @@PG_SCHEMA@@.H3_KRING_DISTANCES(t.${h3_column}, ${size}) AS kring '
        'FROM ${source_table} t',
)
