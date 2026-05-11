# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_DISTANCE',
    sql='SELECT COUNT(@@PG_SCHEMA@@.H3_DISTANCE(t.${h3_column}, t.${h3_column})) '
        'FROM ${source_table} t',
)
