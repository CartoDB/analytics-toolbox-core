# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_BOUNDARY',
    sql='SELECT COUNT(@@PG_SCHEMA@@.QUADBIN_BOUNDARY(t.${quadbin_column})) '
        'FROM ${source_table} t',
)
