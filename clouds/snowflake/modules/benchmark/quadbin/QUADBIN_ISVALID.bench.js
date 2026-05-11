// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_ISVALID',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.QUADBIN_ISVALID(t.${quadbin_column})) FROM ${source_table} t'
});