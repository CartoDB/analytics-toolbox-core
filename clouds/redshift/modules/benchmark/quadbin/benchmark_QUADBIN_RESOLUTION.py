# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_RESOLUTION',
    sql='SELECT COUNT(@@RS_SCHEMA@@.QUADBIN_RESOLUTION(t.${quadbin_column})) '
        'FROM ${source_table} t',
)
