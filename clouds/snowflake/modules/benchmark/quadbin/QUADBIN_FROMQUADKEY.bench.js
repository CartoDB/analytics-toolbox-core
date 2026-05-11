// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMQUADKEY',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.QUADBIN_FROMQUADKEY(\'${quadkey}\')) FROM ${source_table}'
});