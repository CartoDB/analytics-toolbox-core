// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'QUADBIN_TOCHILDREN',
    sql: `SELECT COUNT(*) FROM \`\${source_table}\` t,
UNNEST(\`@@BQ_DATASET@@.QUADBIN_TOCHILDREN\`(t.\${quadbin_column}, \${resolution})) AS q`
});