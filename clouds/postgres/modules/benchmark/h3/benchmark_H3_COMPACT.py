# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_COMPACT',
    sql='SELECT COUNT(*) FROM '
        'UNNEST(@@PG_SCHEMA@@.H3_COMPACT(ARRAY(SELECT t.${h3_column} FROM ${source_table} t)))',
)
