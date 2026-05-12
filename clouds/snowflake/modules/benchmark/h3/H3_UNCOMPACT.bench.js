// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_UNCOMPACT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_UNCOMPACT(ARRAY_AGG(t.\${h3_column}), \${resolution}) AS expanded
FROM \${source_table} t`
});