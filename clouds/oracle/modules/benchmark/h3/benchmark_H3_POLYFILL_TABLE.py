# Copyright (c) 2026, CARTO

from benchmark_utils import benchmark

benchmark(
    function='H3_POLYFILL_TABLE',
    sql="""CALL @@ORA_SCHEMA@@.H3_POLYFILL_TABLE(
    '${input_query}',
    ${resolution},
    '${mode}',
    '${output_table}'
)""",
)
