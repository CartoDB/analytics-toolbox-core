// Copyright (c) 2026, CARTO

const { benchmark } = require('../../../common/benchmark-utils');

benchmark({
    function: 'H3_FROMGEOGPOINT',
    sql: `CREATE OR REPLACE TABLE \${output_table} AS
SELECT @@SF_SCHEMA@@.H3_FROMGEOGPOINT(t.\${geom_column}, \${resolution}) AS result
FROM \${source_table} t`
});