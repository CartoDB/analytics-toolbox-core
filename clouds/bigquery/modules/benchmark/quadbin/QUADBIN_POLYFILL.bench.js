// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_POLYFILL',
    sql: `SELECT COUNT(*) FROM (SELECT * FROM \${source_table}) t,
UNNEST(\`@@BQ_DATASET@@.QUADBIN_POLYFILL\`(t.\${geom_column}, \${resolution})) AS q`
});