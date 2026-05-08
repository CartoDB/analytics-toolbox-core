// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_TOPARENT',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_TOPARENT`(t.${h3_column}, ${resolution})) FROM `${source_table}` t'
});