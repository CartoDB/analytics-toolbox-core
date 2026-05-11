# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOCHILDREN',
    sql='SELECT COUNT(@@RS_SCHEMA@@.QUADBIN_TOCHILDREN(t.${quadbin_column}, ${resolution})) '
        'FROM ${source_table} t',
)
