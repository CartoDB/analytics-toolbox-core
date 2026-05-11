# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_INT_TOSTRING',
    sql='SELECT COUNT(@@PG_SCHEMA@@.H3_INT_TOSTRING(${h3_int})) '
        'FROM ${source_table}',
)
