// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_POLYFILL_MODE',
    sql: `SELECT COUNT(*) FROM (SELECT * FROM \${source_table}) t,
UNNEST(\`@@BQ_DATASET@@.H3_POLYFILL_MODE\`(t.\${geom_column}, \${resolution}, '\${mode}')) AS h`
});