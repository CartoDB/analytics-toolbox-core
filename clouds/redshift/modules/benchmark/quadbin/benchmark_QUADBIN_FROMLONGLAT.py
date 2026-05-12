# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMLONGLAT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@RS_SCHEMA@@.QUADBIN_FROMLONGLAT(${lon}, ${lat}, ${resolution}) AS result '
        'FROM ${source_table} t',
)
