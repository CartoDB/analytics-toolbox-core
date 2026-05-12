# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_UNCOMPACT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_UNCOMPACT(ARRAY(SELECT t.${h3_column} FROM ${source_table} t), ${resolution}) AS expanded',
)
