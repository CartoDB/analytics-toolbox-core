# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_HEXRING',
    sql="""CREATE TABLE ${output_table} AS
SELECT t.${h3_column} AS input, k.COLUMN_VALUE AS cell
FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.H3_HEXRING(t.${h3_column}, ${distance})) k""",
)
