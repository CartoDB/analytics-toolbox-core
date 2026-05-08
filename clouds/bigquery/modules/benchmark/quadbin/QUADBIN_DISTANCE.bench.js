// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_DISTANCE',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_DISTANCE`(t.${quadbin_column}, t.${quadbin_column})) FROM `${source_table}` t'
});