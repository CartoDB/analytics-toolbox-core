# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_RESOLUTION',
    sql='CREATE TABLE ${output_table} AS '
    'SELECT @@ORA_SCHEMA@@.H3_RESOLUTION(t.${h3_column}) AS result '
    'FROM ${source_table} t',
)
