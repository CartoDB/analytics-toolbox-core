# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_DISTANCE',
    sql="""SELECT COUNT(
    @@ORA_SCHEMA@@.QUADBIN_DISTANCE(t.${quadbin_column}, t.${quadbin_column})
) FROM ${source_table} t""",
)
