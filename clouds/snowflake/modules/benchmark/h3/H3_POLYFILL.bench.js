// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL',
    sql: `SELECT COUNT(*) FROM \${source_table} t,
LATERAL FLATTEN(input => @@SF_SCHEMA@@.H3_POLYFILL(t.\${geom_column}, \${resolution}))`
});