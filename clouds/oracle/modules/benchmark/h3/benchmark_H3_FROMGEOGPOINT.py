# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_FROMGEOGPOINT',
    sql="""SELECT COUNT(
    @@ORA_SCHEMA@@.H3_FROMGEOGPOINT(t.${geom_column}, ${resolution})
) FROM ${source_table} t""",
)
