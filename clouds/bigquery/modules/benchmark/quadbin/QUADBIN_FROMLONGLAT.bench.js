// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMLONGLAT',
    sql: 'SELECT COUNT(`@@BQ_DATASET@@.QUADBIN_FROMLONGLAT`(${lon}, ${lat}, ${resolution})) FROM `${source_table}`'
});