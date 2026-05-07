# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMGEOGPOINT',
    sql="""SELECT COUNT(
    @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT(t.${geom_column}, ${resolution})
) FROM ${source_table} t""",
)
