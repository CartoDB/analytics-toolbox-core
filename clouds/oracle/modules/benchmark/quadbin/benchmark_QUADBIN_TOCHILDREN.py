# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOCHILDREN',
    sql="""CREATE TABLE ${output_table} AS
SELECT t.${quadbin_column} AS input, k.COLUMN_VALUE AS cell
FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN(t.${quadbin_column}, ${resolution})) k""",
)
