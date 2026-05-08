// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOZXY',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_TOZXY`(t.${quadbin_column}).z) FROM `${source_table}` t'
});