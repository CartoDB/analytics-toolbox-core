// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_SIBLING',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.QUADBIN_SIBLING(t.\${quadbin_column}, '\${direction}') AS result
FROM \${source_table} t`
});