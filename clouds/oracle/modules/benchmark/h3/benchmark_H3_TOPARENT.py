# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_TOPARENT',
    sql="""SELECT COUNT(@@ORA_SCHEMA@@.H3_TOPARENT(t.${h3_column}, ${resolution}))
FROM ${source_table} t""",
)
