# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMZXY',
    sql='SELECT @@PG_SCHEMA@@.QUADBIN_FROMZXY(${z}, ${x}, ${y})',
)
