# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_COMPACT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_COMPACT(ARRAY(SELECT t.${h3_column} FROM ${source_table} t)) AS compacted',
)
