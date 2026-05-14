# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_DISTANCE',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@RS_SCHEMA@@.QUADBIN_DISTANCE(t.${quadbin_column}, t.${quadbin_column}) AS result '
        'FROM ${source_table} t',
)
