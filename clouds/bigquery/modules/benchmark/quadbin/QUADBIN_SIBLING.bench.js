// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_SIBLING',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_SIBLING`(t.${quadbin_column}, \'${direction}\')) FROM `${source_table}` t'
});