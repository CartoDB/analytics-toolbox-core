# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_INT_TOSTRING',
    sql='CREATE TABLE ${output_table} AS '
    'SELECT @@ORA_SCHEMA@@.H3_INT_TOSTRING(${h3_int}) AS result '
    'FROM ${source_table} t',
)
