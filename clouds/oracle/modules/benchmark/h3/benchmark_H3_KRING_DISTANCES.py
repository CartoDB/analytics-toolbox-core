# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_KRING_DISTANCES',
    sql="""CREATE TABLE ${output_table} AS
SELECT t.${h3_column} AS input, k.h3, k.distance
FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.H3_KRING_DISTANCES(t.${h3_column}, ${size})) k""",
)
