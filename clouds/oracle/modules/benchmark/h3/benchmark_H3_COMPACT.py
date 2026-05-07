# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_COMPACT',
    sql="""SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.H3_COMPACT(
    CAST(MULTISET(SELECT t.${h3_column} FROM ${source_table} t)
        AS @@ORA_SCHEMA@@.H3_INDEX_ARRAY)
))""",
)
