# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_TOPARENT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_TOPARENT(t.${h3_column}, ${resolution}) AS result '
        'FROM ${source_table} t',
)
