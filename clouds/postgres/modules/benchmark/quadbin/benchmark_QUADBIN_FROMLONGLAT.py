# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMLONGLAT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(${longitude}, ${latitude}, ${resolution}) AS result '
        'FROM ${source_table}',
)
