# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMZXY',
    sql='CREATE TABLE ${output_table} AS '
    'SELECT @@ORA_SCHEMA@@.QUADBIN_FROMZXY(${z}, ${x}, ${y}) AS result FROM DUAL',
)
