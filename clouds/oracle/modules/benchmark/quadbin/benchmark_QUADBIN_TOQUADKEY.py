# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOQUADKEY',
    sql='CREATE TABLE ${output_table} AS '
    'SELECT @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY(t.${quadbin_column}) AS result '
    'FROM ${source_table} t',
)
