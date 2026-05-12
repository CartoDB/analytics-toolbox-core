# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_FROMLONGLAT',
    sql="""CREATE TABLE ${output_table} AS
SELECT @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
    t.${lon_column}, t.${lat_column}, ${resolution}) AS result
FROM ${source_table} t""",
)
