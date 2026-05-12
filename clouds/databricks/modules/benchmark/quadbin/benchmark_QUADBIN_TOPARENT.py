# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOPARENT',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_TOPARENT(t.${quadbin_column}, ${resolution}) AS result '
        'FROM ${source_table} t',
)
