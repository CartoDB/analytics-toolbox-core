# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_FROMGEOGPOINT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.H3_FROMGEOGPOINT(t.${geom_column}, ${resolution}) AS result '
        'FROM ${source_table} t',
)
