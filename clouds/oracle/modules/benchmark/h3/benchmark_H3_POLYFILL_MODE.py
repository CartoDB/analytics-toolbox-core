# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL_MODE',
    sql="""CREATE TABLE ${output_table} AS
SELECT p.COLUMN_VALUE AS cell
FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.H3_POLYFILL_MODE(t.${geom_column}, ${resolution}, '${mode}')) p""",
)
