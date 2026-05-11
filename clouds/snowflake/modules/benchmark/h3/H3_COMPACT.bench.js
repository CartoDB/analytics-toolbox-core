// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_COMPACT',
    sql: 'SELECT ARRAY_SIZE(@@SF_SCHEMA@@.H3_COMPACT(ARRAY_AGG(${h3_column}))) FROM ${source_table}'
});