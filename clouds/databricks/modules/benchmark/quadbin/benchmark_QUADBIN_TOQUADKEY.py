# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOQUADKEY',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_TOQUADKEY(t.${quadbin_column}) AS result FROM ${source_table} t',
)
