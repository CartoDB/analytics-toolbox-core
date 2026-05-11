// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMLONGLAT',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.QUADBIN_FROMLONGLAT(${lon}, ${lat}, ${resolution})) FROM ${source_table}'
});