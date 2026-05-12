# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_FROMLONGLAT',
    sql="""CREATE TABLE ${output_table} AS
SELECT @@ORA_SCHEMA@@.H3_FROMLONGLAT(
    t.${longitude}, t.${latitude}, ${resolution}) AS result
FROM ${source_table} t""",
)
