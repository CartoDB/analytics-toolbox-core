from benchmark_utils import benchmark

benchmark(
    function='QUADBIN_CENTER',
    sql='CREATE OR REPLACE TABLE ${output_table} AS '
        'SELECT @@DB_SCHEMA@@.QUADBIN_CENTER(t.${quadbin_column}) AS result '
        'FROM ${source_table} t',
)
