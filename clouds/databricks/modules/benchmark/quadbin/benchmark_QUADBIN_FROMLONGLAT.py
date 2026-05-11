# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMLONGLAT',
    sql='SELECT COUNT(@@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(${lon}, ${lat}, ${resolution})) '
        'FROM ${source_table}',
)
