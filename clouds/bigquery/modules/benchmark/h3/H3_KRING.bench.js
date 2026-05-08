// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_KRING',
    sql: `SELECT COUNT(*) FROM \`\${source_table}\` t,
UNNEST(\`@@BQ_DATASET@@.H3_KRING\`(t.\${h3_column}, \${size})) AS k`
});