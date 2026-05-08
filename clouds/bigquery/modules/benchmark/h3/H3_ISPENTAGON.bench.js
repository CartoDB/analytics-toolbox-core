// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_ISPENTAGON',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_ISPENTAGON`(t.${h3_column})) FROM `${source_table}` t'
});