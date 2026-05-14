// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_ISVALID',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.QUADBIN_ISVALID(t.\${quadbin_column}) AS result
FROM \${source_table} t`
});