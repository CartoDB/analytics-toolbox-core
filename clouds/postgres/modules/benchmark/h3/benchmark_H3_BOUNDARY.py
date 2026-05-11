# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_BOUNDARY',
    sql='SELECT COUNT(@@PG_SCHEMA@@.H3_BOUNDARY(t.${h3_column})) '
        'FROM ${source_table} t',
)
