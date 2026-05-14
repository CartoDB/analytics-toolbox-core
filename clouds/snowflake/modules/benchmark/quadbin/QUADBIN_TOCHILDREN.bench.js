// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOCHILDREN',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT t.\${quadbin_column} AS input, @@SF_SCHEMA@@.QUADBIN_TOCHILDREN(t.\${quadbin_column}, \${resolution}) AS cells
FROM \${source_table} t`
});