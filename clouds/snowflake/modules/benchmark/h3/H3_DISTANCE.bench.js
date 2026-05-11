// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_DISTANCE',
    sql: 'SELECT COUNT(@@SF_SCHEMA@@.H3_DISTANCE(t.${h3_column}, t.${h3_column})) FROM ${source_table} t'
});