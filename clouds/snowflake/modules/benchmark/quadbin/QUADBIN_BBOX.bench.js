// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_BBOX',
    sql: `SELECT COUNT(*) FROM \${source_table} t,
LATERAL FLATTEN(input => @@SF_SCHEMA@@.QUADBIN_BBOX(t.\${quadbin_column}))`
});