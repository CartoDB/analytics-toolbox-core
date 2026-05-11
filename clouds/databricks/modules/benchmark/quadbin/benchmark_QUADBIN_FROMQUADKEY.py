# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMQUADKEY',
    sql='SELECT COUNT(*) FROM ('
        "SELECT @@DB_SCHEMA@@.QUADBIN_FROMQUADKEY('${quadkey}') AS q "
        'FROM ${source_table}'
        ')',
)
