// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_FROMLONGLAT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_FROMLONGLAT(\${lon}, \${lat}, \${resolution}) AS result
FROM \${source_table}`
});