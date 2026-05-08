// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_FROMZXY',
    sql: 'SELECT `@@BQ_DATASET@@.QUADBIN_FROMZXY`(${z}, ${x}, ${y})'
});