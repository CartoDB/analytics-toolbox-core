# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOZXY',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(t.${quadbin_column}) AS result '
        'FROM ${source_table} t',
)
