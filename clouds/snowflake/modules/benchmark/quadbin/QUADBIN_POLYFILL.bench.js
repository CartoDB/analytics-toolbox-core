// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_POLYFILL',
    sql: `SELECT COUNT(*) FROM \${source_table} t,
LATERAL FLATTEN(input => @@SF_SCHEMA@@.QUADBIN_POLYFILL(t.\${geom_column}, \${resolution}))`
});