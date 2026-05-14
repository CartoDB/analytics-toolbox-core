// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMZXY',
    sql: 'CREATE OR REPLACE TABLE ${output_table} AS SELECT @@SF_SCHEMA@@.QUADBIN_FROMZXY(${z}, ${x}, ${y}) AS result'
});