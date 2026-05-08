// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_FROMGEOGPOINT',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.H3_FROMGEOGPOINT`(t.${geom_column}, ${resolution})) FROM `${source_table}` t'
});