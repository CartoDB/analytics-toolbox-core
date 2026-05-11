# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_TOCHILDREN',
    sql='SELECT COUNT(*) FROM ${source_table} t, '
        'UNNEST(@@PG_SCHEMA@@.H3_TOCHILDREN(t.${h3_column}, ${resolution})) AS c',
)
