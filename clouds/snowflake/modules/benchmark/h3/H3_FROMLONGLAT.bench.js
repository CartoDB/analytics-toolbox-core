// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_FROMLONGLAT',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.H3_FROMLONGLAT(${lon}, ${lat}, ${resolution})) FROM ${source_table}'
});