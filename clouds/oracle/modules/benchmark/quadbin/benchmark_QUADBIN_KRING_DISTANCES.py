# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_KRING_DISTANCES',
    sql="""CREATE TABLE ${output_table} AS
SELECT t.${quadbin_column} AS input, k.QUADBIN_INDEX, k.DISTANCE
FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES(t.${quadbin_column}, ${distance})) k""",
)
