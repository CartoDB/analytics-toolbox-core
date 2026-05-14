// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_TOCHILDREN',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT t.\${h3_column} AS input, @@SF_SCHEMA@@.H3_TOCHILDREN(t.\${h3_column}, \${resolution}) AS cells
FROM \${source_table} t`
});