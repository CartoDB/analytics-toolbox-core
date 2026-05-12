// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_HEXRING',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT t.\${h3_column} AS input, @@SF_SCHEMA@@.H3_HEXRING(t.\${h3_column}, \${size}) AS cells
FROM \${source_table} t`
});