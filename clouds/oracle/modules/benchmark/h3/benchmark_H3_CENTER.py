# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_CENTER',
    sql='SELECT COUNT(@@ORA_SCHEMA@@.H3_CENTER(t.${h3_column})) FROM ${source_table} t',
)
