# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_UNCOMPACT',
    sql='SELECT COUNT(*) FROM '
        'UNNEST(@@PG_SCHEMA@@.H3_UNCOMPACT('
        'ARRAY(SELECT t.${compacted_h3_column} FROM ${source_table} t), ${resolution}))',
)
