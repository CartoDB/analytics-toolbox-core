// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_STRING_TOINT',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.H3_STRING_TOINT(t.${h3_column})) FROM ${source_table} t'
});