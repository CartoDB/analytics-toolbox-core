# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMGEOGPOINT',
    sql="""CREATE TABLE ${output_table} AS
SELECT @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT(t.${geom_column}, ${resolution}) AS result
FROM ${source_table} t""",
)
