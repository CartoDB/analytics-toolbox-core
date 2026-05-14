# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_ISVALID',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_ISVALID(t.${h3_column}) AS result '
        'FROM ${source_table} t',
)
