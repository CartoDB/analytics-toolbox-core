from benchmark_utils import benchmark

benchmark(
    function='H3_ISPENTAGON',
    sql='CREATE TABLE ${output_table} AS '
    'SELECT @@ORA_SCHEMA@@.H3_ISPENTAGON(t.${h3_column}) AS result '
    'FROM ${source_table} t',
)
