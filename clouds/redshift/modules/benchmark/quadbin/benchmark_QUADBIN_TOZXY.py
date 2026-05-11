# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOZXY',
    sql='SELECT COUNT(@@RS_SCHEMA@@.QUADBIN_TOZXY(t.${quadbin_column})) '
        'FROM ${source_table} t',
)
