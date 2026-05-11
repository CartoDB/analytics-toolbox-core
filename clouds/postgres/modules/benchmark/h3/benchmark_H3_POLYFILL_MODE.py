# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL_MODE',
    sql='SELECT COUNT(*) FROM (SELECT * FROM ${source_table}) t, '
        "UNNEST(@@PG_SCHEMA@@.H3_POLYFILL(t.${geom_column}, ${resolution}, '${mode}')) AS h",
)
