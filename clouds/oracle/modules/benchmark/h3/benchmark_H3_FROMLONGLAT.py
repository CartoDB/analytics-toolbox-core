# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_FROMLONGLAT',
    sql="""SELECT COUNT(
    @@ORA_SCHEMA@@.H3_FROMLONGLAT(t.${lon_column}, t.${lat_column}, ${resolution})
) FROM ${source_table} t""",
)
