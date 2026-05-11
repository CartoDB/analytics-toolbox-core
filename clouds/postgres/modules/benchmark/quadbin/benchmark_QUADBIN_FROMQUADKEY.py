# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMQUADKEY',
    sql="SELECT COUNT(@@PG_SCHEMA@@.QUADBIN_FROMQUADKEY('${quadkey}')) "
        'FROM ${source_table}',
)
