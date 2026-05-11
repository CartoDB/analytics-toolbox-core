# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_SIBLING',
    sql="SELECT COUNT(@@DB_SCHEMA@@.QUADBIN_SIBLING(t.${quadbin_column}, '${direction}')) "
        'FROM ${source_table} t',
)
