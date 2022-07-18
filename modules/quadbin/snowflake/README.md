# Quadbin module for Snowflake

You can learn more about quadbins in the [Overview section](/analytics-toolbox-snowflake/overview/spatial-indexes/#quadbin) of the documentation.

The functions `QUADBIN_KRING`, `QUADBIN_KRING_DISTANCES`, `QUADBIN_POLYFILL` and `QUADBIN_TOCHILDREN`  return a STRING instead of a proper ARRAY for two main issues related with Snowflake limitations:
1. Snowflake has a native support of BigInt numbers, however, if the UDF
returns this data type the next Snowflake internal error is raised:
SQL execution internal error: Processing aborted due to error 300010:3321206824
2. If the UDF returns the hex codification of the quadbin to be parsed in a SQL
higher level by using the _QUADBIN_STRING_TOINT UDF a non-correlated query can be produced.