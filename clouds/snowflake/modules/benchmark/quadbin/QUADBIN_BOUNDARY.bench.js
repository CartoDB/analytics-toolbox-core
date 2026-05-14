// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_BOUNDARY',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.QUADBIN_BOUNDARY(t.\${quadbin_column}) AS result
FROM \${source_table} t`
});