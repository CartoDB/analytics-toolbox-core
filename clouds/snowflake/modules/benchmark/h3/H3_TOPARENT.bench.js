// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_TOPARENT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_TOPARENT(t.\${h3_column}, \${resolution}) AS result
FROM \${source_table} t`
});