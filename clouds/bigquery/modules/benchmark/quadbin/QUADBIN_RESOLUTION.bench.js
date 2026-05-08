// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_RESOLUTION',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_RESOLUTION`(t.${quadbin_column})) FROM `${source_table}` t'
});