// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_INT_TOSTRING',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_INT_TOSTRING`(${h3_int})) FROM `${source_table}`'
});