# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOCHILDREN',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT t.${quadbin_column} AS input, @@DB_SCHEMA@@.QUADBIN_TOCHILDREN(t.${quadbin_column}, ${resolution}) AS cells '
        'FROM ${source_table} t',
)
