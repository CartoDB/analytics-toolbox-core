# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOCHILDREN',
    sql="""SELECT COUNT(*) FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN(t.${quadbin_column}, ${resolution}))""",
)
