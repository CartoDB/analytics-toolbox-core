# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_UNCOMPACT',
    sql="""SELECT COUNT(*) FROM TABLE(@@ORA_SCHEMA@@.H3_UNCOMPACT(
    CAST(MULTISET(SELECT t.${h3_column} FROM ${source_table} t)
        AS @@ORA_SCHEMA@@.H3_INDEX_ARRAY),
    ${resolution}
))""",
)
