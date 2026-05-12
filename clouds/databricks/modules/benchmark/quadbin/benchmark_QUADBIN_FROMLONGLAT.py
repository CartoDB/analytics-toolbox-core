# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMLONGLAT',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(${lon}, ${lat}, ${resolution}) AS result '
        'FROM ${source_table}',
)
