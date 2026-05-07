# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_BBOX',
    sql="""SELECT COUNT(@@ORA_SCHEMA@@.QUADBIN_BBOX(t.${quadbin_column}))
FROM ${source_table} t""",
)
