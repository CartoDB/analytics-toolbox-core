# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMZXY',
    sql='SELECT COUNT(@@ORA_SCHEMA@@.QUADBIN_FROMZXY(${z}, ${x}, ${y})) FROM DUAL',
)
