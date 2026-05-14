// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_COMPACT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_COMPACT(ARRAY_AGG(t.\${h3_column})) AS compacted
FROM \${source_table} t`
});