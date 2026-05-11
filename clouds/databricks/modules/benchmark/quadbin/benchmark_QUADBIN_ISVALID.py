# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_ISVALID',
    sql='SELECT COUNT(@@DB_SCHEMA@@.QUADBIN_ISVALID(t.${quadbin_column})) '
        'FROM ${source_table} t',
)
