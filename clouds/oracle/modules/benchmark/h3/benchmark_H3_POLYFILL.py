# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL',
    sql="""SELECT COUNT(*) FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.H3_POLYFILL(t.${geom_column}, ${resolution}))""",
)
