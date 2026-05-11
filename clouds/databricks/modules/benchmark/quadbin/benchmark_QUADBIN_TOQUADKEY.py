# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_TOQUADKEY',
    sql='SELECT COUNT(*) FROM ('
        'SELECT @@DB_SCHEMA@@.QUADBIN_TOQUADKEY(t.${quadbin_column}) AS q '
        'FROM ${source_table} t'
        ')',
)
