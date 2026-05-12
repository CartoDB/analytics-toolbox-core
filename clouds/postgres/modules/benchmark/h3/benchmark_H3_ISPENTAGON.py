# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_ISPENTAGON',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_ISPENTAGON(t.${h3_column}) AS result '
        'FROM ${source_table} t',
)
