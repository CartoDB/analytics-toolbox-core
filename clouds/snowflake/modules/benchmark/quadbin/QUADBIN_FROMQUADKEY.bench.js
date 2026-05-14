// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMQUADKEY',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.QUADBIN_FROMQUADKEY('\${quadkey}') AS result
FROM \${source_table}`
});