# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_FROMLONGLAT',
    sql='SELECT COUNT(@@PG_SCHEMA@@.H3_FROMLONGLAT(${lon}, ${lat}, ${resolution})) '
        'FROM ${source_table}',
)
