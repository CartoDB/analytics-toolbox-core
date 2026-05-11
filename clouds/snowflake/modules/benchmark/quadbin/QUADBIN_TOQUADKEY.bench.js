// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOQUADKEY',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.QUADBIN_TOQUADKEY(t.${quadbin_column})) FROM ${source_table} t'
});