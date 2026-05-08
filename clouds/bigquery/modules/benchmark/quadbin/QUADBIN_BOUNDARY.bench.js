// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_BOUNDARY',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_BOUNDARY`(t.${quadbin_column})) FROM `${source_table}` t'
});