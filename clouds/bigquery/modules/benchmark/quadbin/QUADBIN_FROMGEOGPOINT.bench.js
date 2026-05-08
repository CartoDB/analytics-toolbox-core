// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMGEOGPOINT',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_FROMGEOGPOINT`(t.${geom_column}, ${resolution})) FROM `${source_table}` t'
});