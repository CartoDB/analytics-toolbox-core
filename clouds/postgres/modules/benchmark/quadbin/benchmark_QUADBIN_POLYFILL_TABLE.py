from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_POLYFILL_TABLE',
    sql="""CALL @@PG_SCHEMA@@.QUADBIN_POLYFILL_TABLE(
    '${input_query}',
    ${resolution},
    '${mode}',
    '${output_table}'
)""",
)
