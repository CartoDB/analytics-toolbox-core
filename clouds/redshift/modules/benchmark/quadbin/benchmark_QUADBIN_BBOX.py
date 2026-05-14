# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_BBOX',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT @@RS_SCHEMA@@.QUADBIN_BBOX(t.${quadbin_column}) AS result '
        'FROM ${source_table} t',
)
