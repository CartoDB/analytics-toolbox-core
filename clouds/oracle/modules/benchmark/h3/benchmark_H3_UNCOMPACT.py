# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_UNCOMPACT',
    sql="""CREATE TABLE ${output_table} AS
SELECT COLUMN_VALUE AS cell
FROM TABLE(@@ORA_SCHEMA@@.H3_UNCOMPACT(
    CAST(MULTISET(SELECT t.${h3_column} FROM ${source_table} t)
        AS @@ORA_SCHEMA@@.H3_INDEX_ARRAY),
    ${resolution}
))""",
)
