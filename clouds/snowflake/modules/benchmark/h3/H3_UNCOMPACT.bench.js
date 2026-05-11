// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_UNCOMPACT',
    sql: 'SELECT ARRAY_SIZE(@@SF_SCHEMA@@.H3_UNCOMPACT(ARRAY_AGG(${h3_column}), ${resolution})) FROM ${source_table}'
});