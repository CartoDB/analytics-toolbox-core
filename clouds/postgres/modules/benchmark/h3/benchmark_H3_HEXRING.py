# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_HEXRING',
    sql='SELECT COUNT(*) FROM ${source_table} t, '
        'UNNEST(@@PG_SCHEMA@@.H3_HEXRING(t.${h3_column}, ${size})) AS k',
)
