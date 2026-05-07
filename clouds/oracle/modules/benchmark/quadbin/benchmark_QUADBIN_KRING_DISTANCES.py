# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_KRING_DISTANCES',
    sql="""SELECT COUNT(*) FROM ${source_table} t,
TABLE(@@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES(t.${quadbin_column}, ${size}))""",
)
