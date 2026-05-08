// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_UNCOMPACT',
    sql: 'SELECT COUNT(*) FROM UNNEST(`@@BQ_DATASET@@.H3_UNCOMPACT`(ARRAY(SELECT ${h3_column} FROM ${source_table}), ${resolution}))'
});