# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOPARENT',
    sql='SELECT COUNT(@@DB_SCHEMA@@.QUADBIN_TOPARENT(t.${quadbin_column}, ${resolution})) '
        'FROM ${source_table} t',
)
