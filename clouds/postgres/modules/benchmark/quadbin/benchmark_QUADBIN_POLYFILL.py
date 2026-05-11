# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL',
    sql='SELECT COUNT(*) FROM (SELECT * FROM ${source_table}) t, '
        'UNNEST(@@PG_SCHEMA@@.QUADBIN_POLYFILL(t.${geom_column}, ${resolution})) AS q',
)
