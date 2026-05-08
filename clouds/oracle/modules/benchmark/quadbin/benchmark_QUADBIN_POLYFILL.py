# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql="""SELECT COUNT(*) FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution}))""",
)
