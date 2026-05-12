// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_POLYFILL(t.\${geom_column}, \${resolution}) AS cells
FROM \${source_table} t`
});