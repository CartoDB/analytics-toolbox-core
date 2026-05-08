// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOPARENT',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_TOPARENT`(t.${quadbin_column}, ${resolution})) FROM `${source_table}` t'
});