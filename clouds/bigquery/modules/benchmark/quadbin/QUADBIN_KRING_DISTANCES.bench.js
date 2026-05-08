// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_KRING_DISTANCES',
    sql: `SELECT COUNT(*) FROM \`\${source_table}\` t,
UNNEST(\`@@BQ_DATASET@@.QUADBIN_KRING_DISTANCES\`(t.\${quadbin_column}, \${size})) AS k`
});