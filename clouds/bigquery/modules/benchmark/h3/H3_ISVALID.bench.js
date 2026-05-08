// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_ISVALID',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_ISVALID`(t.${h3_column})) FROM `${source_table}` t'
});