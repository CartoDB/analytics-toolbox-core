// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_STRING_TOINT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_STRING_TOINT(t.\${h3_column}) AS result
FROM \${source_table} t`
});