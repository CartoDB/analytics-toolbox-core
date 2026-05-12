# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMQUADKEY',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        "SELECT @@DB_SCHEMA@@.QUADBIN_FROMQUADKEY('${quadkey}') AS result FROM ${source_table}",
)
