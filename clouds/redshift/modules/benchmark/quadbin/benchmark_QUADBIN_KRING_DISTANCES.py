# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_KRING_DISTANCES',
    sql='CREATE TABLE ${output_table} AS '
        'SELECT t.${quadbin_column} AS input, @@RS_SCHEMA@@.QUADBIN_KRING_DISTANCES(t.${quadbin_column}, ${size}) AS kring '
        'FROM ${source_table} t',
)
