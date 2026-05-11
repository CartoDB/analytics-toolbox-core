# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_KRING',
    sql='SELECT COUNT(@@RS_SCHEMA@@.QUADBIN_KRING(t.${quadbin_column}, ${size})) '
        'FROM ${source_table} t',
)
