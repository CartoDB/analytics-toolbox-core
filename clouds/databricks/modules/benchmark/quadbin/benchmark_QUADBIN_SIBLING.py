# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_SIBLING',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        "SELECT @@DB_SCHEMA@@.QUADBIN_SIBLING(t.${quadbin_column}, '${direction}') AS result "
        'FROM ${source_table} t',
)
