// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_TOCHILDREN',
    sql: `SELECT COUNT(*) FROM \`\${source_table}\` t,
UNNEST(\`@@BQ_DATASET@@.H3_TOCHILDREN\`(t.\${h3_column}, \${resolution})) AS h`
});