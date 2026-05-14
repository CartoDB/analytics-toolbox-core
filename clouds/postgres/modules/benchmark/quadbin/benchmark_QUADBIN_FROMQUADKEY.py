# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMQUADKEY',
    sql="CREATE TABLE ${output_table} AS "
        "SELECT @@PG_SCHEMA@@.QUADBIN_FROMQUADKEY('${quadkey}') AS result "
        'FROM ${source_table}',
)
