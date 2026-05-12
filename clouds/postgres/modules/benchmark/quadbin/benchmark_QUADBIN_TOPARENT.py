# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOPARENT',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@PG_SCHEMA@@.QUADBIN_TOPARENT(t.${quadbin_column}, ${resolution}) AS result '
        'FROM ${source_table} t',
)
