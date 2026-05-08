// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_RESOLUTION',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_RESOLUTION`(t.${h3_column})) FROM `${source_table}` t'
});